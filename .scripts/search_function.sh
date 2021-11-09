functionName=$1

echo "checking for existance of function $functionName"

# remove from '-' characters onwards, otherwise listfunctions will not find function
search=$(sed $'s/\-.*//g' <<< $functionName)
echo "search string: $search"

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    $APPWRITE_ENDPOINT/functions?search=$search)

echo "search result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    function=$(jq -r --arg functionName $functionName '.functions | map(select(.name==$functionName)) | .[0]' <<< $listJson)
    if [ "$function" != "null" ]; then
        echo "search_function result: $function"
        echo $function > _search_function.txt
    else
        echo "function $functionName not found!"
        echo $(jq empty) > _search_function.txt 
    fi
else
    echo "ERROR searching function: $message"
    exit 1;
fi
