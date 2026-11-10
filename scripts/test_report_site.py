import argparse
import io
import json
import os
from pathlib import Path
import stat
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import report_site as site


def zipped(files):
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
        for name, data in files.items():
            archive.writestr(name, data)
    return output.getvalue()


def snapshot(**extra):
    return {"schemaVersion": 1, "context": {"gitSha": "f" * 40},
            "status": "success", "jobs": [{"state": "cached"}, {"state": "built"}], **extra}


def run(identifier=10, attempt=1, branch="master", started="2026-11-10T10:00:00Z"):
    return {
        "id": identifier, "attempt": attempt, "number": identifier,
        "headSha": "a" * 40, "headBranch": branch, "headRepository": "nix-ocaml/nix-overlays",
        "pullRequests": [2797], "event": "pull_request", "conclusion": "success",
        "startedAt": started, "updatedAt": started, "reports": [], "jobs": [],
    }


class ReportDataTests(unittest.TestCase):
    def test_only_json_is_read(self):
        data = zipped({"results.json": json.dumps(snapshot()), "events.jsonl": '{"type":"job"}\n',
                       "report.html": '<script>fetch("https://evil.invalid")</script>',
                       "run.sh": "exit 1", "logs/untrusted.html": "<script>bad()</script>"})
        result, events, notes = site.artifact_data(data)
        self.assertEqual(result["status"], "success")
        self.assertEqual(events, [{"type": "job"}])
        self.assertEqual(notes, [])

    def test_truncated_final_event_preserves_earlier_events(self):
        data = zipped({"results.json": json.dumps(snapshot()), "events.jsonl": '{"type":"job"}\n{"type":'})
        _, events, notes = site.artifact_data(data)
        self.assertEqual(events, [{"type": "job"}])
        self.assertIn("incomplete", notes[0])
        with self.assertRaises(ValueError):
            site.artifact_data(zipped({"results.json": json.dumps(snapshot()), "events.jsonl": 'broken\n{"type":"job"}\n'}))

    def test_path_traversal_is_rejected(self):
        for path in ("../results.json", "/results.json", "logs/../../owned", "logs\\owned"):
            with self.subTest(path=path), self.assertRaises(ValueError):
                site.artifact_data(zipped({"results.json": json.dumps(snapshot()), path: "bad"}))

    def test_symlink_and_duplicate_data_are_rejected(self):
        for duplicate in (False, True):
            with self.subTest(duplicate=duplicate):
                buffer = io.BytesIO()
                with zipfile.ZipFile(buffer, "w") as archive:
                    info = zipfile.ZipInfo("results.json")
                    info.external_attr = (stat.S_IFLNK | 0o777) << 16 if not duplicate else 0
                    archive.writestr(info, json.dumps(snapshot()))
                    if duplicate:
                        import warnings
                        with warnings.catch_warnings():
                            warnings.simplefilter("ignore", UserWarning)
                            archive.writestr("results.json", json.dumps(snapshot()))
                with self.assertRaises(ValueError):
                    site.artifact_data(buffer.getvalue())

    def test_size_and_json_schema_limits(self):
        with patch.object(site, "MAX_DATA_BYTES", 10), self.assertRaises(ValueError):
            site.artifact_data(zipped({"results.json": json.dumps(snapshot())}))
        for content in ('[]', '{"schemaVersion":2}', '{"schemaVersion":1,"jobs":{}}',
                        '{"schemaVersion":1,"elapsed":NaN}'):
            with self.subTest(content=content), self.assertRaises(ValueError):
                site.artifact_data(zipped({"results.json": content}))
        with self.assertRaises(ValueError):
            site.artifact_data(zipped({"results.json": json.dumps(snapshot()), "events.jsonl": '[]\n'}))


