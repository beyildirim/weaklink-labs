from __future__ import annotations

import argparse
import csv
import json
import os
import socket
import sys
from datetime import datetime, timezone
from pathlib import Path

from weaklink_platform.console import Style, colorize
from weaklink_platform.lab_runtime import VerificationCheck, VerificationResult
from weaklink_platform.labs import Lab, find_lab, iter_labs, parse_estimated_minutes, phase_entries
from weaklink_platform.paths import LABS_ROOT, PROGRESS_DIR, ensure_progress_dir
from weaklink_platform.progress import completed_at, increment_hint, is_completed, mark_completed, reset_progress
from weaklink_platform.subprocess_utils import capture, run


NAMESPACE = "weaklink"

ASSESS_QUESTIONS = (
    ("What does `git diff HEAD~1` show?", ("changes in last commit", "staged changes", "untracked files", "merge conflicts"), "a", "Git"),
    ("What prevents direct pushes to main?", (".gitignore", "branch protection rules", "git hooks only", "repository permissions"), "b", "Git"),
    ("In a supply chain attack via Git, an attacker would most likely:", ("delete the repo", "modify a build script in a PR", "change the README", "add a .gitignore"), "b", "Git"),
    ("When you run `pip install <package>`, what file can execute arbitrary code?", ("README.md", "setup.py", "requirements.txt", "__init__.py"), "b", "Package Managers"),
    ("What does `--extra-index-url` do in pip?", ("replaces the default registry", "adds an additional registry to check", "disables the cache", "enables verbose mode"), "b", "Package Managers"),
    ("What is a lockfile?", ("a file that prevents package installation", "an exact snapshot of all dependency versions", "a password file for private registries", "a log of all pip commands"), "b", "Package Managers"),
    ("What does `--require-hashes` do?", ("encrypts packages", "verifies package integrity via checksums", "hashes the requirements file", "enables TLS"), "b", "Package Managers"),
    ("Docker tags like `:latest` are:", ("immutable -- always point to the same image", "mutable -- can be reassigned to different images", "only used in development", "automatically versioned"), "b", "Containers"),
    ("What uniquely identifies a Docker image regardless of tag changes?", ("image name", "tag", "digest (sha256 hash)", "Dockerfile"), "c", "Containers"),
    ("An attacker who pushes a new image with the same tag to a registry is performing:", ("registry confusion", "tag poisoning", "layer injection", "manifest confusion"), "b", "Containers"),
)


def _check_cluster() -> None:
    result = run(["kubectl", "get", "namespace", NAMESPACE], check=False)
    if result.returncode == 0:
        return
    print(colorize("Error: WeakLink Labs is not running.", Style.RED), file=sys.stderr)
    print(f"Run '{colorize('make start', Style.BOLD)}' to start the platform.", file=sys.stderr)
    raise SystemExit(1)


def _get_workstation_pod() -> str:
    return capture(
        [
            "kubectl",
            "get",
            "pods",
            "-n",
            NAMESPACE,
            "-l",
            "app.kubernetes.io/name=workstation",
            "-o",
            "jsonpath={.items[0].metadata.name}",
        ]
    )


def _all_labs() -> list[Lab]:
    return iter_labs(LABS_ROOT)


def _require_lab(lab_id: str) -> Lab:
    lab = find_lab(lab_id, LABS_ROOT)
    if lab:
        return lab
    print(colorize(f"Error: Lab {lab_id} not found.", Style.RED), file=sys.stderr)
    raise SystemExit(1)


def _completed_count() -> int:
    ensure_progress_dir()
    return len(list(PROGRESS_DIR.glob("*.completed")))


def cmd_shell(_: argparse.Namespace) -> int:
    _check_cluster()
    pod = _get_workstation_pod()
    if not pod:
        print(colorize("Error: Workstation pod not found.", Style.RED), file=sys.stderr)
        print("Check status with: make status", file=sys.stderr)
        return 1
    print(colorize(f"Connecting to workstation pod: {pod}", Style.DIM))
    return run(["kubectl", "exec", "-it", "-n", NAMESPACE, pod, "--", "/bin/bash", "-l"], check=False).returncode


