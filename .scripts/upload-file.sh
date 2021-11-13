#!/bin/sh

ftpHost=$1
ftpUser=$2
ftpPassword=$3
localDir=$4
remoteDir=$5
file=$6

if [[  -z $1 || -z $2 || -z $3 || -z $4 ]]; then
    echo "required arguments missing"
    exit 1
fi

ftp -n $ftpHost <<END_SCRIPT
quote USER $ftpUser
quote PASS $ftpPassword
binary
lcd $localDir
cd $remoteDir
put $file
quit
END_SCRIPT
exit 0