functionId=$1
tagId=$2

if [[ -z $1 || -z $2 || -z $APPWRITE_PROJECT || -z $APPWRITE_APIKEY || -z $APPWRITE_ENDPOINT ]]; then
    echo "required arguments missing"
    exit 1
fi


echo "update function $functionId set tag $tagId"

echo "{ \"functionId\": \"$functionId\", \"tag\": \"$tagId\" }" > tmp.json

echo $(cat tmp.json)

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    -H "Content-Type:application/json" \
    -X PATCH \
    -d @tmp.json \
    $APPWRITE_ENDPOINT/functions/$functionId/tag)

echo "update result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    echo "tag updated successfully"
else
    echo "ERROR updating tag: $message"
    exit 500;
fi