def cmd_verify(args: argparse.Namespace) -> int:
    _check_cluster()
    lab = _require_lab(args.lab_id)
    if not (lab.lab_dir / "verify.sh").exists() and not (lab.lab_dir / "verify.py").exists():
        print(colorize(f"No verification script for lab {lab.lab_id}.", Style.YELLOW))
        return 1
    pod = _get_workstation_pod()
    if not pod:
        print(colorize("Error: Workstation pod not found.", Style.RED), file=sys.stderr)
        return 1
    print(f"  {colorize(f'Verifying lab {lab.lab_id}...', Style.CYAN)}")
    print()
    result = run(
        [
            "kubectl",
            "exec",
            "-n",
            NAMESPACE,
            pod,
            "--",
            "python3",
            "-m",
            "weaklink_platform.lab_runtime",
            lab.lab_id,
            "--json",
        ],
        capture_output=True,
        check=False,
    )
    payload = _parse_verification_payload(result)
    _print_verification_payload(payload)
    if not payload.passed:
        print()
        print(f"  {colorize('Not quite -- check the output above and try again.', Style.RED)}")
        hint_text = f"Run './cli/weaklink hint {lab.lab_id}' if you are stuck."
        print(f"  {colorize(hint_text, Style.DIM)}")
        return 1
    mark_completed(lab.lab_id)
    print()
    print(f"  {colorize(f'Lab {lab.lab_id} completed!', Style.GREEN + Style.BOLD)}")
    print()
    labs = _all_labs()
    next_lab = None
    for index, item in enumerate(labs):
        if item.lab_id == lab.lab_id and index + 1 < len(labs):
            next_lab = labs[index + 1]
            break
    if next_lab:
        print(f"  Next lab: {colorize(f'./cli/weaklink info {next_lab.lab_id}', Style.BOLD)}")
    return 0


def _parse_verification_payload(result) -> VerificationResult:
    if result.stdout.strip():
        payload = json.loads(result.stdout.strip().splitlines()[-1])
        return VerificationResult(
            passed=bool(payload.get("passed")),
            checks=tuple(
                VerificationCheck(status=str(item["status"]), message=str(item["message"]))
                for item in payload.get("checks", [])
            ),
            error=str(payload.get("error")) if payload.get("error") else None,
        )
    return VerificationResult(passed=False, checks=tuple(), error=result.stderr.strip() or "Verification failed")


def _print_verification_payload(result: VerificationResult) -> None:
    labels = {
        "pass": colorize("[PASS]", Style.GREEN),
        "fail": colorize("[FAIL]", Style.RED),
        "info": colorize("[INFO]", Style.DIM),
    }
    for check in result.checks:
        print(f"  {labels.get(check.status, labels['info'])} {check.message}")
    if result.error:
        print(f"  {colorize(result.error, Style.RED)}")


def cmd_hint(args: argparse.Namespace) -> int:
    lab = _require_lab(args.lab_id)
    hint_num = increment_hint(lab.lab_id)
    hint_file = lab.lab_dir / "hints" / f"hint-{hint_num}.md"
    if not hint_file.exists():
        print(colorize(f"No more hints available for lab {lab.lab_id}.", Style.YELLOW))
        print(colorize("Check the solution/ directory if you're completely stuck.", Style.DIM))
        return 0
    total_hints = len(list((lab.lab_dir / "hints").glob("hint-*.md")))
    print()
    print(f"  {colorize(f'Hint {hint_num}/{total_hints} for lab {lab.lab_id}', Style.YELLOW)}")
    print("  ────────────────────────────────")
    for line in hint_file.read_text().splitlines():
        print(f"  {line}")
    print()
    if hint_num < total_hints:
        print(colorize(f"Run './cli/weaklink hint {lab.lab_id}' again for the next hint.", Style.DIM))
    else:
        print(colorize("That was the last hint. Check solution/ if still stuck.", Style.DIM))
    return 0


