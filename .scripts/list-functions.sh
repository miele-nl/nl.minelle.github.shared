limit=$1

if [[ -z $APPWRITE_PROJECT || -z $APPWRITE_APIKEY || -z $APPWRITE_ENDPOINT ]]; then
    echo "required arguments missing"
    exit 1
fi

if [[ -z $1 ]]; then
    limit=0
fi

echo "list all functions (maximum: $limit)"

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
