#!/bin/sh

ftpHost=$1
ftpUser=$2
ftpPassword=$3
remoteDir=$4
file=$5

if [[  -z $1 || -z $2 || -z $3 || -z $4 || -z $5 ]]; then
    echo "required arguments missing"
    exit 1
fi

resp=$(eval "ftp -p -n $ftpHost <<END_SCRIPT
quote USER $ftpUser
quote PASS $ftpPassword
binary
cd $remoteDir
put $file
quit
END_SCRIPT")

[[ -z "$resp" ]] && exit 0

echo $resp
exit 1