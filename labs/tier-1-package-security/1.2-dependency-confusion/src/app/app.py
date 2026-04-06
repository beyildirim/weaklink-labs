"""WeakLink Corp internal application.

This app uses the internal wl-auth package for authentication.
"""

from wl_auth import authenticate, get_version


def main():
    print("=" * 50)
    print("  WeakLink Corp Internal Application")
    print("=" * 50)
    print()
    print(f"  Auth library: {get_version()}")
    print()

    # Simulate authentication
    result = authenticate("admin", "secret-token-123")
    print(f"  Auth result: {result}")
    print()

    # Check for compromise
    import os
    if os.path.exists("/tmp/dependency-confusion-pwned"):
        print("  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print("  !! SYSTEM COMPROMISED                      !!")
        print("  !! /tmp/dependency-confusion-pwned exists   !!")
        print("  !! Malicious code ran during pip install    !!")
        print("  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    else:
        print("  [OK] No compromise detected.")
        print("  [OK] /tmp/dependency-confusion-pwned does not exist.")

    print()


if __name__ == "__main__":
    main()
