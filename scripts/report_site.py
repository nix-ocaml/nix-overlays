#!/usr/bin/env python3
"""Publish a bounded report archive from Actions data, never from artifact HTML."""

import argparse
import base64
import collections
import datetime as dt
import hashlib
import html
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import tempfile
import zipfile


ARCHIVE_BRANCH = "build-reports"
MAX_ARTIFACT_BYTES = 256 * 1024 * 1024
MAX_DATA_BYTES = 32 * 1024 * 1024
MAX_EVENTS_BYTES = 64 * 1024 * 1024
MAX_REPORT_BYTES = 64 * 1024 * 1024
MAX_ARCHIVE_BYTES = 512 * 1024 * 1024
ARTIFACT_NAME = re.compile(r"^nix-ci-build-[A-Za-z0-9_.-]+-attempt-([1-9][0-9]*)$")
SHA = re.compile(r"^[a-f0-9]{40}$")
REPOSITORY = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")


def positive(value):
    number = int(value)
    if number < 1:
        raise ValueError("expected a positive integer")
    return number


def escape(value):
    return html.escape(str(value), quote=True)


def decode_json(data):
    def invalid_constant(_):
        raise ValueError("non-finite JSON number")

    try:
        return json.loads(data, parse_constant=invalid_constant)
    except RecursionError as error:
        raise ValueError("JSON nesting exceeds the limit") from error


class GitHub:
    def __init__(self, repository):
        if not REPOSITORY.fullmatch(repository):
            raise ValueError("invalid repository")
        self.repository = repository
        self.prefix = "repos/" + repository + "/"

    def request(self, endpoint, *, binary=False, missing=False, limit=MAX_ARCHIVE_BYTES):
        # gh handles authentication and authenticated redirects. Never evaluate a
        # command or URL supplied by a build artifact.
        with tempfile.TemporaryFile() as output:
            result = subprocess.run(
                ["gh", "api", self.prefix + endpoint],
                stdout=output, stderr=subprocess.PIPE, timeout=180,
            )
            size = output.tell()
            if size > limit:
                raise ValueError("GitHub response exceeds the size limit")
            output.seek(0)
            data = output.read()
        if result.returncode:
            if missing:
                try:
                    if str(decode_json(data).get("status")) == "404":
                        return None
                except (ValueError, AttributeError):
                    pass
            raise RuntimeError("GitHub API request failed: " + endpoint.split("?")[0])
        return data if binary else decode_json(data)

    def pages(self, endpoint, key):
        result = []
        for page in range(1, 21):
            separator = "&" if "?" in endpoint else "?"
            data = self.request(f"{endpoint}{separator}per_page=100&page={page}")
            items = data[key] if key else data
            result.extend(items)
            if len(items) < 100:
                return result
        raise ValueError("GitHub result exceeds the pagination limit")


def safe_archive_path(name):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or "\\" in name:
        raise ValueError("unsafe archive path")
    return path


def regular_member(info):
    mode = info.external_attr >> 16
    return not mode or stat.S_IFMT(mode) in (0, stat.S_IFREG)


def read_report_member(archive, info):
    try:
        return archive.read(info)
    except (NotImplementedError, RuntimeError) as error:
        raise ValueError("unsupported or encrypted report data") from error


def artifact_data(data):
    """Read only the two known data files; do not extract HTML, scripts or logs."""
    result = {}
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        if len(archive.infolist()) > 10000:
            raise ValueError("too many artifact entries")
        for info in archive.infolist():
            safe_archive_path(info.filename)
            if info.filename not in ("results.json", "events.jsonl"):
                continue
            if info.filename in result or not regular_member(info):
                raise ValueError("duplicate or non-regular report data")
            limit = MAX_DATA_BYTES if info.filename == "results.json" else MAX_EVENTS_BYTES
            if info.file_size > limit:
                raise ValueError("report data exceeds the size limit")
            result[info.filename] = read_report_member(archive, info)
    if "results.json" not in result:
        raise ValueError("artifact does not contain results.json")
    snapshot = decode_json(result["results.json"])
    if not isinstance(snapshot, dict) or snapshot.get("schemaVersion") != 1:
        raise ValueError("unsupported report schema")
    if not isinstance(snapshot.get("jobs", []), list):
        raise ValueError("invalid report jobs")
    events, notes = [], []
    raw_events = result.get("events.jsonl", b"")
    lines = raw_events.splitlines()
    for number, line in enumerate(lines):
        if line.strip():
            try:
                event = decode_json(line)
            except ValueError:
                if number == len(lines) - 1 and not raw_events.endswith((b"\n", b"\r")):
                    notes.append("The final event was incomplete; the timeline includes all earlier complete events.")
                    break
                raise
            if not isinstance(event, dict):
                raise ValueError("invalid report event")
            events.append(event)
            if len(events) > 200000:
                raise ValueError("too many report events")
    return snapshot, events, notes


def restore_archive(api, site):
    ref = api.request("git/ref/heads/" + ARCHIVE_BRANCH, missing=True)
    if ref is None:
        return {"version": 1, "repository": api.repository, "runs": []}, ""
    revision = ref["object"]["sha"]
    if not SHA.fullmatch(revision):
        raise ValueError("invalid archive revision")
    data = api.request("zipball/" + revision, binary=True)
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        members = archive.infolist()
        if len(members) > 10000 or sum(i.file_size for i in members) > MAX_ARCHIVE_BYTES:
            raise ValueError("archive exceeds the size limit")
        for info in members:
            source = safe_archive_path(info.filename)
            parts = source.parts[1:]  # GitHub zipballs have one repository directory.
            if not parts or info.is_dir():
                continue
            if not regular_member(info) or ".git" in parts:
                raise ValueError("non-regular file in report archive")
            destination = site.joinpath(*parts)
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(archive.read(info))
    catalog = decode_json((site / "catalog.json").read_bytes())
    if catalog.get("version") != 1 or catalog.get("repository") != api.repository:
        raise ValueError("archive belongs to another repository or schema")
    for run in catalog["runs"]:
        positive(run["id"])
        positive(run["attempt"])
        if not SHA.fullmatch(run["headSha"]):
            raise ValueError("invalid archived commit")
    return catalog, revision


def run_path(run):
    return f"runs/{positive(run['id'])}/{positive(run['attempt'])}"


def branch_path(run):
    label = run["headRepository"] + "/" + run["headBranch"]
    slug = re.sub(r"[^A-Za-z0-9_-]+", "-", label).strip("-")[:100] or "branch"
    return "branches/" + slug + "-" + hashlib.sha256(label.encode()).hexdigest()[:10]


def timestamp(value):
    try:
        return dt.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()
    except (ValueError, AttributeError):
        return None


def duration(start, end):
    start, end = timestamp(start), timestamp(end)
    return max(0, end - start) if start is not None and end is not None else None


def elapsed(seconds):
    if seconds is None:
        return "—"
    seconds = int(seconds)
    return f"{seconds // 3600}h {seconds % 3600 // 60}m" if seconds >= 3600 else f"{seconds // 60}m {seconds % 60}s"


