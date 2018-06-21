#!/usr/bin/env bash
set -Eeuo pipefail

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
	echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
	echo "$@" | sed -e 's/[\/&]/\\&/g' | sed -e ':a;N;$!ba;s/\n/\\n/g'
}

alpine_versions=(3.6 3.7)
declare -A boost_checksums
boost_checksums=(["1.67.0"]="8aa4e330c870ef50a896634c931adf468b21f8a69b77007e45c444151229f665" ["1.66.0"]="bd0df411efd9a585e5a2212275f8762079fed8842264954675a4fddc46cfcf60")

for version in "${versions[@]}"; do
    echo "Generating Dockerfiles for Boost version ${version}."
    template=alpine
    boost_url_dir=boost_${version//./_}
    checksum=${boost_checksums[$version]}
    echo "Generating templates for ${template}"

    for alpine_version in ${alpine_versions[@]}; do
	mkdir -p $version/$template/$alpine_version
        
	sed -r \
	    -e 's!%%TAG%%!'"$alpine_version"'!g' \
	    -e 's!%%BOOST_VERSION%%!'"$version"'!g' \
	    -e 's!%%BOOST_CHECKSUM%%!'"$checksum"'!g' \
	    -e 's!%%BOOST_URL_DIR%%!'"$boost_url_dir"'!g' \
            "Dockerfile-${template}.template" > "$version/$template/$alpine_version/Dockerfile"
	echo "Generated ${version}/${template}/${alpine_version}/Dockerfile"
    done
done