def cmd_info(args: argparse.Namespace) -> int:
    lab = _require_lab(args.lab_id)
    metadata = lab.metadata
    print()
    print(f"  {colorize(str(metadata['title']), Style.BOLD)}")
    print("  ──────────────────────────────────────")
    print(f"  {colorize('ID:', Style.DIM)}            {metadata['id']}")
    print(f"  {colorize('Tier:', Style.DIM)}          {metadata['tier']}")
    print(f"  {colorize('Difficulty:', Style.DIM)}    {metadata['difficulty']}")
    print(f"  {colorize('Time:', Style.DIM)}          {metadata['estimated_time']}")
    print(f"  {colorize('Prerequisites:', Style.DIM)} {metadata['prerequisites']}")
    print(f"  {colorize('Tags:', Style.DIM)}          {metadata['tags']}")
    print()
    print(f"  {colorize('Phases:', Style.BOLD)}")
    for _, label, text in phase_entries(metadata):
        print(f"    {colorize(label, Style.BLUE)}  {text}")
    print()
    return 0


def cmd_status(_: argparse.Namespace) -> int:
    _check_cluster()
    print()
    print(f"  {colorize('WeakLink Labs -- Pod Status', Style.BOLD)}")
    print("  ══════════════════════════════")
    print()
    run(["kubectl", "get", "pods", "-n", NAMESPACE, "-o", "wide"], check=False)
    print()
    job_result = run(
        [
            "kubectl",
            "get",
            "job",
            "lab-setup",
            "-n",
            NAMESPACE,
            "-o",
            "jsonpath={.status.conditions[0].type}",
        ],
        capture_output=True,
        check=False,
    )
    job_status = (job_result.stdout.strip() or "Unknown") if job_result.returncode == 0 else "Unknown"
    print(f"  {colorize(f'Setup job: {job_status}', Style.DIM)}")
    print(f"  {colorize(f'Labs completed: {_completed_count()}', Style.DIM)}")
    print()
    return 0


def cmd_logs(_: argparse.Namespace) -> int:
    _check_cluster()
    print(f"  {colorize('Lab Setup Logs', Style.BOLD)}")
    print("  ──────────────")
    print()
    result = run(["kubectl", "logs", "-n", NAMESPACE, "job/lab-setup"], check=False)
    if result.returncode != 0:
        print(colorize("No logs found. The setup job may not have started yet.", Style.YELLOW))
    return 0


def cmd_reset(args: argparse.Namespace) -> int:
    _require_lab(args.lab_id)
    print(f"  Resetting progress for lab {args.lab_id}...")
    reset_progress(args.lab_id)
    print(f"  {colorize('Done.', Style.GREEN)} Progress reset for {args.lab_id}.")
    return 0


def cmd_assess(_: argparse.Namespace) -> int:
    print()
    print(f"  {colorize('WEAKLINK LABS -- Placement Test', Style.BOLD)}")
    print("  ═══════════════════════════════")
    print()
    print(f"  {colorize('10 questions on Git, package managers, and containers.', Style.DIM)}")
    print(f"  {colorize('Score 8/10 or higher to skip Tier 0.', Style.DIM)}")
    print()
    score = 0
    wrong_topics: list[str] = []
    total = len(ASSESS_QUESTIONS)
    for index, (question, options, correct, topic) in enumerate(ASSESS_QUESTIONS, start=1):
        print(f"  {colorize(f'{index}/{total}. {question}', Style.BOLD)}")
        for label, option in zip(("a", "b", "c", "d"), options):
            print(f"    {label}) {option}")
        print()
        while True:
            answer = input("  Your answer (a/b/c/d): ").strip().lower()
            if answer in {"a", "b", "c", "d"}:
                break
            print(f"  {colorize('Please enter a, b, c, or d.', Style.YELLOW)}")
        if answer == correct:
            print(f"  {colorize('Correct.', Style.GREEN)}")
            score += 1
        else:
            print(f"  {colorize('Incorrect.', Style.RED)} The answer is {colorize(f'{correct})', Style.BOLD)}.")
            if topic not in wrong_topics:
                wrong_topics.append(topic)
        print()
    print("  ──────────────────────────────────────")
    print(f"  {colorize(f'Score: {score}/{total}', Style.BOLD)}")
    print()
    if score >= 8:
        for lab_id in ("0.1", "0.2", "0.3", "0.4", "0.5"):
            mark_completed(lab_id)
        print(f"  {colorize('Tier 0 skipped. You are ready for Tier 1!', Style.GREEN + Style.BOLD)}")
        print()
        print(f"  {colorize('Tier 0 (Labs 0.1-0.5) marked as completed.', Style.DIM)}")
        print(f"  {colorize('Next step: ./cli/weaklink info 1.1', Style.DIM)}")
        return 0
    print(f"  {colorize('We recommend completing Tier 0 labs.', Style.YELLOW)}")
    if wrong_topics:
        print(f"  {colorize('Areas to review: ' + ', '.join(wrong_topics), Style.DIM)}")
    print()
    print(f"  {colorize('Next step: ./cli/weaklink info 0.1', Style.DIM)}")
    print()
    return 0