STYLE = """
:root {
  color-scheme: light dark;
  --bg: #f6f6f8;
  --panel: #fff;
  --fg: #232333;
  --muted: #686879;
  --line: #dfe0e5;
  --soft: #f2edf8;
  --accent: #632ca6;
  --selected: #f1eafa;
  --success: #188762;
  --danger: #ce4659;
  --warning: #ae7d23;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #17171e;
    --panel: #202029;
    --fg: #e8e7ef;
    --muted: #a7a5b8;
    --line: #383741;
    --soft: #2c253a;
    --accent: #b28be1;
    --selected: #362747;
    --success: #5abf97;
    --danger: #f07c8d;
    --warning: #d4ae63;
  }
}
* {
  box-sizing: border-box;
}
[hidden] {
  display: none !important;
}
body {
  margin: 0;
  background: var(--bg);
  color: var(--fg);
  font:
    13px/1.5 system-ui,
    sans-serif;
}
a {
  color: var(--accent);
  text-decoration: none;
}
a:hover {
  text-decoration: underline;
}
button,
input,
select {
  font: inherit;
}
button {
  cursor: pointer;
}
button,
input,
select {
  color: var(--fg);
  background: var(--panel);
  border: 1px solid var(--line);
  border-radius: 4px;
}
button {
  padding: 5px 9px;
}
button:hover {
  background: var(--soft);
}
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
input {
  padding: 7px 10px;
  width: min(100%, 600px);
}
input::placeholder {
  color: var(--muted);
}
select {
  padding: 5px 26px 5px 8px;
}
h1 {
  font-size: 23px;
  line-height: 1.3;
  letter-spacing: -0.025em;
  margin: 17px 0 10px;
}
h2 {
  font-size: 16px;
  margin: 22px 0 10px;
}
h3 {
  font-size: 13px;
  margin: 0;
}
p,
.muted {
  color: var(--muted);
}
p {
  margin: 8px 0 12px;
}
code {
  font:
    12px ui-monospace,
    monospace;
  overflow-wrap: anywhere;
}
.masthead {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  min-height: 42px;
  padding: 8px 24px;
  border-bottom: 1px solid var(--line);
  background: var(--panel);
}
.masthead-brand {
  font-weight: 650;
  color: var(--fg);
  display: flex;
  align-items: center;
  gap: 9px;
}
.brand-mark {
  display: inline-grid;
  place-items: center;
  width: 23px;
  height: 23px;
  border-radius: 4px;
  background: var(--accent);
  color: var(--panel);
  font:
    700 14px ui-monospace,
    monospace;
}
.masthead-subtitle {
  color: var(--muted);
  font-size: 12px;
}
.masthead nav {
  font-size: 12px;
}
main {
  max-width: 1760px;
  margin: 0 auto;
  padding: 0 24px 24px;
  min-width: 0;
}
nav {
  display: flex;
  gap: 15px;
  align-items: center;
  flex-wrap: wrap;
}
.run-nav {
  font-size: 12px;
  padding-bottom: 3px;
}
.run-meta {
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 9px;
  flex-wrap: wrap;
}
.panel {
  background: var(--panel);
  border: 1px solid var(--line);
  border-radius: 4px;
  margin: 12px 0;
  overflow: auto;
}
.panel table {
  min-width: 580px;
}
table {
  border-collapse: collapse;
  width: 100%;
  text-align: left;
  font-size: 12px;
}
th {
  color: var(--muted);
  font-size: 11px;
  font-weight: 600;
  background: var(--bg);
}
td,
th {
  padding: 9px 12px;
  border-bottom: 1px solid var(--line);
  vertical-align: top;
}
tr:last-child td {
  border-bottom: 0;
}
tbody tr:hover {
  background: var(--soft);
}
.badge {
  font: 600 10px system-ui;
  border-radius: 3px;
  padding: 3px 6px;
  white-space: nowrap;
  background: #6a778218;
  color: var(--muted);
}
.success {
  background: #16966a18;
  color: var(--success);
}
.failure,
.failed,
.error,
.timed_out {
  background: #df494918;
  color: var(--danger);
}
.cancelled,
.skipped {
  background: #b3862918;
  color: var(--warning);
}
.facts {
  display: grid;
  grid-template-columns: repeat(6, minmax(0, 1fr));
  padding: 14px 0;
  margin-top: 15px;
}
.facts > div {
  border-right: 1px solid var(--line);
  padding: 0 20px;
  color: var(--muted);
  font-size: 11px;
}
.facts > div:last-child {
  border-right: 0;
}
.facts strong {
  font-size: 24px;
  line-height: 1.25;
  font-weight: 600;
  display: block;
  color: var(--fg);
  font-variant-numeric: tabular-nums;
  margin-bottom: 3px;
}
.section-heading {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-top: 22px;
  margin-bottom: 10px;
}
.section-heading h2 {
  margin: 0;
}
.table-search {
  display: flex;
  gap: 8px;
  align-items: center;
  color: var(--muted);
  font-size: 12px;
}
.table-search input {
  width: 300px;
}
.notice {
  border-left: 3px solid var(--warning);
  padding: 8px 12px;
  background: var(--panel);
  font-size: 12px;
}
footer {
  font-size: 11px;
  color: var(--muted);
  margin-top: 24px;
  max-width: 1000px;
}
.explorer {
  display: grid;
  grid-template-columns: 162px minmax(0, 1fr) 310px;
  background: var(--panel);
  border: 1px solid var(--line);
  border-radius: 4px;
  min-width: 0;
}
.facets {
  padding: 14px 10px;
  border-right: 1px solid var(--line);
}
.facet-heading {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  color: var(--muted);
  font-weight: 650;
  margin: 0 6px 8px;
}
.facet-button {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 0;
  padding: 7px 8px;
  text-align: left;
  font-size: 12px;
  background: transparent;
  margin-bottom: 2px;
}
.facet-button[aria-pressed="true"] {
  background: var(--selected);
  color: var(--accent);
  font-weight: 600;
}
.facet-count {
  font-size: 11px;
  color: var(--muted);
  font-variant-numeric: tabular-nums;
}
.facet-note {
  font-size: 11px;
  color: var(--muted);
  padding: 12px 6px;
  margin-top: 12px;
  border-top: 1px solid var(--line);
}
.waterfall {
  min-width: 0;
}
.explorer-toolbar {
  padding: 10px 12px;
  border-bottom: 1px solid var(--line);
  display: flex;
  gap: 8px;
  align-items: center;
}
.explorer-toolbar input {
  width: 100%;
  min-width: 0;
}
.search-shortcut {
  color: var(--muted);
  font:
    11px ui-monospace,
    monospace;
  line-height: 1;
  border: 1px solid var(--line);
  padding: 3px 5px;
  border-radius: 3px;
}
.query-wrap {
  display: flex;
  align-items: center;
  position: relative;
  flex: 1;
  min-width: 0;
}
.query-wrap input {
  padding-right: 30px;
}
.query-wrap kbd {
  position: absolute;
  right: 8px;
  pointer-events: none;
}
.waterfall-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 12px;
  font-size: 11px;
  color: var(--muted);
  border-bottom: 1px solid var(--line);
  flex-wrap: wrap;
}
.waterfall-toolbar label {
  display: flex;
  gap: 6px;
  align-items: center;
}
.waterfall-actions {
  display: flex;
  gap: 5px;
  align-items: center;
}
.waterfall-actions button {
  font-size: 11px;
  padding: 4px 7px;
}
.matrix-scroll {
  overflow: auto;
  max-height: 620px;
}
.matrix {
  min-width: 600px;
  position: relative;
}
.matrix-axis,
.matrix-row {
  display: grid;
  grid-template-columns: minmax(210px, 1fr) minmax(270px, 1.5fr) 66px;
  gap: 10px;
  align-items: center;
}
.matrix-axis {
  position: sticky;
  top: 0;
  z-index: 2;
  background: var(--bg);
  font-size: 10px;
  color: var(--muted);
  height: 35px;
  padding: 0 10px;
  border-bottom: 1px solid var(--line);
}
.matrix-ticks {
  position: relative;
  height: 14px;
}
.matrix-ticks span {
  position: absolute;
  white-space: nowrap;
  transform: translateX(-50%);
}
.matrix-ticks span:first-child {
  transform: none;
}
.matrix-ticks span:last-child {
  transform: translateX(-100%);
}
.matrix-row {
  width: 100%;
  border: 0;
  border-bottom: 1px solid var(--line);
  border-radius: 0;
  background: none;
  color: inherit;
  text-align: left;
  padding: 7px 10px;
  height: 35px;
  cursor: pointer;
}
.matrix-row:hover {
  background: var(--soft);
}
.matrix-row:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: -2px;
}
.matrix-row[aria-expanded="true"] {
  background: var(--selected);
  box-shadow: inset 3px 0 var(--accent);
}
.matrix-label {
  display: flex;
  align-items: center;
  gap: 7px;
  font-size: 11px;
  min-width: 0;
}
.matrix-label-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.status-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--muted);
  flex: none;
}
.status-dot.success {
  background: var(--success);
}
.status-dot.failure,
.status-dot.timed_out,
.status-dot.failed {
  background: var(--danger);
}
.status-dot.cancelled,
.status-dot.skipped {
  background: var(--warning);
}
.matrix-duration {
  font-size: 11px;
  color: var(--muted);
  text-align: right;
  white-space: nowrap;
  font-variant-numeric: tabular-nums;
}
.matrix-track {
  display: block;
  position: relative;
  height: 20px;
  background: repeating-linear-gradient(
    to right,
    transparent 0,
    transparent calc(25% - 1px),
    var(--line) calc(25% - 1px),
    var(--line) 25%
  );
  border-left: 1px solid var(--line);
  overflow: hidden;
}
.matrix-span {
  position: absolute;
  top: 3px;
  height: 14px;
  border-radius: 2px;
}
.phase-job {
  background: var(--line);
}
.phase-checkout {
  background: #9c6bd3;
}
.phase-setup {
  background: #5a95de;
}
.phase-build {
  background: #36a88b;
}
.phase-upload {
  background: #dba44d;
}
.phase-other {
  background: #9496aa;
}
.legend {
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  font-size: 10px;
  color: var(--muted);
  padding: 9px 12px;
  border-top: 1px solid var(--line);
}
.legend span {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}
.legend i {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 1px;
}
.inspector {
  border-left: 1px solid var(--line);
  min-width: 0;
}
.inspector-header {
  height: 53px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 14px;
  border-bottom: 1px solid var(--line);
}
.inspector-header h2 {
  font-size: 12px;
  margin: 0;
}
.inspector-header span {
  font-size: 10px;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.inspector-content {
  max-height: 710px;
  overflow: auto;
}
.job-details {
  padding: 12px 14px;
  border-bottom: 1px solid var(--line);
}
.job-details:target {
  outline: 2px solid var(--accent);
  outline-offset: -2px;
}
.job-details summary {
  cursor: pointer;
  list-style: none;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  align-items: center;
}
.job-details summary::-webkit-details-marker {
  display: none;
}
.job-details summary strong {
  display: block;
  width: 100%;
  font-size: 13px;
  line-height: 1.45;
  overflow-wrap: anywhere;
  order: 1;
}
.job-details summary .muted {
  margin-left: auto;
  font-size: 12px;
  font-variant-numeric: tabular-nums;
}
.job-detail-body > p {
  font-size: 11px;
  margin: 10px 0;
}
.job-tabs {
  display: flex;
  gap: 16px;
  border-bottom: 1px solid var(--line);
  margin-top: 14px;
  margin-bottom: 12px;
}
.job-tabs button {
  border: 0;
  border-bottom: 2px solid transparent;
  border-radius: 0;
  background: none;
  padding: 7px 0;
  font-size: 11px;
}
.job-tabs button[aria-selected="true"] {
  border-color: var(--accent);
  color: var(--accent);
  font-weight: 600;
}
.step-item {
  padding: 9px 0;
  border-bottom: 1px solid var(--line);
}
.step-item:last-child {
  border-bottom: 0;
}
.step-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 8px;
}
.step-name {
  font-size: 11px;
  overflow-wrap: anywhere;
}
.step-duration {
  font-size: 11px;
  white-space: nowrap;
  color: var(--muted);
  font-variant-numeric: tabular-nums;
}
.step-bottom {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 6px;
}
.step-track {
  height: 4px;
  flex: 1;
  background: var(--line);
  border-radius: 1px;
  overflow: hidden;
}
.step-bar {
  height: 4px;
  display: block;
  border-radius: 1px;
}
.step-bottom .badge {
  font-size: 9px;
  padding: 1px 4px;
}
.job-metadata {
  display: grid;
  grid-template-columns: 70px minmax(0, 1fr);
  font-size: 11px;
  margin: 0;
  gap: 10px;
}
.job-metadata dt {
  color: var(--muted);
}
.job-metadata dd {
  margin: 0;
  overflow-wrap: anywhere;
}
.empty-state {
  padding: 30px 20px;
  text-align: center;
  color: var(--muted);
  font-size: 12px;
}
.enhanced .job-details:not([open]) {
  display: none;
}
.enhanced .job-details {
  border: 0;
}
.enhanced .job-details summary {
  cursor: default;
}
.enhanced .job-details:target {
  outline: none;
}
.toolbar-note {
  font-size: 11px;
  color: var(--muted);
  margin: 7px 0 12px;
}
.inline-button {
  font: inherit;
  border: 0;
  padding: 0;
  color: var(--accent);
  background: none;
}
.index-count {
  font-size: 11px;
  color: var(--muted);
  margin-left: 8px;
}
.screen-reader {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
@media (max-width: 1200px) {
  .explorer {
    grid-template-columns: 156px minmax(0, 1fr);
  }
  .inspector {
    grid-column: 1/-1;
    border-left: 0;
    border-top: 1px solid var(--line);
  }
  .inspector-content {
    max-height: 420px;
  }
  .job-detail-body {
    display: grid;
    grid-template-columns: 220px minmax(0, 1fr);
    column-gap: 24px;
  }
  .job-detail-body > p {
    grid-column: 1;
  }
  .job-tabs {
    grid-column: 2;
    grid-row: 1;
    margin-top: 0;
  }
  .job-tab-panel {
    grid-column: 2;
    grid-row: 2/5;
  }
  .job-details summary {
    max-width: 320px;
  }
  .facts > div {
    padding: 0 14px;
  }
}
@media (max-width: 720px) {
  main {
    padding: 0 12px 20px;
  }
  .masthead {
    padding: 8px 12px;
  }
  .masthead-subtitle {
    display: none;
  }
  .masthead nav {
    font-size: 11px;
  }
  h1 {
    font-size: 20px;
  }
  .facts {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    row-gap: 16px;
  }
  .facts > div:nth-child(3) {
    border-right: 0;
  }
  .facts strong {
    font-size: 21px;
  }
  .explorer {
    display: block;
  }
  .facets {
    border-right: 0;
    border-bottom: 1px solid var(--line);
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    padding: 9px;
  }
  .facet-heading {
    width: 100%;
    margin-bottom: 3px;
  }
  .facet-button {
    width: auto;
    gap: 7px;
    padding: 4px 7px;
    border: 1px solid var(--line);
    margin: 0;
  }
  .facet-note {
    display: none;
  }
  .inspector {
    border-left: 0;
  }
  .job-detail-body {
    display: block;
  }
  .job-tabs {
    margin-top: 14px;
  }
  .job-details summary {
    max-width: none;
  }
  .section-heading {
    display: block;
  }
  .table-search {
    margin-top: 8px;
  }
  .table-search input {
    width: 100%;
  }
  .section-heading .muted {
    font-size: 11px;
  }
  .matrix-scroll {
    max-height: 460px;
  }
  .waterfall-toolbar select {
    max-width: 150px;
  }
  .explorer-toolbar {
    padding: 9px;
  }
  .toolbar-note {
    font-size: 11px;
  }
  .matrix {
    min-width: 580px;
  }
  .panel table {
    min-width: 560px;
  }
}
"""
FILTER = """
(() => {
  const search = document.querySelector("#search");
  if (search)
    search.addEventListener("input", () => {
      const query = search.value.toLowerCase().trim();
      const rows = [...document.querySelectorAll("tbody[data-filter] tr")];
      rows.forEach((row) => {
        row.hidden = !row.textContent.toLowerCase().includes(query);
      });
      const count = document.querySelector("#index-count");
      if (count)
        count.textContent =
          rows.filter((row) => !row.hidden).length + " of " + rows.length;
    });
  const explorer = document.querySelector("#pipeline-explorer");
  if (!explorer) return;
  explorer.classList.add("enhanced");
  const rows = [...explorer.querySelectorAll("button[data-job]")];
  const details = [...explorer.querySelectorAll(".job-details")];
  const query = document.querySelector("#job-search");
  const facets = [...explorer.querySelectorAll("[data-outcome]")];
  const counter = document.querySelector("#job-count");
  const empty = document.querySelector("#job-empty");
  const inspectorEmpty = document.querySelector("#inspector-empty");
  const matrix = document.querySelector("#matrix");
  const fullSpan = Number(matrix.dataset.span);
  let selected = null;
  let initialized = false;
  let outcome = "";
  let windowStart = 0;
  let windowEnd = fullSpan;
  const format = (value) => {
    const seconds = Math.floor(Math.max(0, value));
    return seconds >= 3600
      ? Math.floor(seconds / 3600) +
          "h " +
          Math.floor((seconds % 3600) / 60) +
          "m"
      : Math.floor(seconds / 60) + "m " + (seconds % 60) + "s";
  };
  function revealSelection() {
    if (!selected || selected.hidden) return;
    const viewport = matrix.parentElement;
    const top = selected.offsetTop;
    const bottom = top + selected.offsetHeight;
    const header = matrix.querySelector(".matrix-axis").offsetHeight;
    if (top < viewport.scrollTop + header)
      viewport.scrollTop = Math.max(0, top - header);
    else if (bottom > viewport.scrollTop + viewport.clientHeight)
      viewport.scrollTop = bottom - viewport.clientHeight;
  }
  function select(row, updateUrl = true) {
    selected = row;
    rows.forEach((item) =>
      item.setAttribute("aria-expanded", String(item === row)),
    );
    details.forEach((detail) => {
      detail.open = !!row && detail.id === row.dataset.job;
    });
    inspectorEmpty.hidden = !!row;
    document.querySelector("#focus-job").disabled =
      !row || Number(row.dataset.duration) <= 0;
    document.querySelector("#inspector-content").scrollTop = 0;
    if (row && updateUrl && history.replaceState)
      history.replaceState(null, "", "#" + row.dataset.job);
    revealSelection();
  }
  function filter() {
    const text = query.value.toLowerCase().trim();
    rows.forEach((row) => {
      row.hidden =
        (outcome && row.dataset.status !== outcome) ||
        !row.dataset.search.includes(text);
    });
    const visible = rows.filter((row) => !row.hidden);
    counter.textContent = visible.length + " of " + rows.length + " jobs";
    empty.hidden = visible.length !== 0;
    if (!selected || selected.hidden) select(visible[0] || null, initialized);
    else revealSelection();
    facets.forEach((button) =>
      button.setAttribute(
        "aria-pressed",
        String(button.dataset.outcome === outcome),
      ),
    );
  }
  function setWindow(start, end) {
    windowStart = Math.max(0, start);
    windowEnd = Math.min(fullSpan, Math.max(windowStart + 1, end));
    const span = windowEnd - windowStart;
    matrix.querySelectorAll("[data-span-start]").forEach((segment) => {
      const left = Math.max(windowStart, Number(segment.dataset.spanStart));
      const right = Math.min(windowEnd, Number(segment.dataset.spanEnd));
      segment.hidden = right <= left;
      segment.style.left =
        Math.max(0, (100 * (left - windowStart)) / span) + "%";
      segment.style.width = Math.max(0, (100 * (right - left)) / span) + "%";
    });
    matrix.querySelectorAll(".matrix-ticks span").forEach((tick, index) => {
      tick.textContent = format(windowStart + (span * index) / 4);
    });
    document.querySelector("#window-label").textContent =
      start === 0 && end === fullSpan
        ? "Full run"
        : format(windowStart) + " – " + format(windowEnd);
    document.querySelector("#reset-window").disabled =
      start === 0 && end === fullSpan;
  }
  rows.forEach((row) => {
    row.addEventListener("click", () => select(row));
    row.addEventListener("keydown", (event) => {
      const visible = [...matrix.querySelectorAll("button[data-job]")].filter(
        (item) => !item.hidden,
      );
      const index = visible.indexOf(row);
      let next = null;
      if (event.key === "ArrowDown")
        next = visible[Math.min(visible.length - 1, index + 1)];
      if (event.key === "ArrowUp") next = visible[Math.max(0, index - 1)];
      if (event.key === "Home") next = visible[0];
      if (event.key === "End") next = visible[visible.length - 1];
      if (next) {
        event.preventDefault();
        next.focus();
        select(next);
      }
    });
  });
  details.forEach((detail) => {
    detail
      .querySelector("summary")
      .addEventListener("click", (event) => event.preventDefault());
    const tabs = [...detail.querySelectorAll("[role=tab]")];
    function activate(tab) {
      tabs.forEach((item) => {
        const active = item === tab;
        item.setAttribute("aria-selected", String(active));
        item.tabIndex = active ? 0 : -1;
        document.getElementById(item.getAttribute("aria-controls")).hidden =
          !active;
      });
    }
    tabs.forEach((tab, index) => {
      tab.addEventListener("click", () => activate(tab));
      tab.addEventListener("keydown", (event) => {
        const next =
          event.key === "ArrowRight"
            ? tabs[(index + 1) % tabs.length]
            : event.key === "ArrowLeft"
              ? tabs[(index + tabs.length - 1) % tabs.length]
              : null;
        if (next) {
          event.preventDefault();
          activate(next);
          next.focus();
        }
      });
    });
    if (tabs.length) activate(tabs[0]);
  });
  facets.forEach((button) =>
    button.addEventListener("click", () => {
      outcome = button.dataset.outcome;
      filter();
    }),
  );
  query.addEventListener("input", filter);
  document.querySelector("#clear-job-filters").addEventListener("click", () => {
    query.value = "";
    outcome = "";
    filter();
    query.focus();
  });
  document.querySelector("#job-sort").addEventListener("change", (event) => {
    const key = event.target.value;
    const sorted = [...rows].sort((a, b) =>
      key === "duration"
        ? Number(b.dataset.duration) - Number(a.dataset.duration)
        : key === "name"
          ? a.dataset.search.localeCompare(b.dataset.search)
          : key === "status"
            ? a.dataset.status.localeCompare(b.dataset.status)
            : Number(a.dataset.start) - Number(b.dataset.start),
    );
    sorted.forEach((row) => matrix.append(row));
    revealSelection();
  });
  document.querySelector("#job-sort").dispatchEvent(new Event("change"));
  document.querySelector("#focus-job").addEventListener("click", () => {
    if (selected) {
      const start = Number(selected.dataset.start);
      const end = start + Number(selected.dataset.duration);
      const padding = Math.max(1, (end - start) * 0.025);
      setWindow(start - padding, end + padding);
    }
  });
  document
    .querySelector("#reset-window")
    .addEventListener("click", () => setWindow(0, fullSpan));
  document.querySelector("#longest-job").addEventListener("click", () => {
    const longest = [...rows].sort(
      (a, b) => Number(b.dataset.duration) - Number(a.dataset.duration),
    )[0];
    if (longest) {
      outcome = "";
      query.value = "";
      filter();
      select(longest);
      longest.focus({ preventScroll: true });
    }
  });
  document.addEventListener("keydown", (event) => {
    if (
      event.key === "/" &&
      !event.ctrlKey &&
      !event.metaKey &&
      !event.altKey &&
      !["INPUT", "TEXTAREA", "SELECT"].includes(document.activeElement.tagName)
    ) {
      event.preventDefault();
      query.focus();
    }
    if (event.key === "Escape" && document.activeElement === query) {
      query.value = "";
      filter();
    }
  });
  window.addEventListener("hashchange", () => {
    const row = rows.find((item) => "#" + item.dataset.job === location.hash);
    if (row) {
      outcome = "";
      query.value = "";
      filter();
      select(row, false);
    }
  });
  filter();
  const initial =
    rows.find((item) => "#" + item.dataset.job === location.hash) ||
    [...rows].sort(
      (a, b) => Number(b.dataset.duration) - Number(a.dataset.duration),
    )[0];
  if (initial) select(initial, false);
  initialized = true;
  setWindow(0, fullSpan);
})();
"""


