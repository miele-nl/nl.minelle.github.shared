collectionName=$1

echo "checking for existance of collection $collectionName"

# remove from '-' characters onwards, otherwise listcollections will not find collection
search=$(sed $'s/\-.*//g' <<< $collectionName)
echo "search string: $search"

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    $APPWRITE_ENDPOINT/database/collections?search=$search)

echo "search result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    
    collection=$(echo $listJson | jq -r --arg collectionName $collectionName '.collections | map(select(.name==$collectionName)) | .[0]')
    if [ "$collection" != "null" ]; then
        echo "search_collection result: $collection"
        echo $collection > _search_collection.txt
    else
        echo "collection $collectionName not found!"
        echo $(jq empty) > _search_collection.txt 
    fi
else
    echo "ERROR searching collection: $message"
    #exit 1;
fi