class ArchiveTests(unittest.TestCase):
    def test_restore_preserves_report(self):
        catalog = {"version": 1, "repository": "nix-ocaml/nix-overlays", "runs": [run()]}
        class API:
            repository = "nix-ocaml/nix-overlays"
            def request(self, path, **_):
                if path.startswith("git/"):
                    return {"object": {"sha": "b" * 40}}
                return zipped({"repo-hash/catalog.json": json.dumps(catalog),
                               "repo-hash/runs/10/1/jobs/20/index.html": "trusted old report"})
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            restored, revision = site.restore_archive(API(), root)
            self.assertEqual(restored, catalog)
            self.assertEqual(revision, "b" * 40)
            self.assertEqual((root / "runs/10/1/jobs/20/index.html").read_text(), "trusted old report")

    def test_prune_and_aliases_keep_newest_attempts(self):
        old = run(identifier=10, attempt=1)
        new = run(identifier=10, attempt=2, started="2026-11-10T11:00:00Z")
        other = run(identifier=11, branch="feature/new", started="2026-11-10T12:00:00Z")
        catalog = {"version": 1, "repository": "nix-ocaml/nix-overlays", "runs": [old, other, new]}
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for item in catalog["runs"]:
                path = root / site.run_path(item) / "jobs/20"
                path.mkdir(parents=True)
                (path / "index.html").write_text("immutable package report")
            site.render_indexes(root, catalog)
            site.prune(root, catalog, 2, 1024 * 1024)
            site.render_indexes(root, catalog)
            self.assertEqual([(r["id"], r["attempt"]) for r in catalog["runs"]], [(11, 1), (10, 2)])
            self.assertFalse((root / "runs/10/1").exists())
            self.assertEqual((root / "runs/10/2/jobs/20/index.html").read_text(), "immutable package report")
            self.assertIn("attempt 2", (root / "runs/10/index.html").read_text())
            self.assertNotIn("attempt 1", (root / "runs/10/index.html").read_text())
            self.assertIn("Run #11", (root / "pulls/2797/index.html").read_text())
            self.assertTrue((root / "commits" / ("a" * 40) / "index.html").exists())

    def test_byte_budget_drops_old_reports(self):
        catalog = {"runs": [run(), run(11, started="2026-11-10T11:00:00Z")]}
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for item in catalog["runs"]:
                path = root / site.run_path(item)
                path.mkdir(parents=True)
                (path / "large.html").write_text("x" * 100)
            site.prune(root, catalog, 20, 150)
            self.assertEqual([r["id"] for r in catalog["runs"]], [11])
            self.assertLessEqual(site.tree_size(root), 150)
            with self.assertRaises(ValueError):
                site.prune(root, catalog, 20, 50)

    def test_branch_labels_cannot_escape_site_or_collide(self):
        self.assertNotEqual(site.branch_path(run(branch="feature/a")), site.branch_path(run(branch="feature-a")))
        path = site.branch_path(run(branch="../../<script>alert('x')</script>"))
        self.assertNotIn("..", path)
        self.assertNotIn("<", path)

    def test_explicitly_recovered_attempt_survives_pruning(self):
        catalog = {"runs": [run(), run(11, started="2026-11-10T11:00:00Z")]}
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for item in catalog["runs"]:
                path = root / site.run_path(item)
                path.mkdir(parents=True)
                (path / "index.html").write_text("report")
            site.prune(root, catalog, 1, 100, keep=(10, 1))
            self.assertEqual([r["id"] for r in catalog["runs"]], [10])
            with self.assertRaises(ValueError):
                site.prune(root, catalog, 0, 1, keep=(10, 1))

    def test_catch_up_recovers_an_older_skipped_attempt(self):
        recent = [{"id": 10, "run_attempt": 5, "status": "completed", "created_at": "2026-11-10T10:00:00Z"}]
        selected = site.catch_up((11, 1), recent, {(10, 1), (10, 3), (10, 4), (10, 5)})
        self.assertEqual(selected, [(11, 1), (10, 2)])
        self.assertEqual(site.catch_up((11, 1), recent, {(10, n) for n in range(1, 6)}), [(11, 1)])

    def test_catch_up_respects_global_work_limit(self):
        recent = [{"id": 10, "run_attempt": 200, "status": "completed", "created_at": "2026-11-10T10:00:00Z"}]
        self.assertEqual(len(site.catch_up((11, 1), recent, set())), 5)

    def test_first_publication_catches_up_earlier_pending_runs(self):
        class API:
            repository = "nix-ocaml/nix-overlays"
            def request(self, endpoint, **_):
                if endpoint.startswith("git/"):
                    return None
                if endpoint.startswith("actions/workflows/"):
                    return {"workflow_runs": [{"id": 10, "run_attempt": 1, "status": "completed"}]}
                return {"run_attempt": 1}
            def pages(self, *_):
                return []
        with tempfile.TemporaryDirectory() as temporary, patch.object(site, "GitHub", return_value=API()), patch.object(site, "load_run", side_effect=lambda _, identifier, attempt: run(identifier, attempt)):
            args = argparse.Namespace(repository=API.repository, output=temporary, run_id=11,
                                      attempt=None, refresh=False, renderer=Path("/trusted/renderer"),
                                      max_runs=20, max_bytes=1024 * 1024)
            with patch.dict(os.environ, {"GITHUB_OUTPUT": ""}):
                site.build(args)
            catalog = json.loads((Path(temporary) / "catalog.json").read_text())
            self.assertEqual({item["id"] for item in catalog["runs"]}, {10, 11})


