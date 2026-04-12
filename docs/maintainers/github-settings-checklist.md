# GitHub Settings Checklist

These settings live in GitHub repository settings and cannot be enforced fully from the repo alone.

## Security

- Enable **private vulnerability reporting** for the repository.
- Enable **secret scanning** and **push protection** if available on your plan.
- Enable **Dependabot alerts** and keep them visible to maintainers.
- Verify `SECURITY.md` is rendered on the repo front page.

## Branch and Tag Protection

- Protect `main` with pull-request-only changes.
- Require these checks before merge:
  - `Check Docs`
  - `Test Labs`
  - `Dependency Review`
  - `CodeQL`
  - `Secret Scan`
- Restrict force-pushes and branch deletion on `main`.
- Protect release tags such as `v*` from unreviewed rewrites.

## Releases and Supply Chain

- Keep GitHub Actions permissions at the lowest practical default.
- Review publish workflows after any change touching `.github/workflows/`, image build paths, or release automation.
- Confirm GHCR package visibility and release asset permissions match the intended public/private model.

## Public Repo Face

- Upload a GitHub social preview image using `docs/assets/github-overview.svg` or a derived PNG.
- Keep the repository description and topic tags aligned with the README.
- Re-check the README image and top links after every major docs refresh.
