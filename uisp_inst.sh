#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

temp="/tmp/unms-install"

args="$*"
version=""
branch="master"

branchRegex=" --branch ([^ ]+)"
if [[ " ${args}" =~ ${branchRegex} ]]; then
  branch="${BASH_REMATCH[1]}"
fi
echo "branch=${branch}"

repo="https://uisp.ui.com/v1/${branch}"

versionRegex=" --version ([^ ]+)"
if [[ " ${args}" =~ ${versionRegex} ]]; then
  version="${BASH_REMATCH[1]}"
fi

if [ -z "${version}" ]; then
  latestVersionUrl="${repo}/latest-version"
  if ! version=$(curl -fsS "${latestVersionUrl}"); then
    echo >&2 "Failed to obtain latest version info from ${latestVersionUrl}"
    exit 1
  fi
fi
echo version="${version}"

rm -rf "${temp}"
if ! mkdir "${temp}"; then
  echo >&2 "Failed to create temporary directory"
  exit 1
fi

cd "${temp}"
echo "Downloading installation package for version ${version}."
packageUrl="${repo}/unms-${version}.tar.gz"
if ! curl -sS "${packageUrl}" | tar xzf -; then
  echo >&2 "Failed to download installation package ${packageUrl}"
  exit 1
fi

if [ -d /var/lib/docker-desktop ] && [ ! -d /var/lib/docker ]; then
    ln -s /var/lib/docker-desktop /var/lib/docker
fi

# /tmp/unms-install/install-full.sh
# echo "Docker compose version: ${DOCKER_COMPOSE_VERSION}"
#sed -i -E "s#(DOCKER_COMPOSE_VERSION=\"\$\(docker-compose -v | sed 's/.*version )#\1v?#" /tmp/unms-install/install-full.sh
sed -i -E 's#version \\#version v*\\#' /tmp/unms-install/install-full.sh
#sed -i -E 's#version \\\(\[0-9\]#version v?\\\(\[0-9\]#' /tmp/unms-install/install-full.sh

#sed -i -E 's|(^\s*echo \"Docker compose version:.*$)|  DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION//Docker Compose version v/}\n\1|' /tmp/unms-install/install-full.sh




chmod +x install-full.sh
./install-full.sh ${args} --version "${version}"

cd ~
if ! rm -rf "${temp}"; then
  echo >&2 "Warning: Failed to remove temporary directory ${temp}"
fi