def _report_rows() -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for lab in _all_labs():
        rows.append(
            {
                "lab_id": lab.lab_id,
                "title": lab.title,
                "tier": lab.tier,
                "tier_name": lab.tier_name,
                "estimated_time": str(lab.metadata["estimated_time"]),
                "status": "completed" if is_completed(lab.lab_id) else "not_started",
                "completed_at": completed_at(lab.lab_id),
            }
        )
    return rows


def cmd_report_pretty(_: argparse.Namespace) -> int:
    rows = _report_rows()
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    print()
    print(colorize("WeakLink Labs -- Completion Report", Style.BOLD))
    print(colorize(f"Generated: {now}", Style.DIM))
    print()
    current_tier = None
    completed = 0
    total_minutes = 0
    for row in rows:
        if row["tier"] != current_tier:
            if current_tier is not None:
                print()
            print(colorize(f"Tier {row['tier']}: {row['tier_name']}", Style.BOLD))
            current_tier = row["tier"]
        if row["status"] == "completed":
            completed += 1
            total_minutes += parse_estimated_minutes(str(row["estimated_time"]))
            status_text = colorize("done", Style.GREEN)
            timestamp = f"  {colorize(str(row['completed_at']), Style.DIM)}"
            detail = "Completed"
        else:
            status_text = colorize("    ", Style.DIM)
            timestamp = ""
            detail = "Not started"
        print(f"  {row['lab_id']:<4} {row['title']:<40} [{status_text}]  {detail}{timestamp}")
    print()
    total = len(rows)
    percentage = int((completed * 100 / total) if total else 0)
    print(f"{colorize('Progress:', Style.BOLD)} {completed}/{total} labs completed ({percentage}%)")
    if total_minutes:
        print(f"{colorize('Total time:', Style.BOLD)} ~{total_minutes} minutes (estimated from completed labs)")
    print()
    return 0


def cmd_report_json(_: argparse.Namespace) -> int:
    rows = _report_rows()
    total = len(rows)
    completed = sum(1 for row in rows if row["status"] == "completed")
    payload = {
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "user": f"{os.getenv('USER', 'unknown')}@{socket.gethostname().split('.')[0]}",
        "labs": {
            row["lab_id"]: {
                "title": row["title"],
                "status": row["status"],
                "completed_at": row["completed_at"],
            }
            for row in rows
        },
        "summary": {
            "total": total,
            "completed": completed,
            "percentage": int((completed * 100 / total) if total else 0),
        },
    }
    print(json.dumps(payload, indent=2))
    return 0


def cmd_report_csv(_: argparse.Namespace) -> int:
    writer = csv.writer(sys.stdout)
    writer.writerow(["lab_id", "title", "status", "completed_at"])
    for row in _report_rows():
        writer.writerow([row["lab_id"], row["title"], row["status"], row["completed_at"] or ""])
    return 0


