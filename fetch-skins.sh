#!/usr/bin/env bash
set -e

URL="http://minetest.fensta.bplaced.net/api/v2/get.json.php?getlist"
PAGE="1"
PAGES="20"
PER_PAGE="100"
BUFF=/tmp/page.json

mkdir -p {meta,textures}
while true ; do
	echo "Fetching $PAGE from $PAGES ..."

	export retry=0
	while true ; do
		if ! curl -sSL "${URL}&page=${PAGE}&per_page=${PER_PAGE}" > $BUFF; then
			if [ $retry -gt 3 ] ; then
				exit 1
			fi
			let retry=retry+1
			continue
		fi
		break
	done

	jq -c '.skins[]' < /tmp/page.json | while read skin ; do
		id="`echo "$skin" | jq -r '.id'`"
		echo "$skin" | jq -r '[.name, .author, .license] | join("\n")' > meta/character_$id.txt
		echo "$skin" | jq -r '.img' | base64 -d > textures/character_$id.png
		echo "$skin" | jq -r '"Skin: ",.id, .name, .author, .license'
	done

	export PAGES=$(jq -r '.pages' < $BUFF)
	if [ x"${PAGE}" = x"${PAGES}" ] ; then
		break
	fi
	let PAGE=PAGE+1
done
