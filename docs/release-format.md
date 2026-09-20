# Release metadata

## Shared structure

A `release.json` has one `releases` array and any number of addon-named sections.
The names below are placeholders:

```text
{
    "releases": [...],
    "<addon_name>": { ... },
    "<another_addon_name>": { ... }
}
```

`releases` contains addon-manager entries with `filename`, `nolib`, and flavor/interface
`metadata` derived from packaged TOCs. Addon-named sections use common metadata
fields and can carry addon-specific extensions.

A combined package copies addon sections unchanged, including their artifact records.
Those records must not be repointed to the combined ZIP; the outer `releases` array
describes the combined downloads.

## Shared addon metadata

| Field | Meaning |
| --- | --- |
| `repository` | Canonical HTTPS repository URL without a trailing slash, used to resolve commit links. |
| `version` | The addon's independent version. |
| `producerCommit` | Full source commit SHA used to produce the addon build. |
| `changelog` | Current-release changes, preserving supplied wording and order. |
| `artifacts` | Optional records describing this addon's original archives, including `file`, `sha256`, and `bytes` (compressed size). |

Each change has `category`, `text`, `commit`, `author`, and `coAuthors`. Its `commit`
identifies the change, not the build. Categories are `feature` (new features),
`fix` (general fixes), `quest` (quest fixes), `db` (database fixes), and
`locale` (localization fixes). Render the primary author followed by co-authors.
Names are display names, not guaranteed GitHub usernames; escape them for display
and do not invent profile links. Link credits to the entry's commit and build
provenance to `producerCommit`, using the addon's `repository` field.

Commit fields contain full commit SHAs. Forty zeroes are allowed only for
`producerCommit` in local builds without Git history; never link that sentinel.
Changelog entries must identify real commits, not the sentinel.

A contributor list can be derived from entries rather than stored again. Empty or
missing changelogs do not mean "nothing changed."

Addon-specific fields, such as contract ranges and import baselines, remain
extensions and travel unchanged with the shared fields.

## Bundling and verification

A component update does not change another component's version. Use the same retained
metadata for archive verification and release notes. Reject checksum mismatches rather
than fetching newer metadata when rendering notes.
