#!/bin/bash

set -euo pipefail

SRCPATH=${1}
FILENAME=$(basename "${SRCPATH}")
NAME=${FILENAME%.*}
TMPDIR="${HOME}/tmp/gogextract"
TARDIR="${TMPDIR}/tarballs"
TARBALL="${TARDIR}/${NAME}.tar"
ARCH=$(flatpak --default-arch)
MAKEROPTS=""

TMPDIR=$(mktemp -d)
GAMEINFO="${TMPDIR}/data/noarch/gameinfo"

unzip -q ${SRCPATH} data/noarch/gameinfo -d ${TMPDIR} || true

GAMENAME=$(head -n 1 ${GAMEINFO} | sed 's/[^[:alpha:][:digit:]]//g')
GOGVERSION=$(head -n 2 ${GAMEINFO} | tail -n 1 | sed 's/[^[:alpha:][:digit:]\.]//g')
GAMEVERSION=$(tail -n 1 ${GAMEINFO} | sed 's/[^[:alpha:][:digit:]\.]//g')
SHASUM=$(sha256sum ${SRCPATH} | awk '{print $1}')
SIZE=$(ls -l ${SRCPATH} | awk '{print $5}')

if [ ${GAMEVERSION} == "na" ]
then
    GAMEVERSION=0
fi

MAKEROPTS="${FILENAME} --name ${GAMENAME} --size ${SIZE} --sha ${SHASUM} --branch ${GOGVERSION}-${GAMEVERSION}"

if [ -e overrides/starter-${GAMENAME} ]
then
    echo "Starter override found."
    MAKEROPTS="${MAKEROPTS} --startoverride overrides/starter-${GAMENAME}"
fi

./json-maker.py ${MAKEROPTS} > gen_com.gog.${GAMENAME}.json
echo "Generation complete."
