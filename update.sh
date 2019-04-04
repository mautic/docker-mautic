#!/bin/bash
set -e

declare -A cmd=(
	[apache]='apache2-foreground'
	[fpm]='php-fpm'
	[fpm-alpine]='php-fpm'
)

declare -A extras=(
	[apache]='\n# Enable Apache Rewrite Module\nRUN a2enmod rewrite'
	[fpm]=''
	[fpm-alpine]=''
)

declare -A base=(
	[apache]='debian'
	[fpm]='debian'
	[fpm-alpine]='alpine'
)

variants=(
	apache
	fpm
)

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
for variant in "${variants[@]}"; do
	dir="$variant"
	echo "generating $current-$variant"

	template="Dockerfile-${base[$variant]}.template"
	cp $template "$dir/Dockerfile"

	sed -E -i'' -e '
		s/%%VARIANT%%/'"$variant"'/;
		s/%%VARIANT_EXTRAS%%/'"${extras[$variant]}"'/;
		s/%%VERSION%%/'"$current"'/;
		s/%%VERSION_SHA1%%/'"$sha1"'/;
		s/%%CMD%%/'"${cmd[$variant]}"'/;
	' "$dir/Dockerfile"

	# To make management easier, we use these files for all variants
	cp common/* "$dir"/
done

echo "remove mautic.zip"
rm mautic.zip