def _load_team_reports(args: argparse.Namespace) -> list[dict[str, object]]:
    reports: list[dict[str, object]] = []
    if args.dir:
        report_dir = Path(args.dir)
        if not report_dir.is_dir():
            raise SystemExit(f"Directory '{report_dir}' not found.")
        for report_file in sorted(report_dir.glob("*.json")):
            reports.append(json.loads(report_file.read_text()))
        if not reports:
            raise SystemExit(f"No .json files found in '{report_dir}'.")
        return reports
    if sys.stdin.isatty():
        raise SystemExit("report --team requires piped input or --dir <path>.")
    raw = sys.stdin.read()
    decoder = json.JSONDecoder()
    index = 0
    while index < len(raw):
        while index < len(raw) and raw[index].isspace():
            index += 1
        if index >= len(raw):
            break
        report, offset = decoder.raw_decode(raw, idx=index)
        reports.append(report)
        index = offset
    if not reports:
        raise SystemExit("No valid JSON reports found on stdin.")
    return reports


def cmd_report_team(args: argparse.Namespace) -> int:
    reports = _load_team_reports(args)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    print()
    print(colorize("WeakLink Labs -- Team Completion Report", Style.BOLD))
    print(colorize(f"Generated: {now}", Style.DIM))
    print(colorize(f"Analysts:  {len(reports)}", Style.DIM))
    print()
    print(f"  {colorize('Analyst', Style.BOLD):<30}  {colorize('Completed', Style.BOLD):>10}  {colorize('Progress', Style.BOLD):>10}")
    print("  ──────────────────────────────────────────────────────")
    team_total = 0
    team_completed = 0
    for report in reports:
        user = str(report.get("user", "unknown"))
        summary = report.get("summary", {})
        total = int(summary.get("total", 0))
        completed = int(summary.get("completed", 0))
        percentage = int(summary.get("percentage", 0))
        team_total += total
        team_completed += completed
        color = Style.RED
        if percentage >= 66:
            color = Style.GREEN
        elif percentage >= 33:
            color = Style.YELLOW
        bar_filled = int(percentage * 20 / 100)
        bar = ("█" * bar_filled) + ("░" * (20 - bar_filled))
        print(f"  {user:<30}  {completed:>5}/{total:<4}  {colorize(bar, color)} {percentage:>3}%")
    print("  ──────────────────────────────────────────────────────")
    team_percentage = int((team_completed * 100 / team_total) if team_total else 0)
    print(f"  {colorize('TOTAL', Style.BOLD):<30}  {team_completed:>5}/{team_total:<4}  {team_percentage:>3}%")
    print()
    first_report = reports[0].get("labs", {})
    print(colorize("Per-Lab Completion:", Style.BOLD))
    print()
    for lab_id, info in first_report.items():
        title = str(info.get("title", lab_id))
        completed_count = 0
        for report in reports:
            lab_report = report.get("labs", {}).get(lab_id, {})
            if lab_report.get("status") == "completed":
                completed_count += 1
        color = Style.RED
        if completed_count == len(reports):
            color = Style.GREEN
        elif completed_count > 0:
            color = Style.YELLOW
        print(f"  {lab_id:<4} {title:<40} {colorize(f'{completed_count}/{len(reports)}', color)}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="./cli/weaklink")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("assess").set_defaults(func=cmd_assess)
    subparsers.add_parser("shell").set_defaults(func=cmd_shell)

    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("lab_id")
    verify_parser.set_defaults(func=cmd_verify)

    hint_parser = subparsers.add_parser("hint")
    hint_parser.add_argument("lab_id")
    hint_parser.set_defaults(func=cmd_hint)

    info_parser = subparsers.add_parser("info")
    info_parser.add_argument("lab_id")
    info_parser.set_defaults(func=cmd_info)

    subparsers.add_parser("status").set_defaults(func=cmd_status)
    subparsers.add_parser("logs").set_defaults(func=cmd_logs)

    reset_parser = subparsers.add_parser("reset")
    reset_parser.add_argument("lab_id")
    reset_parser.set_defaults(func=cmd_reset)

    report_parser = subparsers.add_parser("report")
    report_parser.add_argument("--json", action="store_true", dest="as_json")
    report_parser.add_argument("--csv", action="store_true", dest="as_csv")
    report_parser.add_argument("--team", action="store_true")
    report_parser.add_argument("--dir")
    report_parser.set_defaults(func=None)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.command == "report":
        if args.as_json:
            return cmd_report_json(args)
        if args.as_csv:
            return cmd_report_csv(args)
        if args.team:
            return cmd_report_team(args)
        return cmd_report_pretty(args)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
