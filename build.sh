#!/usr/bin/env bash
set -Eeuo pipefail

versions=( "$@" )
if [ "${#versions[@]}" -eq 0 ]; then
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

alpine_versions=(3.9 "edge")
latest_alpine=3.10
latest_boost=1.70.0
imagebase="westonsteimel/boost"
repos=("")

for version in "${versions[@]}"; do
    echo "Building Dockerfiles for Boost version ${version}."
    template=alpine

    for alpine_version in "${alpine_versions[@]}"; do
	    (
        cd "${version}/${template}/${alpine_version}"
        build_tag="${imagebase}:${version}-${template}${alpine_version}"
        echo "Building ${build_tag}..."
        time docker build --build-arg "CONCURRENT_PROCESSES=4" -t "${build_tag}" .

        for repo in "${repos[@]}"; do 
            repobase="${imagebase}"
            if [ "$repo" != "" ]; then
                repobase="${repo}/${imagebase}"
            fi
            docker tag "${build_tag}" "${repobase}:${version}-${template}${alpine_version}"
	        if [ "${version}" = "${latest_boost}" ]; then
                docker tag "${build_tag}" "${repobase}:${template}${alpine_version}"
            fi
            if [ "${alpine_version}" = "${latest_alpine}" ]; then
                docker tag "${build_tag}" "${repobase}:${version}"
                docker tag "${build_tag}" "${repobase}:${version}-${template}"
            fi
            if [ "${version}" = "${latest_boost}" ] && [ "${alpine_version}" = "${latest_alpine}" ]; then
                docker tag "${build_tag}" "${repobase}:latest"
                docker tag "${build_tag}" "${repobase}:${template}"
            fi
        done
        )
    done
done
