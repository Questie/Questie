# Cache regression reproduction

Companion to finding 1 in `../REVIEW_FINDINGS.md`.

From the repository root, run with Lua 5.1 and Git available:

```bash
lua review-artifacts/cache-repro.lua
```

The script reads `QuestLogCache.lua` directly from these local Git commits:

- Starting master: `04ba519340847f47ee6a305e7ff413fb0ff8ba0b`
- Reviewed HEAD: `545d17fd5cc03fd13534784a086b6b35f2aee3c5`

Both commits must be available locally; a shallow clone may need more history. The script does not fetch, switch branches, or modify files. API responses are synthetic. The labels `master` and `HEAD` refer to these pinned revisions, not the current branch tips, so this preserves the original finding rather than testing a later fix.

Expected on each of three retries:

```text
master: cacheMiss=false count=4
HEAD:   cacheMiss=true  count=5
```

The source archives and captured output are redundant local copies and are not needed to run the reproduction or implement the fixes.
