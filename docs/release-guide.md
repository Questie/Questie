## Questie release guide

### Prepare
Bump the Questie version in all flavor TOCs and commit it first. Workflows never bump versions or create commits.

Builds include the latest stable QuestieDB. For database-only updates, reuse the same Questie source revision.

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
