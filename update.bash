#!/bin/bash
# set -xeu # for debug
TAR_DIR="tmp_for_textlint"
USER="dbgroup-nagoya-u"
REPOSITORY="test-public-textlint-settings"

REPOSITORY_URL="https://github.com/${USER}/${REPOSITORY}"

# Package check
ESC=$(printf '\033')
RED="${ESC}[31m"
if ! command -v wget &> /dev/null
then
    echo "wget could not be found."
    printf "Type ${RED}%s${ESC}[m\n" 'sudo apt install wget'
    exit
fi
if ! command -v jq &> /dev/null
then
    echo "jq could not be found."
    printf "Type ${RED}%s${ESC}[m\n" 'sudo apt install jq'
    exit
fi

# Download from the latest tags
curl --silent https://api.github.com/repos/${USER}/${REPOSITORY}/tags > res.json
tag_latest=$(jq '.[] | .name' res.json | sort -rV | head -n1 | sed 's/"//g')
latest_file="${tag_latest}.tar.gz"
rm res.json
wget ${REPOSITORY_URL}/archive/${latest_file}

mkdir ${TAR_DIR} && tar -zxvf ${latest_file} -C ${TAR_DIR} --strip-components 1
rm ${latest_file}

(
  pushd ${TAR_DIR}
  dirarray=($(find . -mindepth 1 -type d))

  popd
  for dirname in ${dirarray[@]}; do
    mkdir -p ${dirname}
  done

  pushd ${TAR_DIR}
  for file in $(find . -type d \( -path './.git' -o -path './dir' \) -prune -false -o -type f -not -name 'README.md' -not -name 'paper.txt'); do
    mv ${file} ../${file}
  done
)
rm -rf ${TAR_DIR}

ESC=$(printf '\033')
GREEN="${ESC}[32m"
printf "${GREEN}%s${ESC}[m\n" 'Update paper-lint settings successfully!'
