---
name: release-docker-images
description: Build and publish the official Mautic Docker images (mautic/mautic on Docker Hub and ghcr.io/mautic/docker-mautic) with the "Build and publish a Docker image" GitHub Actions workflow. Use when new Mautic versions were released, when PHP or base image security releases require a rebuild of existing tags, or when a maintainer asks how to trigger, monitor, or verify an image release.
---

# Release Mautic Docker images

Images are built by `.github/workflows/build_publish.yml`, which only runs on manual dispatch (`workflow_dispatch`). One run builds one Mautic version for both flavours (`apache`, `fpm`) and both platforms (`linux/amd64`, `linux/arm64`), then pushes to Docker Hub (`mautic/mautic`) and GHCR (`ghcr.io/mautic/docker-mautic`).

Triggering a run publishes public images and overwrites existing tags. Confirm the versions and tag flags with the user before starting runs.

## 1. Check prerequisites

- `gh auth status` works and the user has write access to `mautic/docker-mautic`.
- No publish run is already in progress:
  ```sh
  gh run list -R mautic/docker-mautic -w build_publish.yml -L 5
  ```
- The workflow on `main` is the one you expect. Read `.github/workflows/build_publish.yml` on `origin/main`, especially the "Compute BASE_TAG" step, which maps the Mautic major version to a PHP version. An unsupported major makes the run fail.

## 2. Pick versions

Find the versions to build:

```sh
gh release list -R mautic/mautic -L 10
```

Each version must exist as `mautic/recommended-project` on Packagist, because the Dockerfile installs from it:

```sh
curl -s https://repo.packagist.org/p2/mautic/recommended-project.json \
  | python3 -c 'import json,sys;print([v["version"] for v in json.load(sys.stdin)["packages"]["mautic/recommended-project"]][:15])'
```

For a PHP or base image security rebuild, use the current latest patch version of each supported line (the same versions that were published last).

## 3. Decide tag flags

Every run always pushes `<version>-<flavour>` and `<version>-<YYYYMMDD>-<flavour>`. The inputs control the moving tags:

| Input | Set to `true` when | Tag |
|---|---|---|
| `overwrite_latest_minor` | The version is the newest patch in its minor line | `<major>.<minor>-<flavour>` |
| `overwrite_latest_major` | The version is the newest release in its major line | `<major>-<flavour>` |
| `tag_as_latest` | The version is the newest release overall (only one run) | `latest` (apache only) |

Check for newer minor lines before setting the major flag, for example with `gh release list -R mautic/mautic -L 200`. Never build an older patch with these flags set, because it moves the tags backwards.

## 4. Trigger the runs

One run per version, all from `main`:

```sh
gh workflow run build_publish.yml -R mautic/docker-mautic --ref main \
  -f mautic_version=<version> \
  -f overwrite_latest_major=<true|false> \
  -f overwrite_latest_minor=<true|false> \
  -f tag_as_latest=<true|false>
```

The command prints the run URL. Alternatively, use "Run workflow" on https://github.com/mautic/docker-mautic/actions/workflows/build_publish.yml.

## 5. Monitor

A run takes about 1-2 hours, mostly for the arm64 build under QEMU emulation. Poll the status instead of using `gh run watch`, which can exit before a long run finishes:

```sh
for id in <run-id> ...; do
  while [ "$(gh run view -R mautic/docker-mautic "$id" --json status -q .status)" != "completed" ]; do sleep 30; done
  echo "$id: $(gh run view -R mautic/docker-mautic "$id" --json conclusion -q .conclusion)"
done
```

Run it in the background. On failure, inspect with `gh run view -R mautic/docker-mautic <run-id> --log-failed`.

## 6. Verify

Check that the tags exist and were updated today:

```sh
for t in <version>-apache <version>-fpm <major>.<minor>-apache <major>-apache latest; do
  curl -s "https://hub.docker.com/v2/repositories/mautic/mautic/tags/$t" \
    | python3 -c "import json,sys;print('$t', json.load(sys.stdin).get('last_updated','MISSING'))"
done
```

Check the PHP version in the published image:

```sh
docker buildx imagetools inspect mautic/mautic:<version>-apache \
  --format '{{json (index .Image "linux/amd64").Config.Env}}' | grep -o 'PHP_VERSION=[0-9.]*'
```

## PHP security rebuilds

The Dockerfile uses floating base tags such as `php:8.3-apache-bookworm`, and the workflow has no build cache, so every run pulls the current base image. To find out if a rebuild picks up a new PHP release, compare the latest release on https://www.php.net/releases/ with the base image:

```sh
docker buildx imagetools inspect php:8.3-apache-bookworm \
  --format '{{json (index .Image "linux/amd64").Config.Env}}' | grep -o 'PHP_VERSION=[0-9.]*'
```

If the base image already has the new version, re-run the workflow for the current versions with the same tag flags as their last release. If it does not, wait for the official `php` image to be updated.
