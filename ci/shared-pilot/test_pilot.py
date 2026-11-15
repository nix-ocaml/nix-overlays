#!/usr/bin/env python3
"""Fail-closed checks for the pilot's build budget and measured outcomes."""

import copy
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest

import pilot


class BudgetTests(unittest.TestCase):
    def setUp(self):
        self.selection = {
            "sets": {"native": {"fmt": {"derivation": "root"}}},
            "allowedDerivations": ["root", "topkg"],
        }
        self.manifest = {
            "plan": {"requests": [{"id": "native", "roots": [{"drvPath": "root"}]}],
                     "groups": [{"id": "native", "kind": "package", "system": "x86_64-linux",
                                 "members": ["root", "topkg"], "requiredPaths": ["/compiler"]}]},
            "graph": {"root": {"outputs": {"out": "/root"}},
                      "topkg": {"outputs": {"out": "/topkg"}}},
            "cachedPaths": ["/compiler"],
        }

    def test_cached_toolchain_and_small_owned_work_are_allowed(self):
        result = pilot.validate_plan(self.manifest, self.selection)
        self.assertEqual(result["ownedDerivations"], ["root", "topkg"])

    def test_cold_compiler_is_rejected_before_workers(self):
        self.manifest["plan"]["groups"][0]["members"].append("compiler")
        with self.assertRaisesRegex(RuntimeError, "Cold dependencies"):
            pilot.validate_plan(self.manifest, self.selection)

    def test_changed_root_is_rejected(self):
        self.manifest["plan"]["requests"][0]["roots"][0]["drvPath"] = "other"
        with self.assertRaisesRegex(RuntimeError, "roots differ"):
            pilot.validate_plan(self.manifest, self.selection)

    def test_duplicate_ownership_is_rejected(self):
        self.manifest["plan"]["groups"].append(copy.deepcopy(self.manifest["plan"]["groups"][0]))
        with self.assertRaisesRegex(RuntimeError, "more than one owner"):
            pilot.validate_plan(self.manifest, self.selection)

    def test_uncached_boundary_is_rejected(self):
        self.manifest["cachedPaths"] = []
        with self.assertRaisesRegex(RuntimeError, "boundary"):
            pilot.validate_plan(self.manifest, self.selection)

    def test_warm_plan_needs_no_dependency_graph_or_workers(self):
        self.manifest["plan"]["groups"] = []
        self.manifest["graph"] = {}
        result = pilot.validate_plan(self.manifest, self.selection)
        self.assertTrue(result["warm"])
        self.assertEqual(result["cachedBoundaryPaths"], [])

    def summary_fixture(self, directory, *, warm=False, guard_status="success"):
        directory = Path(directory)
        plan, reports, report = [directory / name for name in ("plan", "reports", "aggregate")]
        reports.mkdir()
        if warm:
            self.manifest["plan"]["groups"] = []
        pilot.write_json(plan / "selection.json", self.selection)
        pilot.write_json(plan / "execution-plan.json", self.manifest)
        pilot.write_json(plan / "bounded-work.json", {"status": guard_status})
        pilot.write_json(report / "aggregate.json", {"status": "success", "activeRunId": "test", "groups": []})
        return SimpleNamespace(plan=str(plan), reports=str(reports), report=str(report))

    def aggregate_attempts(self, args, attempts):
        pilot.write_json(Path(args.report) / "aggregate.json", {
            "status": "success", "activeRunId": "test", "groups": [{
                "id": "native", "latestAttemptId": attempts[-1]["attemptId"],
                "ambiguousAttemptOrder": False, "attempts": attempts,
            }],
        })

    def test_warm_report_is_success_without_claiming_builds(self):
        with tempfile.TemporaryDirectory() as directory:
            args = self.summary_fixture(directory, warm=True)
            pilot.summarize(args)
            result = pilot.read_json(Path(args.report) / "pilot-measurements.json")
            self.assertEqual(result["status"], "success")
            self.assertEqual(result["observedBuildCounts"], {})

    def test_missing_execution_evidence_cannot_report_success(self):
        with tempfile.TemporaryDirectory() as directory:
            args = self.summary_fixture(directory)
            pilot.write_json(Path(args.reports) / "worker/pilot-worker.json", {
                "groupId": "native", "status": "success", "startedAt": 1, "finishedAt": 2,
            })
            with self.assertRaisesRegex(RuntimeError, "did not complete"):
                pilot.summarize(args)

    def test_failed_guard_cannot_report_warm_success(self):
        with tempfile.TemporaryDirectory() as directory:
            args = self.summary_fixture(directory, warm=True, guard_status="failed")
            with self.assertRaisesRegex(RuntimeError, "did not complete"):
                pilot.summarize(args)

    def test_observed_work_outside_ownership_is_a_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            args = self.summary_fixture(directory)
            self.aggregate_attempts(args, [{
                "runId": "test", "attemptId": "1", "status": "success", "startedAt": 1, "finishedAt": 2,
                "actual": {"derivations": [{"drvPath": "compiler", "state": "built", "buildSeconds": 0.5}]},
            }])
            with self.assertRaisesRegex(RuntimeError, "did not complete"):
                pilot.summarize(args)
            result = pilot.read_json(Path(args.report) / "pilot-measurements.json")
            self.assertEqual(result["ownershipViolations"], ["compiler"])

    def test_same_group_retry_uses_aggregate_selected_attempt(self):
        with tempfile.TemporaryDirectory() as directory:
            args = self.summary_fixture(directory)
            attempts = [{"runId": "test", "attemptId": str(number), "status": status,
                         "startedAt": number, "finishedAt": number + 0.5,
                         "actual": {"derivations": [{"drvPath": "root", "state": "built", "buildSeconds": 0.25}]}}
                        for number, status in [(1, "failed"), (2, "success")]]
            self.aggregate_attempts(args, attempts)
            pilot.summarize(args)
            result = pilot.read_json(Path(args.report) / "pilot-measurements.json")
            self.assertEqual(result["status"], "success")
            self.assertEqual(result["observedBuildCounts"], {"root": 1})
            self.assertEqual(result["allAttemptBuildCounts"], {"root": 2})


if __name__ == "__main__":
    unittest.main()
