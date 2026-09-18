# CI against released and developing QuestieDB

Status: `.github/workflows/provider-conformance.yml` runs the existing mock-versus-provider conformance suite against QuestieDB `master` in Source mode. An explicitly configured missing checkout fails instead of skipping. This is a temporary migration check, not released-provider compatibility or the full integration coverage proposed below. CI also validates the TOC contract declarations and build preflight.

The `QuestieDB master conformance` check follows provider development and logs the resolved SHA. The same Questie revision can therefore pass or fail as the provider changes. Failures currently fail this job; the supported-release-required/master-advisory split below remains a proposal. Branch-protection settings are managed separately and are not changed by the workflow.

Questie should run focused integration tests against real QuestieDB checkouts, not only its test mock. The checks should protect compatibility with the provider users can install while warning about changes developing on QuestieDB master.

## Two independent checks

Run the same integration checks against both targets on every Questie change. The jobs can run in parallel.

| QuestieDB target | Purpose | Merge policy |
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

Every supported Questie TOC declares `## X-QuestieDB-Contract: 2`. Build preflight and CI reject missing, malformed, duplicate, or inconsistent declarations. The runtime initialization check reads the active TOC rather than hardcoding the requirement. It still runs after file-load provider bindings; moving that gate earlier is tracked in `PLAN-release-bundles.md`.

QuestieDB's release manifest now includes the actual baked `version` and supported contract range. A candidate must satisfy `minSupportedContract <= required <= contractVersion`. A range match is only eligibility, not proof that all APIs Questie uses work; integration checks and the remaining contract/API audit must establish that promise.

Keep an explicit supported release reference in the Questie repository and update it deliberately. Prefer a published, non-prerelease version rather than whichever tag happens to be newest. Record the resolved commit SHA in CI output for both targets.

During migration, the temporary check follows `master` to catch integration drift between the developing repositories. Once a supported release is selected, add the required release check and make the master check advisory. A passing master check is not proof of compatibility with a published release.

When a consumer begins requiring a newer provider, update its declared requirement, CI target, and vendored type declarations together. Older provider releases still advertised as supported need coverage too; moving the test target alone must not silently drop that promise.

## Integration coverage

Keep ordinary unit tests fast and mock-backed. Both provider jobs should run the same committed real-provider integration suite covering:

- Entity reads and the correction behavior Questie consumes.
- Translation slots, built-in and custom locale selection, precedence, and withdrawal.
- Support-wrapper initialization with real zone, XP, faction-template, and drop data, including runtime controls and Mists' mixed drop sources.
- Contract checks and initialization ordering at the provider interface.

Questie already has mock-versus-provider conformance tests. Downloading QuestieDB does not automatically make every test exercise the real provider. The jobs must explicitly select its path and fail if the provider is absent or the intended integration tests are skipped.

Promote the local real-provider support-wrapper checks into a committed test entry point before relying on them in CI. A temporary local script is not a CI gate.

Source-mode tests exercise the interface, but do not prove that a generated release contains the correct metadata or file list. Include checks against the released Baked artifact for behavior that depends on packaging or generated localization. Preserve intentional Source/Baked localization differences in the assertions.

## Coordinating a contract change

1. QuestieDB master introduces the change. Questie's advisory check warns if integration breaks.
2. Prepare the corresponding consumer change and test it against the proposed provider revision.
3. Publish the supporting QuestieDB release.
4. Update Questie's required provider reference and compatibility declaration with the consumer change.
5. Merge when the required release check and other required checks pass.

A temporary test against a provider PR or commit can help develop coordinated changes. It must not silently replace the released-compatibility requirement for merging.

## Reporting

Show the tested provider reference, resolved SHA, failing test names, and useful diagnostics in each job's summary. A master failure should remain visible as an advisory failure, not disappear into a successful log. Distinguish checkout or infrastructure errors from actual compatibility failures.

Neither job should publish releases, write to production, or require live WoW clients. Running code from either checkout must not expose deployment credentials.
