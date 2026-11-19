---
name: release-docker-images
description: Trigger the "Build and publish a Docker image" GitHub Actions workflow that publishes the official Mautic Docker images. Use when new Mautic versions were released, when a PHP or base image security release requires a rebuild, or when a maintainer asks how to trigger an image release.
---

# Release Mautic Docker images

`.github/workflows/build_publish.yml` runs only on manual dispatch. One run builds one Mautic version (apache and fpm, amd64 and arm64) and pushes it to Docker Hub (`mautic/mautic`) and GHCR. It needs write access to `mautic/docker-mautic` and publishes public images, so confirm versions and flags before triggering.

## Tag flags

Every run pushes `<version>-<flavour>` and `<version>-<YYYYMMDD>-<flavour>`. Set the other flags from the current Mautic releases (`gh release list -R mautic/mautic`):

| Input | `true` when the version is | Tag |
|---|---|---|
| `overwrite_latest_minor` | the newest patch in its minor line | `<major>.<minor>-<flavour>` |
| `overwrite_latest_major` | the newest release in its major line | `<major>-<flavour>` |
| `tag_as_latest` | the newest stable release overall | `latest` |

Recompute the flags for every release, also for rebuilds. Copying old flags can move tags back to an older version.

## Trigger

One run per version:

```sh
gh workflow run build_publish.yml -R mautic/docker-mautic --ref main \
  -f mautic_version=<version> \
  -f overwrite_latest_major=<true|false> \
  -f overwrite_latest_minor=<true|false> \
  -f tag_as_latest=<true|false>
```

Or use "Run workflow" on https://github.com/mautic/docker-mautic/actions/workflows/build_publish.yml.

For a PHP security rebuild, rebuild the current versions. The base images use floating tags like `php:8.3-apache-bookworm`, so a new run picks up the latest PHP patch once the official `php` image has it.

## Monitor

A run takes about 1-2 hours. Check with `gh run list -R mautic/docker-mautic -w build_publish.yml`. If a run fails, retry the failed jobs with `gh run rerun -R mautic/docker-mautic <run-id> --failed`.
