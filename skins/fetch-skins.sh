#!/usr/bin/env bash
set -e

URL="http://minetest.fensta.bplaced.net/api/v2/get.json.php"
BUFF=/tmp/page.json

get_licenses() {
	echo "Downloading licenses"
	curl -sSL "${URL}?licenses=true" > /tmp/licenses.json
}

extract_skins() {
	# Check if single skin in input
	jq -c '.skins[]' < $BUFF >/dev/null 2>&1 || {
		cp $BUFF $BUFF.aux
		( echo '{ "skins": [ ' ; cat $BUFF.aux ; echo " ] } " )> $BUFF
	}
	# Update license strings
	jq -c -r '.licenses[] | [(.id|tostring), .name] | join(" ")' < /tmp/licenses.json |\
		while read id l ; do
			sed -i $BUFF -e "s,\"license\": $id,\"license\":\"$l\",g"
		done
	# Loop over JSON data and extracts it
	jq -c '.skins[]' < $BUFF | while read skin ; do
		id="`echo "$skin" | jq -r '.id'`"
		echo -n "$skin" | jq -r '[(.name|tostring), (.author|tostring), .license] | join("\n")' > meta/character_$id.txt
		echo -n "$skin" | jq -r '.img' | base64 -d > textures/character_$id.png
		echo "$skin" | jq -r '["Skin: ", (.id|tostring), (.name|tostring), (.author|tostring), .license] | join(" ")'
	done
}

get_licenses
mkdir -p {meta,textures}
case $1 in
	*.list)
		echo "Fetching skins from list: $1"
		cat $1 | while read id ; do
			echo "Downloading skin $id ..."
			
			export retry=0
			while true ; do
				if ! curl -sSL "${URL}?getsingle=true&outformat=base64&id=${id}" > $BUFF; then
					if [ $retry -gt 3 ] ; then
						exit 1
					fi
					let retry=retry+1
					continue
				fi
				break
			done

			extract_skins
		done
	;;
	"")
		echo "Fetching all skins"
		export PAGE="1" PAGES="20" PER_PAGE="150"

		while true ; do
			echo "Fetching batch $PAGE/$PAGES ($PER_PAGE)..."

			export retry=0
			while true ; do
				if ! curl -sSL "${URL}?getlist=true&page=${PAGE}&per_page=${PER_PAGE}" > $BUFF; then
					if [ $retry -gt 3 ] ; then
						exit 1
					fi
					let retry=retry+1
					continue
				fi
				break
			done

			extract_skins

			export PAGES=$(jq -r '.pages' < $BUFF)
			if [ x"${PAGE}" = x"${PAGES}" ] ; then
				break
			fi
			let PAGE=PAGE+1
		done
	;;
esac