def page(title, body, root="./"):
    digest = base64.b64encode(hashlib.sha256(FILTER.encode()).digest()).decode()
    policy = f"default-src 'none'; img-src data:; style-src 'unsafe-inline'; script-src 'sha256-{digest}'; base-uri 'none'; form-action 'none'"
    return (
        '<!doctype html><html lang="en"><head><meta charset="utf-8"><link rel="icon" href="data:,">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        f'<meta http-equiv="Content-Security-Policy" content="{escape(policy)}">'
        f'<title>{escape(title)} · nix-overlays builds</title><style>{STYLE}</style></head><body>'
        '<header class="masthead">'
        f'<a class="masthead-brand" href="{escape(root)}"><span class="brand-mark" aria-hidden="true">n</span>nix-overlays <span class="masthead-subtitle">/ Build explorer</span></a>'
        f'<nav><a href="{escape(root)}">All runs</a><a href="https://github.com/nix-ocaml/nix-overlays/actions/workflows/pipeline.yml">GitHub Actions ↗</a></nav></header><main>'
        f'<h1>{escape(title)}</h1>{body}'
        '<footer>Reports are indexed by the source commit reported by GitHub. Package explorers also retain the evaluated checkout SHA, which may be a PR merge commit. Raw logs remain in the Actions artifacts.</footer>'
        f'</main><script>{FILTER}</script></body></html>\n'
    )


