# Hint 2: The Defense Strategy

To defend against manifest confusion, you need to:

1. **Never trust `npm view` for security decisions.** Always inspect the actual tarball.
2. **Use a lockfile** (`package-lock.json`) with integrity hashes -- this pins exact tarball contents.
3. **Use `npm ci`** instead of `npm install` -- it strictly follows the lockfile without modifying it.

For the lab, you need to:
- Remove `crafted-widget` from your dependencies
- Use `safe-utils` instead (or any package that has clean manifests)
- Make sure `package-lock.json` has `integrity` fields
- Clean up `/tmp/manifest-confusion-pwned`
