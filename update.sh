#!/bin/bash
set -e

current="$(curl -A 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36' -sSL 'https://www.mautic.org/latest.json' | sed -r 's/^.*"current":"([^"]+)".*$/\1/')"

# TODO - Expose SHA signatures for the packages somewhere
wget -O mautic.zip https://s3.amazonaws.com/mautic/releases/$current.zip
sha1="$(sha1sum mautic.zip | sed -r 's/ .*//')"

for variant in apache fpm; do
	(
		set -x

		sed -ri '
			s/^(ENV MAUTIC_VERSION) .*/\1 '"$current"'/;
			s/^(ENV MAUTIC_SHA1) .*/\1 '"$sha1"'/;
		' "$variant/Dockerfile"

        # To make management easier, we use these files for all variants
		cp docker-entrypoint.sh "$variant/docker-entrypoint.sh"
		cp makeconfig.php "$variant/makeconfig.php"
		cp makedb.php "$variant/makedb.php"
	)
done

rm mautic.zip