def badge(status):
    status = str(status or "unknown")
    category = status if status in {"success", "failure", "failed", "error", "timed_out", "cancelled", "skipped"} else "unknown"
    return f'<span class="badge {category}">{escape(status)}</span>'


def write_page(site, path, title, body):
    destination = site / path / "index.html"
    destination.parent.mkdir(parents=True, exist_ok=True)
    root = "../" * len(PurePosixPath(path).parts) if path else "./"
    destination.write_text(page(title, body, root))


def report_counts(snapshot):
    counts = collections.Counter()
    for job in snapshot.get("jobs", []):
        if isinstance(job, dict):
            state = job.get("state")
            counts[state if state in ("built", "cached", "failed", "blocked", "cancelled", "submitted", "queued") else "unknown"] += 1
    return dict(counts)


def render_artifact(api, artifact, run, renderer, site):
    identifier = positive(artifact["id"])
    report = {"id": identifier, "name": artifact["name"], "counts": {}, "status": "unavailable"}
    destination = site / run_path(run) / "jobs" / str(identifier)
    destination.mkdir(parents=True, exist_ok=True)
    try:
        if artifact.get("expired"):
            raise ValueError("the Actions artifact has expired")
        if artifact["size_in_bytes"] > MAX_ARTIFACT_BYTES:
            raise ValueError("the Actions artifact exceeds the download limit")
        data = api.request(f"actions/artifacts/{identifier}/zip", binary=True, limit=MAX_ARTIFACT_BYTES)
        snapshot, events, notes = artifact_data(data)
        if notes:
            warnings = snapshot.get("warnings")
            snapshot["warnings"] = (warnings if isinstance(warnings, list) else []) + notes
            report["note"] = " ".join(notes)
        context = snapshot.get("context")
        if not isinstance(context, dict):
            context = {}
            snapshot["context"] = context
        context["artifactUrl"] = f"https://github.com/{api.repository}/actions/runs/{run['id']}/artifacts/{identifier}"
        context["logsAvailable"] = False
        context["runUrl"] = f"https://github.com/{api.repository}/actions/runs/{run['id']}"
        context["runAttempt"] = str(run["attempt"])
        with tempfile.TemporaryDirectory(prefix="nix-build-report-") as directory:
            directory = Path(directory)
            (directory / "results.json").write_text(json.dumps(snapshot, allow_nan=False))
            (directory / "events.jsonl").write_text("".join(json.dumps(event, allow_nan=False) + "\n" for event in events))
            environment = {k: v for k, v in os.environ.items() if k not in {"GH_TOKEN", "GITHUB_TOKEN"}}
            rendered = subprocess.run(
                [str(renderer), "--render-report", str(directory)],
                stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, env=environment, timeout=90,
            )
            if rendered.returncode:
                raise ValueError("the trusted renderer could not render this report")
            output = directory / "report.html"
            if output.is_symlink() or not output.is_file() or output.stat().st_size > MAX_REPORT_BYTES:
                raise ValueError("the rendered report exceeds the size limit or is missing")
            shutil.copyfile(output, destination / "index.html")
        report.update(status=str(snapshot.get("status", "unknown"))[:80], counts=report_counts(snapshot),
                      flake=str(context.get("flake", ""))[:1000], gitSha=str(context.get("gitSha", ""))[:80])
    except (ValueError, OSError, subprocess.TimeoutExpired, zipfile.BadZipFile) as error:
        report["error"] = str(error)[:500]
        (destination / "index.html").write_text(page(
            "Report unavailable", f'<p>{escape(report["error"])}</p><p><a href="../../">Back to the run</a></p>', "../../../../../"
        ))
    return report


