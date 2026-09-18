# Questie and QuestieDB bundle releases

Status: in progress. Phase 1's metadata foundation and phase 2's TOC declarations, build validation, and existing initialization check are implemented locally. The early file-load compatibility guard, supported-release integration CI, and bundle release flow are still pending. CurseForge/Wago workflow upload steps remain hard-disabled.

## Publishing lock during preparation

Implement the refactor as completely as possible, including upload code and offline tests, but keep CurseForge and Wago publishing hard-disabled in every workflow until David explicitly approves enabling them. A manual confirmation checkbox is part of the eventual flow, not permission to remove this preparation lock. Enabling external publishing must be a separate, deliberate change after review. Do not push or publish as part of implementation without authorization.

## Agreed behavior

- Questie and QuestieDB retain independent versions and release cycles.
- A bundle combines a particular Questie version with a particular QuestieDB version.
- Database-only updates may produce multiple bundle releases with the same Questie version, provided the Questie source commit is unchanged.
- Build and validate a bundle once. Later CurseForge publication uploads the existing GitHub artifact, not a rebuild.
- GitHub bundle creation is manual. The action creates source and bundle tags without triggering another release.
- Provider selection defaults to latest compatible stable. Prerelease fallback, prerelease-only, and exact-tag selection are explicit options.
- CurseForge and Wago publication are manual, with independent confirmation checkboxes defaulting to false. Neither publishes automatically; both stay hard-disabled during preparation.
- Creating an existing bundle release fails. Publishing that existing bundle to CurseForge for the first time is a separate, allowed operation.
- A GitHub-only replacement option is an emergency repair operation. Normal content changes require bumping the affected component's version.
- Tag both the Questie source version and the bundle release.
- Questie's TOCs declare the required QuestieDB contract. Selection, CI, and runtime use that same declaration.

Example:

```text
Questie source tag: v11.11.11
Bundle release tag: bundle/v11.11.11+v1.1.1
Asset: Questie-v11.11.11+v1.1.1.zip
  Questie/
  QuestieDB/
```

`bundle/v11.11.11+v1.1.2` may point to the same Questie commit and contain a newer database. The bundle identity is derived, not a third manually maintained version counter. Do not use SemVer ordering of the combined string: build metadata after `+` does not affect SemVer precedence.

## Current implementation and constraints

