# CI against released and developing QuestieTDB

Status: proposal. This document does not change CI.

Questie should run focused integration tests against real QuestieTDB checkouts, not only its test mock. The checks should protect compatibility with the provider users can install while warning about changes developing on QuestieTDB master.

## Two independent checks

Run the same integration checks against both targets on every Questie change. The jobs can run in parallel.

| QuestieTDB target | Purpose | Merge policy |
| --- | --- | --- |
| Supported release | Prove compatibility with the released provider Questie promises to support | Required |
| `master` | Detect upcoming integration or contract changes | Advisory; report failures as warnings |

| Supported release result | Master result | Outcome |
| --- | --- | --- |
| Pass | Pass | Provider compatibility checks pass |
| Pass | Fail | Allow merge, with a visible master-compatibility warning |
| Fail | Pass | Block merge: the consumer may depend on unreleased functionality |
| Fail | Fail | Block merge |

Other required Questie checks still apply. A passing provider check does not override unrelated test failures.

## Why not use release testing only as a fallback?

The original idea was to test master first and try a release only if master failed. That misses a consumer change which uses a function available on master but absent from the released provider. Master would pass and the release would never be tested.

Always running the release check prevents merging a consumer that only works with unreleased provider code. The advisory master check still lets the two repositories develop independently.

## Selecting the required target

Keep an explicit supported release reference in the Questie repository and update it deliberately. Prefer a published, non-prerelease version rather than whichever tag happens to be newest. Record the resolved commit SHA in CI output for both targets.

If no usable release exists during migration, pin a known-working provider commit as a temporary required target. Label that limitation clearly: a commit-based check is not proof of compatibility with a published release.

When a consumer begins requiring a newer provider, update its declared requirement, CI target, and vendored type declarations together. Older provider releases still advertised as supported need coverage too; moving the test target alone must not silently drop that promise.

## Integration coverage

Keep ordinary unit tests fast and mock-backed. Both provider jobs should run the same committed real-provider integration suite covering:

- Entity reads and the correction behavior Questie consumes.
- Translation slots, built-in and custom locale selection, precedence, and withdrawal.
- Support-wrapper initialization with real zone, XP, faction-template, and drop data, including runtime controls and Mists' mixed drop sources.
- Contract checks and initialization ordering at the provider interface.

Questie already has mock-versus-provider conformance tests. Downloading QuestieTDB does not automatically make every test exercise the real provider. The jobs must explicitly select its path and fail if the provider is absent or the intended integration tests are skipped.

Promote the local real-provider support-wrapper checks into a committed test entry point before relying on them in CI. A temporary local script is not a CI gate.

Source-mode tests exercise the interface, but do not prove that a generated release contains the correct metadata or file list. Include checks against the released Baked artifact for behavior that depends on packaging or generated localization. Preserve intentional Source/Baked localization differences in the assertions.

## Coordinating a contract change

1. QuestieTDB master introduces the change. Questie's advisory check warns if integration breaks.
2. Prepare the corresponding consumer change and test it against the proposed provider revision.
3. Publish the supporting QuestieTDB release.
4. Update Questie's required provider reference and compatibility declaration with the consumer change.
5. Merge when the required release check and other required checks pass.

A temporary test against a provider PR or commit can help develop coordinated changes. It must not silently replace the released-compatibility requirement for merging.

## Reporting

Show the tested provider reference, resolved SHA, failing test names, and useful diagnostics in each job's summary. A master failure should remain visible as an advisory failure, not disappear into a successful log. Distinguish checkout or infrastructure errors from actual compatibility failures.

Neither job should publish releases, write to production, or require live WoW clients. Running code from either checkout must not expose deployment credentials.