def load_run(api, run_id, attempt):
    data = api.request(f"actions/runs/{positive(run_id)}/attempts/{positive(attempt)}")
    if data.get("path") != ".github/workflows/pipeline.yml" or data.get("repository", {}).get("full_name") != api.repository:
        raise ValueError("the selected run is not this repository's Pipeline")
    if data.get("status") != "completed" or data.get("run_attempt") != attempt:
        raise ValueError("the selected run attempt has not completed")
    if not SHA.fullmatch(data["head_sha"]):
        raise ValueError("invalid source commit")
    pulls = [positive(pr["number"]) for pr in data.get("pull_requests", [])]
    # GitHub omits pull_requests for some fork workflows. Resolve from the
    # authoritative commit API, never from artifact-supplied PR numbers.
    if not pulls and data.get("event") == "pull_request":
        related = api.pages(f"commits/{data['head_sha']}/pulls", None)
        pulls = [positive(pr["number"]) for pr in related if pr.get("base", {}).get("repo", {}).get("full_name") == api.repository]
    run = {
        "id": positive(run_id), "attempt": positive(attempt), "number": data["run_number"],
        "headSha": data["head_sha"], "headBranch": data.get("head_branch") or "detached",
        "headRepository": (data.get("head_repository") or {}).get("full_name") or api.repository,
        "pullRequests": sorted(set(pulls)), "event": data.get("event"),
        "conclusion": data.get("conclusion"), "startedAt": data.get("run_started_at") or data["created_at"],
        "updatedAt": data["updated_at"], "reports": [],
    }
    jobs = api.pages(f"actions/runs/{run_id}/attempts/{attempt}/jobs", "jobs")
    run["jobs"] = [{key: job.get(key) for key in ("id", "name", "status", "conclusion", "started_at", "completed_at", "steps")} for job in jobs]
    return run


