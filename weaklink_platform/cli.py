from __future__ import annotations

import argparse

from weaklink_platform import host_ops


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="python -m weaklink_platform.cli")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("start")
    subparsers.add_parser("stop")
    subparsers.add_parser("deploy")
    subparsers.add_parser("status")
    subparsers.add_parser("logs")
    subparsers.add_parser("clean")
    subparsers.add_parser("clean-images")
    subparsers.add_parser("labs-lint")

    build_parser = subparsers.add_parser("build-images")
    build_parser.add_argument("targets", nargs="*", choices=sorted(host_ops.IMAGE_SPECS))

    docs_parser = subparsers.add_parser("docs-check")
    docs_parser.add_argument("--site-url", default="")

    smoke_parser = subparsers.add_parser("smoke-test")
    smoke_parser.add_argument("--namespace", default=host_ops.NAMESPACE)
    smoke_parser.add_argument("--workstation-selector", default="app.kubernetes.io/name=workstation")

    sign_parser = subparsers.add_parser("sign-images")
    sign_parser.add_argument("--keyless", action="store_true")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "start":
        host_ops.start_platform()
    elif args.command == "stop":
        host_ops.stop_platform()
    elif args.command == "deploy":
        host_ops.deploy_release()
    elif args.command == "status":
        host_ops.show_status()
    elif args.command == "logs":
        host_ops.show_logs()
    elif args.command == "clean":
        host_ops.clean_platform()
    elif args.command == "clean-images":
        host_ops.clean_images()
    elif args.command == "labs-lint":
        host_ops.labs_lint()
    elif args.command == "build-images":
        host_ops.build_images(args.targets or None)
    elif args.command == "docs-check":
        host_ops.build_docs(site_url=args.site_url)
    elif args.command == "smoke-test":
        host_ops.smoke_test(namespace=args.namespace, workstation_selector=args.workstation_selector)
    elif args.command == "sign-images":
        host_ops.sign_images(keyless=args.keyless)
    else:
        parser.error(f"Unknown command: {args.command}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
