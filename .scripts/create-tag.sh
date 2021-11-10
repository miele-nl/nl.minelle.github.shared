functionId=$1
codeFile=$2
templateFile=$3
path=$4

if [[ -z $1 || -z $2 || -z $3 || -z $4 || -z $APPWRITE_PROJECT || -z $APPWRITE_APIKEY || -z $APPWRITE_ENDPOINT ]]; then
    echo "required arguments missing"
    exit 1
fi

echo "create tag for function $functionId with template $templateFile"
echo "code: $codeFile"

command=$(cat $path$templateFile | jq -r '.command')
echo $command

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    -F "command=$command" \
    -F "code=@$path$codeFile" \
    $APPWRITE_ENDPOINT/functions/$functionId/tags)

echo "create result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    tagId=$(jq -r '."$id"' <<< $listJson)
    echo "tag $tagId created successfully"
    echo $tagId > _create_tag.txt
else
    echo "ERROR creating tag: $message"
    exit 500;
fi