def run_rows(runs, prefix=""):
    rows = []
    for run in runs:
        prs = ", ".join(f'PR #{pr}' for pr in run["pullRequests"])
        rows.append(
            f'<tr><td><a href="{prefix}{run_path(run)}/">Run #{escape(run["number"])} · attempt {run["attempt"]}</a>'
            f'<div class="muted">{escape(run["startedAt"])}</div></td><td>{badge(run["conclusion"])}</td>'
            f'<td>{escape(run["headBranch"])}<div class="muted">{escape(prs or run["event"])}</div></td>'
            f'<td><code>{run["headSha"][:12]}</code></td><td>{len(run["reports"])} reports</td></tr>'
        )
    return '<div class="panel"><table><thead><tr><th>Run</th><th>Result</th><th>Branch / PR</th><th>Commit</th><th>Matrix</th></tr></thead><tbody data-filter>' + "".join(rows) + '</tbody></table></div>'


def step_phase(name):
    name = str(name).lower()
    if name.startswith("post "):
        return "other"
    if "checkout" in name:
        return "checkout"
    if "upload" in name:
        return "upload"
    if "build" in name and "report" not in name:
        return "build"
    if any(word in name for word in ("setup", "set up", "install", "nix-s3", "configure")):
        return "setup"
    return "other"


def timeline(run, repository):
    starts = [timestamp(job["started_at"]) for job in run["jobs"]]
    ends = [timestamp(job["completed_at"]) for job in run["jobs"]]
    starts.append(timestamp(run["startedAt"]))
    starts, ends = [x for x in starts if x is not None], [x for x in ends if x is not None]
    origin = min(starts, default=0)
    span = max(max(ends, default=origin) - origin, 1)
    blocks, rows = [], []
    outcomes = collections.Counter(str(job.get("conclusion") or "unknown") for job in run["jobs"])

    def segment(start, end, phase, label):
        start, end = timestamp(start), timestamp(end)
        if start is None or end is None or end <= start:
            return ""
        offset = max(0, min(100, 100 * (start - origin) / span))
        width = max(0, min(100 - offset, 100 * (end - start) / span))
        return (f'<span class="matrix-span phase-{phase}" style="left:{offset:.3f}%;width:{width:.3f}%" '
                f'data-span-start="{start - origin:.3f}" data-span-end="{end - origin:.3f}" title="{escape(label)}"></span>')

    for job in run["jobs"]:
        seconds = duration(job["started_at"], job["completed_at"])
        offset = max(0, (timestamp(job["started_at"]) or origin) - origin)
        identifier = f'job-{positive(job["id"])}'
        conclusion = str(job.get("conclusion") or "unknown")
        category = conclusion if conclusion in {"success", "failure", "failed", "timed_out", "cancelled", "skipped"} else "unknown"
        search = str(job["name"]) + " " + " ".join(str(step.get("name", "")) for step in job.get("steps") or [])
        steps, spans = [], [segment(job["started_at"], job["completed_at"], "job", job["name"])]
        for step in job.get("steps") or []:
            step_time = duration(step.get("started_at"), step.get("completed_at"))
            name = step.get("name", "Step")
            phase = step_phase(name)
            proportion = min(100, 100 * (step_time or 0) / max(seconds or 0, 1))
            steps.append(
                f'<div class="step-item"><div class="step-top"><span class="step-name">{escape(name)}</span>'
                f'<span class="step-duration">{elapsed(step_time)}</span></div><div class="step-bottom">{badge(step.get("conclusion"))}'
                f'<span class="step-track" aria-hidden="true"><span class="step-bar phase-{phase}" style="width:{proportion:.3f}%"></span></span></div></div>'
            )
            spans.append(segment(step.get("started_at"), step.get("completed_at"), phase, f'{name} · {elapsed(step_time)}'))
        rows.append(
            f'<button class="matrix-row" data-job="{identifier}" data-status="{escape(conclusion)}" data-search="{escape(search.lower())}" '
            f'data-start="{offset:.3f}" data-duration="{seconds or 0:.3f}" aria-controls="{identifier}" aria-expanded="false" '
            f'aria-label="{escape(job["name"])} · {escape(conclusion)} · {elapsed(seconds)}" title="{escape(job["name"])} · {escape(conclusion)}">'
            f'<span class="matrix-label"><span class="status-dot {category}" aria-hidden="true"></span><span class="matrix-label-name">{escape(job["name"])}</span></span>'
            f'<span class="matrix-track" aria-hidden="true">{"".join(spans)}</span><span class="matrix-duration">{elapsed(seconds)}</span></button>'
        )
        link = f'https://github.com/{repository}/actions/runs/{run["id"]}/job/{positive(job["id"])}'
        metadata = (
            f'<dl class="job-metadata"><dt>Job ID</dt><dd><code>{positive(job["id"])}</code></dd>'
            f'<dt>Started</dt><dd>{escape(job.get("started_at") or "Unknown")}</dd>'
            f'<dt>Finished</dt><dd>{escape(job.get("completed_at") or "Unknown")}</dd>'
            f'<dt>Run offset</dt><dd>+{elapsed(offset)}</dd><dt>Duration</dt><dd>{elapsed(seconds)}</dd>'
            f'<dt>Result</dt><dd>{badge(conclusion)}</dd></dl>'
        )
        blocks.append(
            f'<details class="job-details" id="{identifier}"><summary>{badge(conclusion)}<strong>{escape(job["name"])}</strong><span class="muted">{elapsed(seconds)}</span></summary>'
            f'<div class="job-detail-body"><p><a href="{link}">Open Actions job ↗</a></p>'
            f'<div class="job-tabs" role="tablist" aria-label="Job details">'
            f'<button id="{identifier}-steps-tab" role="tab" aria-controls="{identifier}-steps" aria-selected="true">Steps ({len(steps)})</button>'
            f'<button id="{identifier}-metadata-tab" role="tab" aria-controls="{identifier}-metadata" aria-selected="false" tabindex="-1">Metadata</button></div>'
            f'<div class="job-tab-panel" id="{identifier}-steps" role="tabpanel" aria-labelledby="{identifier}-steps-tab">'
            + ("".join(steps) if steps else '<p class="muted">No step timings were recorded.</p>')
            + f'</div><div class="job-tab-panel" id="{identifier}-metadata" role="tabpanel" aria-labelledby="{identifier}-metadata-tab">{metadata}</div></div></details>'
        )
    ticks = ''.join(f'<span style="left:{number * 25}%">{elapsed(span * number / 4)}</span>' for number in range(5))
    legend = ''.join(f'<span><i class="phase-{phase}"></i>{label}</span>' for phase, label in (("checkout", "Checkout"), ("setup", "Setup"), ("build", "Build"), ("upload", "Upload"), ("other", "Other")))
    facets = f'<button class="facet-button" data-outcome="" aria-pressed="true"><span>All jobs</span><span class="facet-count">{len(rows)}</span></button>'
    facets += ''.join(
        f'<button class="facet-button" data-outcome="{escape(status)}" aria-pressed="false"><span>{escape(status.replace("_", " ").capitalize())}</span><span class="facet-count">{count}</span></button>'
        for status, count in sorted(outcomes.items())
    )
    chart = f'<div class="matrix" id="matrix" data-span="{span:.3f}"><div class="matrix-axis"><span>Job</span><span class="matrix-ticks">{ticks}</span><span>Duration</span></div>' + ''.join(rows) + '</div>'
    return (
        '<div class="section-heading"><h2>Pipeline timeline</h2><span class="muted">Actions jobs · one shared time axis</span></div>'
        '<div class="explorer" id="pipeline-explorer"><aside class="facets" aria-label="Filter jobs by result"><p class="facet-heading">Result</p>'
        f'{facets}<p class="facet-note">Each row is an Actions job. Select a job to inspect its steps.<br><br><button class="inline-button" id="longest-job">Inspect longest job</button></p></aside>'
        '<section class="waterfall" aria-label="Job waterfall"><div class="explorer-toolbar"><label class="query-wrap"><span class="screen-reader">Search jobs or steps</span>'
        '<input type="search" id="job-search" placeholder="Search jobs or steps…" autocomplete="off"><kbd class="search-shortcut">/</kbd></label>'
        '<button id="clear-job-filters" title="Clear search and result filters">Reset</button></div>'
        f'<div class="waterfall-toolbar"><span id="job-count" aria-live="polite">{len(rows)} jobs</span><label>Sort <select id="job-sort"><option value="start">Start time</option><option value="duration">Longest first</option><option value="name">Job name</option><option value="status">Result</option></select></label>'
        '<div class="waterfall-actions"><span id="window-label">Full run</span><button id="focus-job">Focus selected</button><button id="reset-window" disabled>Full run</button></div></div>'
        f'<div class="matrix-scroll">{chart}<p class="empty-state" id="job-empty" hidden>No jobs match these filters.</p></div><div class="legend">{legend}</div></section>'
        '<aside class="inspector" aria-label="Selected job"><div class="inspector-header"><h2>Actions step details</h2><span>Job inspector</span></div>'
        '<div class="inspector-content" id="inspector-content"><p class="empty-state" id="inspector-empty" hidden>Select a job to inspect its steps.</p>'
        + "".join(blocks) + '</div></aside></div>'
        '<p class="toolbar-note">Build includes tool bootstrap. Open a package report below for derivation activity, dependencies and logs. Use ↑ / ↓ to move between jobs.</p>'
    )