- `Questie/.github/workflows/publish.yml` publishes to GitHub on `v*` tag pushes. CurseForge and Wago upload steps are commented out; their job credential declarations and standalone upload scripts remain unchanged.
- `Questie/build.py` creates a Questie-only archive and obtains its version from `git describe`.
- `Questie/release.py` bumps versions and creates a local source tag. Its responsibilities must be reconciled with workflow-owned tagging.
- `Questie/changelog.py` also uses `git describe`; bundle tags must not interfere with source-version/changelog selection.
- `Questie/Modules/QuestieInit.lua` checks the active TOC requirement through `VersionCheckDB.Check()`, but only during initialization. Several files still bind provider APIs earlier, during file loading.
- `QuestieDB/src/config.lua` already declares `contractVersion = 2` and `minSupportedContract = 1`.
- `QuestieDB/src/api.lua` already provides `RequireContract(required)` using that supported range.
- QuestieDB packaging now writes the actual baked `version`, `contractVersion`, and `minSupportedContract` alongside commit provenance and artifact checksums. No release containing these changes has been published as part of this work.
- QuestieDB's `preview` release is mutable. Full versions are normally fixed but have an existing explicit override mechanism.
- Existing ZIP builders do not promise byte-identical archives across independent builds.
- [QuestieDB integration](docs/questiedb-integration.md#planned-release-compatibility-checks) separates the implemented Source-mode conformance job against provider master from the still-proposed supported-release compatibility checks.

Paths below are relative to the named repository. QuestieDB distribution tools currently live in `tools/distribution/`; tooling is being reorganized in parallel. Recheck paths and preserve unrelated changes before implementation.

## Phase 1: Complete the provider contract metadata

Owner: QuestieDB. Implemented locally and covered by focused config/API, packaging, and LuaLS checks. Publishing a provider release with this metadata remains a separate authorized operation before automatic bundle selection can use it.

1. Keep `src/config.lua` as the source of truth for the supported contract range. Validate positive integer values and `minSupportedContract <= contractVersion`.
2. Preserve range semantics: a consumer requiring `r` is supported when `minSupportedContract <= r <= contractVersion`. Do not require equality.
3. Make `RequireContract` reject malformed requirements, including fractional values, cleanly.
4. Add `minSupportedContract` to the published manifest alongside `contractVersion`. Include the actual addon version so consumers can identify a preview without treating its moving tag as a version.
5. Generate this metadata from the same configuration/version inputs used by the packaged provider. Do not introduce separately maintained copies.
6. Validate that the manifest agrees with the packaged provider across flavors. Keep the existing distinction between the provider's producing commit and its legacy Questie data-baseline commit.
7. Update provider API declarations/docs and release documentation if their published contracts change.

Focused validation:

- Supported floor, current contract, and backwards-compatible newer providers pass.
- Requirements below the floor, above the current contract, or malformed fail with useful messages.
- Packaging tests verify the manifest range, version, and agreement with the packaged runtime.
- Publish a provider release containing the new metadata before relying on it in Questie's release selector. Do not silently assume compatibility for older manifests missing the supported floor.

## Phase 2: Declare and enforce Questie's requirement

Owner: Questie. Build on phase 1.

Progress: steps 1–3 are implemented, including build/CI rejection of inconsistent or duplicate declarations and replacement of the hardcoded initialization requirement. The compatibility check gives an actionable message when invoked, but it is not yet an early startup guard. The API audit and file-load lifecycle work in steps 4–7 remain pending; the localization-correction feature check is intentionally retained.

1. Add this declaration to each supported flavor TOC:

   ```toc
   ## RequiredDeps: QuestieDB
   ## X-QuestieDB-Contract: 2
   ```

2. Remove the hardcoded requirement from initialization. Read the active TOC's declaration at runtime; use the same field in release tooling and CI.
3. Validate that supported flavor TOCs have valid, consistent requirements. Missing/malformed declarations fail builds rather than defaulting to a value.
4. Audit the APIs currently consumed by Questie against the declared contract. In particular, the existing extra check for localization corrections indicates that a contract-number match alone may not describe every requirement today. If needed, correct provider contract evolution and publish the supporting provider version before updating Questie's requirement.
5. Check compatibility before provider-dependent file-load accesses and initialization. Audit `Database/QuestieDB.lua`, support wrappers, localization, and other early consumers.
6. On incompatibility, prevent dependent initialization and show one actionable message with Questie's requirement, installed provider version, and supported range when available. Handle missing globals or missing `RequireContract` without causing another nil-access error.
7. Do not assume that throwing an error or returning from one TOC-loaded file stops subsequent files. Design and test the actual startup guard without scattering unnecessary checks throughout unrelated modules.

Focused validation:

- Tests for TOC parsing/consistency and supported/unsupported providers.
- Startup tests demonstrating that incompatibility reports clearly without cascading provider accesses or starting Questie.
- Update existing `Modules/QuestieInit.test.lua`, provider mock, and conformance tests as appropriate.
- Keep the required dependency for missing-addon/load-order handling.

## Phase 3: Select and validate a published provider

Owner: Questie, with provider metadata from phase 1.

1. Implement a small release resolver with these explicit policies:
   - `stable`: newest compatible published stable release.
   - `stable-or-prerelease`: prefer compatible stable; fall back only if none exists.
   - `prerelease`: explicitly select a compatible published prerelease, including the rolling preview.
   - Exact tag: use that release, still enforcing compatibility.
2. Exclude drafts. Define ordering explicitly for versioned releases and rolling preview; do not rely on API list order or the combined bundle string.
3. Check the required contract against the complete supported range. Older incompatible stable releases must not hide a compatible candidate elsewhere in the release list.
4. Treat API/authentication/download errors as errors, not as permission to fall back to prerelease.
5. Resolve once per build. Record release/asset identifiers, actual provider version, producing commit, and expected checksum.
6. Download and verify `QuestieDB-all.zip`. Validate archive paths and expected contents before extraction; reject unsafe paths, unexpected roots, and duplicate entries.
7. Handle a moving preview or emergency upstream replacement by verifying manifest/artifact consistency. Fail or perform a bounded fresh resolution if it changes; never combine mixed generations.
8. Use the actual preview version, including its development commit suffix, in the bundle identity. Do not use `preview` alone.

CI:

- Implement the [planned release compatibility checks](docs/questiedb-integration.md#planned-release-compatibility-checks): a required supported-release check and an advisory provider-master check. The current master conformance job is only the temporary migration check.
- Distinguish the contract declaration from a concrete CI reference. Keep a deliberately selected supported release as the repeatable required CI baseline; release packaging additionally tests whichever compatible artifact it resolves.
- Exercise the relevant actual provider APIs and baked packaging, not only the existing mock. A missing provider or skipped integration suite must fail the required check.
- If Questie promises support for an older contract/provider baseline, test that promise rather than only the newest provider.
- Report selected versions, commits, contract range, and failure diagnostics.

Focused resolver tests should cover stable preference, incompatible newest releases, explicit prerelease selection, fallback eligibility, missing metadata, download failures, and checksum mismatch. Use local fixtures, not live GitHub calls.

## Phase 4: Build the combined artifact

Owner: Questie.

1. Refactor `build.py` enough to accept an explicit Questie source version and produce a staged Questie addon without publishing anything.
2. Preserve expansion filtering and exclusion of tests/development files. Validate that every advertised flavor has both addon TOCs and its required files.
3. Combine staged Questie with the verified provider contents into exactly two top-level directories.
4. Keep each addon's TOC version independent. Name the archive using the component pair.
5. Preserve the addon-manager `release.json` format and point it at the combined filename. Do not confuse or overwrite it with QuestieDB's differently shaped manifest.
6. Write a separate bundle manifest recording:
   - Bundle identity and prerelease status.
   - Questie version and source commit.
   - QuestieDB version, source release/asset identity, producing commit, and downloaded archive checksum.
   - Required contract and provider supported range.
   - Supported flavors and final bundle filename/SHA-256.
7. Retain the provider manifest as provenance, separately from Questie's addon-manager metadata.
8. Mark the bundle prerelease if either component is prerelease.
9. Generate release notes identifying both components, including database-only updates.
10. Remove dependence on ambiguous nearest-tag discovery. Exclude bundle tags from any remaining source-version/changelog lookup; prefer explicit source refs.

Validation: small fixture-based packaging tests for archive layout, TOC versions, flavor coverage, metadata, and checksums, plus real-provider integration against the exact selected artifact. Hash stored artifacts for integrity; do not infer source changes merely from independently rebuilt ZIP hashes.

## Phase 5: Create and tag GitHub bundle releases

Owner: Questie.

1. Provide a release-creation action able to build either a new Questie version or an existing Questie source tag with a newer database. Resolve the source to an exact commit before building; do not silently use current branch contents for an old version.
2. Preflight remote state before expensive work:
   - An existing bundle tag/release fails, except in the separate repair path.
   - An existing Questie source tag is reusable only if it resolves to the requested source commit.
   - The same Questie version at a different source commit fails and requires a version bump.
   - Treat API failures differently from absence. Account for drafts and tags without releases.
3. Validate, build, and test without publishing credentials. Hand the approved artifacts to a dedicated publisher.
4. Under a publication lock, repeat collision checks and verify the artifact handoff before writing anything.
5. Create `v<questie-version>` if absent. Reuse it unchanged for database-only releases.
6. Create `bundle/v<questie-version>+v<database-version>` pointing to the Questie source commit. The bundle manifest identifies the provider commit.
7. Upload to a draft and expose the release only after its complete artifact set has been verified. Define recovery for interrupted drafts/orphaned tags without silently overwriting a completed release.
8. Set latest/prerelease explicitly so previews never displace stable releases and publishing an older source version does not accidentally change latest.
9. Reconcile `release.py` with action-owned tagging. Prevent tags created by the action from recursively triggering another release.
10. Support reading existing legacy `v*` tags. Do not rewrite historical tags/releases to adopt the new bundle scheme.

This action must not automatically publish to CurseForge.

## Phase 6: Manually publish an existing bundle to CurseForge

Owner: Questie.

Inputs:

- `release_tag`: exact bundle tag, or blank to resolve the latest stable bundle once.
- `publish_curseforge`: boolean confirmation, default false and mandatory for an upload.

Behavior:

1. Resolve an existing published GitHub bundle. Do not rebuild, choose a new provider, or modify the GitHub release.
2. Download and verify its bundle manifest and archive checksum. Use that release's notes and metadata rather than files from the current branch.
3. Check whether this bundle has already been published to CurseForge. If yes, fail; there is no CurseForge replacement option.
4. Upload the exact verified archive, with both component versions in its display identity and correct release type/flavor metadata.
5. Capture the returned CurseForge file ID and retain a durable publication receipt associated with the bundle identity and hash, outside the immutable bundle bytes.
6. Serialize duplicate-check/upload operations. Design recovery for an upload accepted by CurseForge when the action loses the response or fails before saving its receipt. Consult remote state or require manual reconciliation rather than blindly uploading again.
7. Keep the CurseForge secret confined to this explicitly authorized upload job. Never execute source build/test code with it available.

Before implementation, verify the current CurseForge API's duplicate lookup/receipt options and addon-manager behavior when a project bundles the independently installable `QuestieDB/` directory. Do not test these by publishing a live file.

## Phase 7: Add the GitHub-only repair path

- Separate explicit panic-button operation naming the exact target release, not an implicit latest target.
- No CurseForge publishing or replacement in this operation.
- Show the old and proposed provenance before replacement. Refuse immutable GitHub releases.
- Normal changes still bump versions. Do not silently move a Questie source tag; different source content requires a new Questie version.
- Prefer repair from retained, validated artifacts. Never re-resolve latest QuestieDB for an existing bundle identity.
- Serialize repairs with normal publication. Verify the complete artifact set and record the repair details.
- Explain that replacement is not atomic and does not update copies already downloaded elsewhere.
- Preserve any prior CurseForge receipt/hash and flag divergence. A GitHub repair must not make an already-published bundle eligible for another CurseForge upload.

## Validation and rollout

Implement in the numbered order, with phases 1 and 2 reviewed and validated before release workflow work.

Use fresh focused review for contract/API and startup changes, then for release security, credentials, tagging, concurrency, and partial-failure recovery. Run focused tests after fixes; use the repositories' broader required checks before merging. Inspect the final assembled ZIP locally without installing it into a daily-driver client.

Key end-to-end cases, simulated without publishing:

| Case | Expected result |
| --- | --- |
| New Questie and database pair | Create source tag, bundle tag, and GitHub bundle release |
| Same Questie version/commit, newer database | Reuse source tag; create a new bundle release |
| Same Questie version, changed source commit | Fail; require Questie version bump |
| Existing bundle creation requested | Fail unless explicit GitHub repair |
| GitHub-only bundle promoted later | Upload its existing bytes to CurseForge once |
| Already published CurseForge bundle | Fail; no replacement |
| Provider outside supported contract range | Reject in selection and at runtime |
| Stable-or-prerelease with no compatible stable | Select compatible prerelease; publish as prerelease |
| Stable download/API failure | Fail; do not silently fall back |
| Mutable provider assets change during download | Reject mixed content |
| Concurrent creation/publication or interrupted upload | No silent overwrite or blind duplicate upload |

Update [QuestieDB integration](docs/questiedb-integration.md), build/release instructions, provider docs, and release recovery instructions alongside implementation. No live publishing, tag changes, or daily-driver installation during development without explicit authorization.

## Remaining investigation

- Exact CurseForge receipt storage and remote reconciliation, based on verified API capabilities.
