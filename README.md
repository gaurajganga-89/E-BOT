# E-BOT — UNIFIED_SUPREME_FUSION

MetaTrader 5 Expert Advisor.

---

## Release Discipline

### Version tags

- Every release is tagged `vX.Y` or `vX.Y.Z` (e.g. `v1.37`).
- Tags are created **after** the PR is merged to `main`.
- `#property version` in the `.mq5` file **must match** the tag.

### Version bump checklist

Before opening a PR for a new version:

- [ ] Bump `#property version "X.Y"` in `UNIFIED_SUPREME_FUSION.mq5`.
- [ ] Add a `## vX.Y — YYYY-MM-DD` entry in `CHANGELOG.md`.
- [ ] Ensure no placeholder markers like `/*... existing code ...*/` remain.
- [ ] Ensure `#property strict` is present.
- [ ] Ensure banned tokens (e.g. `TRADE_RETCODE_NO_QUOTES`) are absent.
- [ ] Compile-clean in MetaTrader 5 before merging.
- [ ] After merge: create and push the Git tag (`git tag v1.37 && git push origin v1.37`).

### CHANGELOG entries

See [CHANGELOG.md](CHANGELOG.md) for the full history. Every PR that changes
trading logic **must** include a changelog entry.

---

## CI — EA Sanity Check

A GitHub Actions workflow (`.github/workflows/sanity.yml`) runs on every pull
request and every push to `main`. It executes `scripts/check_ea_sanity.sh`,
which verifies:

| Check | What it validates |
|---|---|
| File exists & non-empty | `UNIFIED_SUPREME_FUSION.mq5` is present and not a stub |
| No placeholders | No `/*... existing code ...*/` or similar markers |
| `#property strict` | Required compiler directive is present |
| `#property version` | Matches `X.Y` or `X.Y.Z` semantic version pattern |
| VERSION file (optional) | If a `VERSION` file exists, version must match |
| Banned tokens | `TRADE_RETCODE_NO_QUOTES` must not appear |

The workflow job is named **EA Sanity**. Use this name when configuring
required status checks in branch protection (see below).

---

## Branch Protection on `main`

To prevent direct pushes and require all changes to pass CI:

1. Go to **Settings → Branches → Add rule** (pattern: `main`).
2. Enable the following:
   - **Require a pull request before merging**
   - **Require status checks to pass before merging**
     - Add required check: **`EA Sanity`**
   - **Require branches to be up to date before merging**
   - *(Recommended)* **Do not allow bypassing the above settings**
3. Leave the defaults (force-push and branch deletion are blocked by default).
4. Click **Create** / **Save changes**.

> **Why?** The `main` branch previously received a direct-push stub commit
> (`416f190`) that replaced the full EA with placeholder code. Branch
> protection + required CI prevents this from happening again.

---

## File structure

```
UNIFIED_SUPREME_FUSION.mq5   — Main EA source file
scripts/check_ea_sanity.sh   — Sanity check script (used by CI)
.github/workflows/sanity.yml — GitHub Actions workflow
CHANGELOG.md                 — Version history
README.md                    — This file
```
