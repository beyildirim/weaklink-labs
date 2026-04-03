"""Simple application that uses internal packages."""

from internal_utils import sanitize_input, format_response
from data_processor import process_record


def main():
    print("=== My Application ===")
    print()

    # Test internal-utils
    result = format_response({"message": "Hello from the app"})
    print(f"internal-utils version: {result['version']}")
    print(f"Response: {result}")
    print()

    # Test data-processor
    record = process_record("<script>alert('xss')</script>")
    print(f"Processed record: {record}")
    print()

    # Check which version we got
    import internal_utils
    if hasattr(internal_utils, '__version__'):
        v = internal_utils.__version__
        if v == "1.0.0":
            print("[OK] Correct version of internal-utils installed (1.0.0 from private registry)")
        elif v == "99.0.0":
            print("[WARNING] Wrong version installed! Got 99.0.0 from public PyPI!")
            print("[WARNING] This demonstrates why --extra-index-url is dangerous.")
        else:
            print(f"[INFO] Unexpected version: {v}")


if __name__ == "__main__":
    main()
