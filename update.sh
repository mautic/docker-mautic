#!/bin/bash
set -e

echo "get current version"
current=$( curl -fsSL 'https://api.github.com/repos/mautic/mautic/tags' |tac|tac| \
	grep -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | \
	sort -urV | \
	head -n 1 )

# TODO - Expose SHA signatures for the packages somewhere
echo "get current SHA signature"
curl -s https://s3.amazonaws.com/mautic/releases/$current.zip -o mautic.zip
sha1="$(sha1sum mautic.zip | sed -r 's/ .*//')"

echo "update docker images"
travisEnv=
for variant in apache fpm beta-apache beta-fpm; do
	#set -x
	dir="$variant"
	echo "generating $current-$variant"

	sed -ri '
		s/^(ENV MAUTIC_VERSION) .*/\1 '"$current"'/;
		s/^(ENV MAUTIC_SHA1) .*/\1 '"$sha1"'/;
	' "$dir/Dockerfile"

	# To make management easier, we use these files for all variants
	cp common/* "$dir"/

	travisEnv='\n    - VARIANT='"$variant$travisEnv"
done

echo "update .travis.yml"
travis="$(awk -v 'RS=\n\n' '$1 == "env:" && $2 == "#" && $3 == "Environments" { $0 = "env: # Environments'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

echo "remove mautic.zip"
rm mautic.zip
