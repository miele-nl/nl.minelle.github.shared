functionId=$1
codeFile=$2
templateFile=$3
path=$4

echo "create tag for function $functionId with template $templateFile"
echo "code: $codeFile"

## build tag json
# tagJson=$(envsubst < $templateFile)
# echo $(jq --arg functionId $functionId \
#     --arg code $codeFile \
#     '{ 
#         functionId: $functionId, 
#         command: .command, 
#         code: $code 
#     }' <<< $tagJson) > tmp.json

# echo $(cat tmp.json)
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
