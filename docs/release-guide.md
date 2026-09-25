## Questie release guide

### Prepare
Run the manual **Bump version** workflow on `master` and enter a version without the `v` prefix, for example `12.0.1`. A reviewer must approve the `version-bump` environment before the job starts, even when the reviewer started the run. Other branches and tags are skipped.

It updates the Version and Title fields in all supported flavor TOCs, leaves the unsupported-client `Questie.toc` unchanged, commits as `Bump version to v12.0.1`, and creates tag `v12.0.1`. The branch commit and tag are pushed together; a rejected push publishes neither. Existing tags and unchanged versions fail rather than being overwritten or retagged. Branch protection still applies.

This only prepares the source version. It does not create a GitHub release or upload to CurseForge/Wago. The workflow must exist on the default branch before GitHub offers **Run workflow**. Then select the prepared tag in **Build and publish bundle** to build that exact source commit.

For a local bump, run `uv run --no-project versionbump.py 12.0.1` from a clean checkout root. This creates a local commit and tag but does not push. Add `--no-git` to only edit the TOCs. Failed Git commands stop the script; successful earlier steps are not rolled back.

Builds include the latest stable QuestieDB. For database-only updates, reuse the same Questie source revision.

### Version-bump permissions

The `version-bump` environment must allow only branch `master`, require maintainer approval, and contain:
- Variable `VERSION_BUMP_APP_CLIENT_ID`: the app's Client ID.
- Secret `VERSION_BUMP_APP_PRIVATE_KEY`: its complete PEM private key.

Install the app only on Questie with Contents read/write permission. The workflow requests a short-lived token limited to that repository and permission; it does not use the initiating user's credentials. The original workflow initiator (`github.actor`) is recorded as the commit author using their GitHub noreply address; the app's bot account is the committer. Reruns keep the original author, and environment approvals remain in GitHub's deployment audit history.

Allow the app to push to `master`, but leave branch deletion and force pushes blocked. For `v*` tags, give the app bypass only on a creation-only ruleset. A separate ruleset must still block updates, deletion and force pushes without app bypass. Exclude `v*` from any older creation rule that would otherwise block the app. Maintainer bypass entries remain independent of the app.

The workflow does not change these settings. If authentication or a protection rule rejects the atomic push, neither the branch commit nor the tag is published.

### Preview
Open [GitHub Actions](https://github.com/Questie/Questie/actions) → **Build and publish bundle**.

Select the intended source ref:
- Check **(--dry-run)**.
- Check **(--release)** for a normal release; leave it unchecked for a prerelease.

Tests run first, followed by **Build bundle**. Inspect the run summary and download **release-bundle** to check the ZIP, manifest, and notes. Artifacts remain available for 7 days.

No release or external upload occurs during a dry run.

### Publish
Run again with **(--dry-run) unchecked**.

A separate GitHub job publishes the exact built files. Release titles look like:
```text
v12.0.0+v1.0.3
v12.0.0-pre.abc1234+v1.0.3
```

Git tags retain the `bundle/` prefix. Existing releases aren't overwritten.

### CurseForge and Wago
Select **Upload to CurseForge/Wago** in the main workflow, or run either separately:
- **Upload existing bundle to CurseForge**
- **Upload existing bundle to Wago**

They download the published GitHub bundle without rebuilding. Manual runs default to `latest` stable. Enter the exact bundle tag for a prerelease or older release.

Prereleases upload as **beta** on both platforms.

Before reserving or uploading, both scripts check the tag's component versions against `release.json`, verify Questie's source commit against the tag, and require the ZIP filename to match the manifest and tag. Beta tags must include that commit's seven-character prefix.

This rejects mislabeled bundles, not older releases whose metadata agrees. It does not inspect the ZIP's contents.

### Failed external uploads
Reservation tags prevent duplicate attempts. Check the platform and previous workflow before retrying.

Only remove the reservation if no upload was accepted and no attempt is still running. Failure logs provide the removal command.

### Announcements
GitHub notes include both components' full current-release notes. Generate announcement deltas with:

```sh
python3 release_notes.py <previous-bundle-tag> latest
```

For the first new-format bundle, use its GitHub notes directly.