def render_indexes(site, catalog):
    runs, repository = catalog["runs"], catalog["repository"]
    # Aliases are rebuilt from the retained catalog, so pruning cannot leave
    # links pointing at deleted runs or let an older run overwrite a newer alias.
    for name in ("branches", "pulls", "commits"):
        shutil.rmtree(site / name, ignore_errors=True)
    groups = collections.defaultdict(list)
    for run in runs:
        groups["commits/" + run["headSha"]].append(run)
        groups[branch_path(run)].append(run)
        groups[f'runs/{run["id"]}'].append(run)
        for pr in run["pullRequests"]:
            groups[f"pulls/{positive(pr)}"].append(run)
        path = run_path(run)
        navigation = (
            f'<a href="../../../{branch_path(run)}/">Branch: {escape(run["headBranch"])}</a>'
            f'<a href="../../../commits/{run["headSha"]}/">Commit: {run["headSha"][:12]}</a>'
            + "".join(f'<a href="../../../pulls/{pr}/">PR #{pr}</a>' for pr in run["pullRequests"])
            + f'<a href="https://github.com/{repository}/actions/runs/{run["id"]}/attempts/{run["attempt"]}">Actions run</a>'
        )
        aggregate = collections.Counter()
        rows = []
        for report in run["reports"]:
            aggregate.update(report["counts"])
            count = report["counts"]
            label = report.get("flake") or report["name"].removeprefix("nix-ci-build-").rsplit("-attempt-", 1)[0]
            rows.append(
                f'<tr><td><a href="jobs/{report["id"]}/">{escape(label)}</a>'
                + (f'<div class="muted">{escape(report["error"])}</div>' if report.get("error") else "")
                + (f'<div class="muted">{escape(report["note"])}</div>' if report.get("note") else "")
                + f'</td><td>{badge(report["status"])}</td><td>{count.get("built", 0)}</td><td>{count.get("cached", 0)}</td><td>{count.get("failed", 0) + count.get("blocked", 0)}</td>'
                f'<td><a href="https://github.com/{repository}/actions/runs/{run["id"]}/artifacts/{report["id"]}">Raw artifact</a></td></tr>'
            )
        job_ends = [timestamp(job.get("completed_at")) for job in run["jobs"]]
        job_ends = [value for value in job_ends if value is not None]
        run_start = timestamp(run["startedAt"])
        wall_time = max(job_ends) - run_start if job_ends and run_start is not None else None
        facts = f'<div><strong>{elapsed(wall_time)}</strong>Pipeline wall time</div><div><strong>{len(run["jobs"])}</strong>Actions jobs</div>'
        facts += ''.join(f'<div><strong>{aggregate.get(key, 0):,}</strong>{label}</div>' for key, label in (("built", "Built roots"), ("cached", "Cached roots"), ("failed", "Failed roots"), ("blocked", "Blocked roots")))
        no_reports = '<p class="notice">No package reports were uploaded for this attempt. Check the Actions jobs below for setup failures or cancellation.</p>' if not rows else ""
        body = f'<nav class="run-nav">{navigation}</nav><p class="run-meta">{badge(run["conclusion"])}<span>{escape(run["startedAt"])}</span><span>{escape(run["headRepository"])}</span></p><div class="panel facts">{facts}</div>{no_reports}'
        body += "".join(f'<p class="notice">{escape(note)}</p>' for note in run.get("notes", []))
        body += timeline(run, repository)
        body += f'<div class="section-heading"><h2>Package reports <span class="index-count" id="index-count">{len(rows)}</span></h2><label class="table-search">Filter <input id="search" type="search" placeholder="Compiler, platform or target"></label></div><div class="panel"><table><thead><tr><th>Target</th><th>Result</th><th>Built</th><th>Cached</th><th>Failed / blocked</th><th>Logs</th></tr></thead><tbody data-filter>' + "".join(rows) + '</tbody></table></div>'
        write_page(site, path, f'Run #{run["number"]} · attempt {run["attempt"]}', body)
    for path, selected in groups.items():
        first = selected[0]
        if path.startswith("branches/"):
            title = first["headRepository"] + " · " + first["headBranch"]
        elif path.startswith("commits/"):
            title = "Commit " + first["headSha"]
        elif path.startswith("pulls/"):
            title = "Pull request #" + path.split("/")[-1]
        else:
            title = "Run #" + str(first["number"]) + " · attempts"
        prefix = "../" * len(PurePosixPath(path).parts)
        write_page(site, path, title, run_rows(selected, prefix))
    body = '<p>Package builds across OCaml compilers, platforms and cross targets. Select a run to explore the matrix and package activity timelines.</p><label>Find a run <input id="search" type="search" placeholder="PR number, branch or commit"></label>'
    body += run_rows(runs)
    body += '<p>The archive retains up to 20 recent attempts within a 400 MiB budget. Older reports remain downloadable from Actions while their artifacts are retained.</p>'
    write_page(site, "", "Build explorer", body)
    (site / ".nojekyll").touch()
    (site / "catalog.json").write_text(json.dumps(catalog, indent=2, allow_nan=False) + "\n")


