# Version-bump setup and troubleshooting

Configuration snapshot checked through GitHub's read-only API on 2026-09-25 (UTC).
Links below point to the actual settings. Recheck them when debugging; repository settings
can change independently of this document. No credential values are recorded here.

The workflow prepares a source version, not a published release. Integration with the
publish flow is a follow-up. At this snapshot, [PR #7882](https://github.com/Questie/Questie/pull/7882)
was open and the workflow had not been run on GitHub.

## How the pieces fit together

```text
A repository writer starts Bump version on master
  -> a Release Maintainers member approves the version-bump environment
  -> the job receives the app credentials
  -> a short-lived, repository-scoped app token is created
  -> versionbump.py updates the flavor TOCs
  -> the workflow creates the version commit and v<version> tag
  -> GitHub checks branch protection and both applicable tag rulesets
  -> commit and tag are pushed atomically
```

The normal approval path above has an administrator bypass, described below. Approval
controls when a job can obtain credentials; it does not give the approving person the
app's private key or make the app inherit that person's permissions.

## What we created or changed

### GitHub App: Questie Version Bump

| Setting | Value / purpose |
| --- | --- |
| Owner | Questie organization |
| App slug | `questie-version-bump` |
| App ID | `5079009` |
| Installation ID | `164960542` |
| Registration | [App settings](https://github.com/organizations/Questie/settings/apps/questie-version-bump) |
| Installation | [Installed repository access](https://github.com/organizations/Questie/settings/installations/164960542) |
| Repository selection | Selected repositories; configured by the maintainer for Questie only |
| Required permission | Contents: read/write; Metadata: read is automatic |
| Current extra permission | Actions: write is still configured and installed. It is not needed for this workflow and can be removed. |

The app was created for workflow authentication instead of using a maintainer's personal
access token. Its private key generates short-lived installation tokens. The workflow
explicitly requests only Contents write and only the current repository, even though
the installation currently grants the extra Actions permission.

The API confirmed selected-repository mode, but the authenticated CLI could not enumerate
that installation's repository list. Verify the Questie-only selection using the
installation link when auditing access.

The workflow uses `actions/create-github-app-token@v3.2.0`. That action normally revokes
the generated token during job cleanup. The app's private key remains a long-lived secret
until revoked; treat it as sensitive even though the generated tokens are short-lived.

### Team: Release Maintainers

[Manage the team](https://github.com/orgs/Questie/teams/release-maintainers)

- Slug: `release-maintainers`; team ID: `19733955`.
- Visibility: visible to organization members, not secret. Secret teams cannot be used
  in ruleset bypass lists.
- Added to `Questie/Questie` with **Write** access. This lets members start manual workflows.
- Added as a **required reviewer** on the `version-bump` environment.
- Added with **Always allow** to the **Version tag creators** ruleset.
- Not added to the direct `master` push allowlist.
- Not added to the **Protect bundle tags** or old **Tag Creators** bypass lists.

The last three distinctions are intentional to record: team membership is not a blanket
bypass of every release protection. Some members may separately have broader rights
through the existing individual maintainer entries.

Repository access is managed under [Settings → Collaborators and teams](https://github.com/Questie/Questie/settings/access).

### Environment: version-bump

[Manage environments](https://github.com/Questie/Questie/settings/environments)

| Setting | Recorded configuration |
| --- | --- |
| Required reviewers | Release Maintainers team |
| Approval threshold | One listed reviewer is sufficient |
| Prevent self-review | Off; a reviewer can approve a run they started |
| Administrator bypass | Allowed; an administrator can bypass the wait |
| Deployment branches and tags | Selected branches and tags |
| Allowed source | Branch `master` only; no tag rules |
| Environment variable | `VERSION_BUMP_APP_CLIENT_ID` |
| Environment secret | `VERSION_BUMP_APP_PRIVATE_KEY` |

The variable holds the app's **Client ID**, not its numeric App ID. The secret holds the
entire generated PEM private key, including its BEGIN/END lines. Both names were confirmed
present; secret contents were not read or tested.

The workflow job declares `environment: version-bump`. For normal runs it waits for
approval before starting and receiving environment secrets, even if a reviewer started
it. The branch policy limits which source code can run with these credentials. Allowing
zero source tags does not prevent the job from creating an output version tag.

### Existing master branch protection

[Manage branch protection](https://github.com/Questie/Questie/settings/branches)

We added the `questie-version-bump` app to **Restrict who can push to matching branches**
for `master`. The six existing individual maintainers remain allowed:
`Yttrium-tYcLief`, `Cabro`, `Logonz`, `Muehe`, `Sommos`, and `BreakBB`.
No team is currently listed there.

Force pushes and branch deletion remain disabled. At the snapshot, the legacy rule had
no required PR reviews, status checks, or signed commits, and administrator enforcement
was off. Those were existing settings, not additional protections introduced by this work.

Adding the app to the push allowlist does not give it a blanket bypass of other rules.
Its Contents permission is nevertheless broader than editing TOCs: it can make ordinary
commits on branches it can write. Approval and trusted workflow code remain important.

### Tag rulesets

[Manage all rulesets](https://github.com/Questie/Questie/settings/rules)

All three rulesets below are active. Matching rulesets apply together: a bypass in one
does not bypass a different matching ruleset.

#### Protect bundle tags: expanded to cover version tags

[Settings, ID 23835820](https://github.com/Questie/Questie/settings/rules/23835820)

We retained the existing rule and added the `v*` include pattern. Its UI target patterns are:

- `bundle/v*`
- `bundle/curse/v*`
- `bundle/wago/v*`
- `v*`

It restricts **updates**, **deletions**, and **force pushes**. It does not restrict creations.
The existing six individual maintainers listed above have **Always allow** bypass.
Neither the app nor the Release Maintainers team has bypass here.

This is what prevents the app from replacing or deleting a version tag after creating it.
Do not add the app to this bypass list to fix a creation failure.

#### Version tag creators: new creation-only rule

[Settings, ID 24023153](https://github.com/Questie/Questie/settings/rules/24023153)

- Target: include `v*`.
- Only enabled restriction: **Restrict creations**.
- **Always allow** bypass: Questie Version Bump app and Release Maintainers team.

Update, deletion, and force-push restrictions are deliberately off in this ruleset.
The separate protection ruleset enforces them without giving the app bypass.
A maintainer outside the team does not gain creation bypass from the protection rule alone.

#### Tag Creators: excluded version tags from the old rule

[Settings, ID 17635317](https://github.com/Questie/Questie/settings/rules/17635317)

This existing rule targets all tags except:

- `bundle/v*`
- `bundle/curse/v*`
- `bundle/wago/v*`
- `v*` (the exclusion we added)

It still restricts creations, updates, deletions, and force pushes for other tags.
Its existing six individual maintainer bypass entries were unchanged.

The `v*` exclusion is necessary: otherwise this older creation restriction would still
block the app even though **Version tag creators** allows it.

### Workflow and helper

- [`.github/workflows/versionbump.yml`](../.github/workflows/versionbump.yml): new manual
  **Bump version** workflow, restricted to `refs/heads/master`.
- [`versionbump.py`](../versionbump.py): restored version helper; `--no-git` lets the
  workflow own staging, committing, tagging, and pushing. Its standalone Git sequence
  stops on the first failure so a failed commit cannot tag the previous HEAD.
- [`docs/release-guide.md`](release-guide.md): operator instructions.
- Development branch: `automation/version-bump`; [PR #7882](https://github.com/Questie/Questie/pull/7882).

The workflow validates the version input, updates every flavor registered in `build.py`,
and leaves the unsupported-client `Questie.toc` alone. It creates `Bump version to vX.Y.Z`
and tag `vX.Y.Z`, refusing an existing tag or a no-change commit.

The original initiator (`github.actor` / `github.actor_id`) is the commit **author**, using
their GitHub noreply address. The app bot is the **committer** and push identity. Reruns
retain the original author, not the rerunning user. Approvers are recorded in deployment
history rather than substituted as commit authors.

The built-in `GITHUB_TOKEN` is limited to Contents read in this workflow; checkout/push
use the app token. The repository's broader default workflow permission remains write,
but this workflow overrides it. App-authenticated pushes can trigger normal push CI.
There is no automatic dispatch of the publishing workflow here.

## Adding or removing a release maintainer

For this approved version-bump flow, add or remove membership in
[Release Maintainers](https://github.com/orgs/Questie/teams/release-maintainers/members).
The team's existing repository, environment, and creation-rule entries cover normal use.
A new member does not need their own app, key, or secret.

Manual pushes to `master`, or updates/deletions of protected tags, are separate rights.
If those are required, review the branch allowlist and relevant protection bypass lists
explicitly. Do not grant them merely to make the workflow usable.

Removing a person from the team does not remove any individual access or bypass entries
they already have. Audit those separately, including the six legacy maintainer entries.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Bump version / Run workflow is missing | The workflow must be merged onto default branch `master`. It was still in an open PR at this snapshot. |
| Job is skipped or the environment refuses it | Select branch `master`, not a version tag or feature branch. Both the job condition and environment enforce this. |
| Waiting for review | A Release Maintainers member must approve the environment. Starting a run does not automatically approve it. |
| A team cannot be selected as ruleset bypass | It must be visible, not secret. Confirm its repository access too. |
| The app cannot be selected in branch protection | Confirm it is installed on Questie and has **Contents write**, not merely Actions write. Approve changed installation permissions if prompted. |
| Create app token fails | Check the environment names, Client ID, complete PEM value, app installation, and requested Contents permission. Never print the key or token while debugging. |
| Push to master is denied | Check the app is still on the branch push allowlist and whether new PR/check/signature requirements now apply. Git author identity does not grant push rights. |
| Creating vX.Y.Z is denied | Check app bypass in Version tag creators, its `v*` target, and the `v*` exclusion in old Tag Creators. Check for additional organization/repository rulesets. |
| Updating or deleting an existing tag is denied | Expected for the app. Do not grant protection bypass as a workaround. Choose a new version or involve an authorized maintainer. |
| Existing tag / nothing to commit | The workflow will not overwrite a tag or create an empty bump commit. Check the current TOCs and select the intended new version. |
| Non-fast-forward / atomic push failed | Master may have advanced while the job waited for approval. Start a new workflow run against current master after checking refs. Rerunning an old run retains its selected source SHA. |
| Push reports failure after a connection problem | Check both remote refs and the workflow logs before retrying; the server might have accepted both before the client lost the response. Atomic means both or neither, not that every client error proves neither was accepted. |

### Rotating or revoking credentials

Generate a replacement private key in the app settings, update the environment secret,
then revoke the old key after the replacement is confirmed. Do not commit PEM files or
paste them into logs, issues, or chat. For suspected compromise, suspend/uninstall the
app or revoke its credentials promptly rather than waiting for a normal rotation.

### Safe checks

These GitHub CLI commands are read-only. They show settings and secret names, never
secret values. Repository/organization administrative access may be required.

```sh
gh api orgs/Questie/teams/release-maintainers/repos --paginate \
  --jq '.[] | select(.full_name == "Questie/Questie") | {full_name, permissions}'
gh api repos/Questie/Questie/environments/version-bump
gh api repos/Questie/Questie/environments/version-bump/deployment-branch-policies
gh api repos/Questie/Questie/environments/version-bump/secrets --jq '.secrets[].name'
gh api repos/Questie/Questie/branches/master/protection
for id in 23835820 24023153 17635317; do
  gh api "repos/Questie/Questie/rulesets/$id"
done
```

## Verification and remaining limits

Read-only checks confirmed the team repository role, environment policy and credential
names, branch allowlist, app permissions, and all three rulesets. The secret itself and
installation-token authentication were not tested. Selected-repository scope should be
confirmed in the installation UI as noted above.

Local validation covered TOC updates, Git failure handling, atomic push rejection, and
author/committer attribution using temporary files and Git remotes. After rebasing the PR,
the full Lua suite passed with 2,056 tests. No live version-bump workflow was dispatched.
The first approved run after merge is still the end-to-end check.
