limit=$1
echo "list all collections"

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    $APPWRITE_ENDPOINT/database/collections?limit=$limit)

echo "result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    listJson=$(echo $listJson | jq '.collections')
    echo $listJson > _list_collections.txt
else
    echo "ERROR listing collections: $message"
    exit 500;
fi