def tree_size(directory):
    return sum(path.stat().st_size for path in directory.rglob("*") if path.is_file())


def prune(site, catalog, max_runs, max_bytes, keep=None):
    catalog["runs"].sort(key=lambda run: (run["startedAt"], run["id"], run["attempt"]), reverse=True)
    while len(catalog["runs"]) > max_runs or (len(catalog["runs"]) > 1 and tree_size(site) > max_bytes):
        index = next((index for index in range(len(catalog["runs"]) - 1, -1, -1)
                      if (catalog["runs"][index]["id"], catalog["runs"][index]["attempt"]) != keep), None)
        if index is None:
            raise ValueError("the selected attempt exceeds the site budget")
        old = catalog["runs"].pop(index)
        shutil.rmtree(site / run_path(old), ignore_errors=True)
        parent = site / "runs" / str(old["id"])
        if not any(run["id"] == old["id"] for run in catalog["runs"]):
            shutil.rmtree(parent, ignore_errors=True)
    if tree_size(site) > max_bytes:
        raise ValueError("the latest attempt exceeds the site budget")


def catch_up(target, recent, known):
    candidates = [target]
    inspected = 0
    for run in recent:
        latest = run["run_attempt"] - (run["status"] != "completed")
        if latest > 0:
            for number in range(latest, 0, -1):
                inspected += 1
                key = (positive(run["id"]), number)
                if key not in known and key not in candidates:
                    candidates.append(key)
                if len(candidates) >= 5 or inspected >= 100:
                    return candidates
    return candidates


def build(args):
    api = GitHub(args.repository)
    site = Path(args.output)
    if site.exists() and any(site.iterdir()):
        raise ValueError("output directory must be empty")
    site.mkdir(parents=True, exist_ok=True)
    catalog, archive_sha = restore_archive(api, site)
    target = api.request(f"actions/runs/{positive(args.run_id)}")
    attempt = positive(args.attempt or target["run_attempt"])
    selected = (positive(args.run_id), attempt)
    candidates = [selected]
    known = {(run["id"], run["attempt"]) for run in catalog["runs"]}
    published = [tuple(key) for key in catalog.get("publishedAttempts", sorted(known))]
    previous = next((run for run in catalog["runs"] if (run["id"], run["attempt"]) == selected), None)
    if args.refresh and previous:
        catalog["runs"].remove(previous)
        known.remove(selected)
    # Actions concurrency can replace a pending publisher. Catch up completed
    # attempts on subsequent runs instead of relying on an unbounded queue.
    recent = api.request("actions/workflows/pipeline.yml/runs?per_page=20")["workflow_runs"]
    candidates = catch_up(selected, recent, known | set(published))
    for run_id, number in candidates[:5]:
        if (run_id, number) in known:
            continue
        run = load_run(api, run_id, number)
        artifacts = api.pages(f"actions/runs/{run_id}/artifacts", "artifacts")
        old_reports = {report["id"]: report for report in previous["reports"]} if previous and (run_id, number) == selected else {}
        matches = []
        for artifact in artifacts:
            match = ARTIFACT_NAME.fullmatch(artifact["name"])
            if match and int(match[1]) == number:
                matches.append(artifact)
        if len(matches) > 80:
            run["notes"] = ["Only the first 80 report artifacts are shown; this attempt exceeds the publisher's artifact limit."]
        for artifact in sorted(matches, key=lambda item: item["id"])[:80]:
            old = old_reports.pop(artifact["id"], None)
            if artifact.get("expired") and old and old["status"] != "unavailable":
                run["reports"].append(old)
            else:
                run["reports"].append(render_artifact(api, artifact, run, args.renderer, site))
        run["reports"].extend(old_reports.values())
        run["reports"].sort(key=lambda report: report["name"])
        catalog["runs"].append(run)
        known.add((run_id, number))
        published.append((run_id, number))
    catalog["publishedAttempts"] = list(dict.fromkeys(published))[-1000:]
    for name in ("branches", "pulls", "commits"):
        shutil.rmtree(site / name, ignore_errors=True)
    prune(site, catalog, args.max_runs, args.max_bytes, keep=selected)
    while True:
        render_indexes(site, catalog)
        if tree_size(site) <= args.max_bytes:
            break
        prune(site, catalog, len(catalog["runs"]) - 1, args.max_bytes, keep=selected)
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            output.write(f"archive_sha={archive_sha}\n")
    print(f"Prepared {len(catalog['runs'])} run attempts ({tree_size(site) // (1024 * 1024)} MiB)")


def archive_site(args):
    repository = GitHub(args.repository).repository
    if args.expected_sha and not SHA.fullmatch(args.expected_sha):
        raise ValueError("invalid previous archive SHA")
    source = Path(args.directory).resolve()
    if not (source / "catalog.json").is_file() or tree_size(source) > MAX_ARCHIVE_BYTES:
        raise ValueError("invalid generated site")
    with tempfile.TemporaryDirectory(prefix="nix-report-archive-") as temporary:
        directory = Path(temporary)
        shutil.copytree(source, directory, dirs_exist_ok=True)
        def git(*arguments):
            subprocess.run(["git", *arguments], cwd=directory, check=True, stdout=subprocess.DEVNULL)
        git("init", "--quiet", "--initial-branch=" + ARCHIVE_BRANCH)
        git("config", "user.name", "github-actions[bot]")
        git("config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
        git("add", ".")
        git("commit", "--quiet", "-m", "Update generated build reports")
        git("remote", "add", "origin", "https://github.com/" + repository + ".git")
        # This branch is generated storage, deliberately a single snapshot.
        # The lease prevents overwriting an unexpected concurrent/manual update.
        git("push", "--force-with-lease=refs/heads/" + ARCHIVE_BRANCH + ":" + args.expected_sha,
            "origin", "HEAD:refs/heads/" + ARCHIVE_BRANCH)


def check_pages(args):
    config = GitHub(args.repository).request("pages", missing=True)
    enabled = config is not None and config.get("build_type") == "workflow"
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            output.write(f"enabled={'true' if enabled else 'false'}\n")
    print("GitHub Pages is ready" if enabled else "Report publishing is skipped: select GitHub Actions in Settings > Pages to enable it.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    prepare = commands.add_parser("build")
    prepare.add_argument("--repository", required=True)
    prepare.add_argument("--run-id", type=positive, required=True)
    prepare.add_argument("--attempt", type=positive)
    prepare.add_argument("--renderer", type=Path, required=True)
    prepare.add_argument("--output", required=True)
    prepare.add_argument("--max-runs", type=positive, default=20)
    prepare.add_argument("--max-bytes", type=positive, default=400 * 1024 * 1024)
    prepare.add_argument("--refresh", action="store_true", help="regenerate the selected attempt, retaining existing pages if its artifacts expired")
    save = commands.add_parser("archive")
    save.add_argument("--repository", required=True)
    save.add_argument("--directory", required=True)
    save.add_argument("--expected-sha", default="")
    check = commands.add_parser("check-pages")
    check.add_argument("--repository", required=True)
    args = parser.parse_args()
    {"build": build, "archive": archive_site, "check-pages": check_pages}[args.command](args)


if __name__ == "__main__":
    main()
