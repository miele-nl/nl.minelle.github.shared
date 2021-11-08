limit=$1
echo "list all functions"

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    $APPWRITE_ENDPOINT/functions?limit=$limit)

echo "result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    listJson=$(echo $listJson | jq '.functions')
    echo $listJson > _list_functions.txt
else
    echo "ERROR listing functions: $message"
    exit 500;
fi