class RenderingTests(unittest.TestCase):
    def test_pipeline_timeline_aligns_parallel_jobs_and_step_phases(self):
        item = run()
        item["jobs"] = [
            {"id": 40, "name": "First target", "conclusion": "success",
             "started_at": "2026-11-10T10:00:00Z", "completed_at": "2026-11-10T10:02:00Z",
             "steps": [{"name": "Build packages", "started_at": "2026-11-10T10:00:30Z", "completed_at": "2026-11-10T10:01:30Z"}]},
            {"id": 41, "name": "Second target", "conclusion": "success",
             "started_at": "2026-11-10T10:01:00Z", "completed_at": "2026-11-10T10:02:00Z",
             "steps": [{"name": "Upload build report", "started_at": "2026-11-10T10:01:30Z", "completed_at": "2026-11-10T10:02:00Z"}]},
        ]
        text = site.timeline(item, "nix-ocaml/nix-overlays")
        chart, details = text.split('<h2>Actions step details</h2>')
        self.assertNotIn("<details", chart)
        self.assertEqual(chart.count('class="matrix-row"'), 2)
        self.assertIn('phase-build" style="left:25.000%;width:50.000%"', chart)
        self.assertIn('phase-upload" style="left:75.000%;width:25.000%"', chart)
        self.assertIn('aria-controls="job-41"', chart)
        self.assertIn('id="job-41"', details)
        self.assertIn("2m 0s", chart)

    def test_html_escapes_metadata_and_shows_steps(self):
        item = run(branch='<script>alert("branch")</script>')
        item["jobs"] = [{"id": 40, "name": '<img src=x onerror=alert("job")>', "conclusion": "failure",
                         "started_at": "2026-11-10T10:00:00Z", "completed_at": "2026-11-10T10:02:00Z",
                         "steps": [{"name": "Build <package>", "conclusion": "failure", "started_at": "2026-11-10T10:00:30Z", "completed_at": "2026-11-10T10:01:45Z"}]}]
        item["reports"] = [{"id": 50, "name": "nix-ci-build-test-attempt-1", "counts": {"cached": 1219, "built": 1}, "status": "success", "flake": "#hydraJobs.x86_64-linux.build_5_2"}]
        catalog = {"version": 1, "repository": "nix-ocaml/nix-overlays", "runs": [item]}
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            site.render_indexes(root, catalog)
            text = (root / "runs/10/1/index.html").read_text()
            self.assertNotIn('<script>alert("branch")</script>', text)
            self.assertNotIn("<img", text)
            self.assertIn("&lt;img", text)
            self.assertIn("1m 15s", text)
            self.assertIn("jobs/50/", text)
            self.assertIn("Content-Security-Policy", text)
            self.assertIn("1,219", text)

    def test_renderer_receives_only_data_and_authoritative_artifact_link(self):
        payload = zipped({"results.json": json.dumps(snapshot()), "events.jsonl": '{"type":"job"}\n', "report.html": "evil HTML", "run.sh": "exit 1"})
        class API:
            repository = "nix-ocaml/nix-overlays"
            def request(self, *_, **__):
                return payload
        artifact = {"id": 99, "name": "nix-ci-build-test-attempt-2", "size_in_bytes": len(payload), "expired": False}
        def renderer(arguments, **kwargs):
            self.assertEqual(arguments[:2], ["/trusted/bin/nix-ci-build", "--render-report"])
            directory = Path(arguments[2])
            self.assertEqual({path.name for path in directory.iterdir()}, {"results.json", "events.jsonl"})
            context = json.loads((directory / "results.json").read_text())["context"]
            self.assertEqual(context["gitSha"], "f" * 40)
            self.assertEqual(context["artifactUrl"], "https://github.com/nix-ocaml/nix-overlays/actions/runs/10/artifacts/99")
            self.assertEqual(context["runAttempt"], "2")
            self.assertFalse(context["logsAvailable"])
            self.assertNotIn("GH_TOKEN", kwargs["env"])
            self.assertNotIn("GITHUB_TOKEN", kwargs["env"])
            (directory / "report.html").write_text("trusted regenerated report")
            return argparse.Namespace(returncode=0)
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"GH_TOKEN": "secret", "GITHUB_TOKEN": "secret"}), patch.object(site.subprocess, "run", side_effect=renderer):
            root = Path(temporary)
            report = site.render_artifact(API(), artifact, run(attempt=2), Path("/trusted/bin/nix-ci-build"), root)
            self.assertEqual(report["counts"], {"built": 1, "cached": 1})
            self.assertEqual((root / "runs/10/2/jobs/99/index.html").read_text(), "trusted regenerated report")

    def test_http_error_does_not_become_a_permanent_missing_report(self):
        class API:
            repository = "nix-ocaml/nix-overlays"
            def request(self, *_, **__):
                raise RuntimeError("HTTP 503")
        artifact = {"id": 99, "name": "nix-ci-build-test-attempt-1", "size_in_bytes": 100}
        with tempfile.TemporaryDirectory() as temporary, self.assertRaises(RuntimeError):
            site.render_artifact(API(), artifact, run(), Path("/trusted/renderer"), Path(temporary))

    def test_unsupported_zip_compression_is_an_artifact_error(self):
        data = zipped({"results.json": json.dumps(snapshot())})
        with patch.object(zipfile.ZipFile, "read", side_effect=NotImplementedError("compression")), self.assertRaises(ValueError):
            site.artifact_data(data)

    def test_missing_report_is_visible(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            site.render_indexes(root, {"version": 1, "repository": "nix-ocaml/nix-overlays", "runs": [run()]})
            self.assertIn("No package reports were uploaded", (root / "runs/10/1/index.html").read_text())


class MetadataTests(unittest.TestCase):
    def test_wrong_workflow_and_incomplete_attempt_are_rejected(self):
        class API:
            repository = "nix-ocaml/nix-overlays"
            def request(self, *_, **__):
                return self.data
        api = API()
        api.data = {"path": ".github/workflows/untrusted.yml", "repository": {"full_name": api.repository}, "status": "completed", "run_attempt": 1}
        with self.assertRaises(ValueError):
            site.load_run(api, 1, 1)
        api.data.update(path=".github/workflows/pipeline.yml", status="in_progress")
        with self.assertRaises(ValueError):
            site.load_run(api, 1, 1)

    def test_head_commit_is_not_taken_from_the_snapshot(self):
        class API:
            repository = "nix-ocaml/nix-overlays"
            def request(self, *_, **__):
                return {"path": ".github/workflows/pipeline.yml", "repository": {"full_name": self.repository},
                        "status": "completed", "run_attempt": 2, "run_number": 10, "head_sha": "a" * 40,
                        "head_branch": "my-branch", "head_repository": {"full_name": "contributor/fork"},
                        "event": "pull_request", "pull_requests": [], "conclusion": "failure",
                        "created_at": "2026-11-10T10:00:00Z", "updated_at": "2026-11-10T11:00:00Z"}
            def pages(self, endpoint, _):
                if endpoint.startswith("commits/"):
                    return [{"number": 20, "head": {"sha": "a" * 40}, "base": {"repo": {"full_name": self.repository}}},
                            {"number": 21, "head": {"sha": "b" * 40}, "base": {"repo": {"full_name": self.repository}}},
                            {"number": 22, "base": {"repo": {"full_name": "other/repo"}}}]
                return []
        result = site.load_run(API(), 10, 2)
        self.assertEqual(result["headSha"], "a" * 40)
        self.assertEqual(result["headRepository"], "contributor/fork")
        self.assertEqual(result["pullRequests"], [20, 21])


if __name__ == "__main__":
    unittest.main()
