collectionName=$1

echo "create collection $collectionName"

echo "{ 
    \"name\": \"$collectionName\", 
    \"read\": [], 
    \"write\": [],
    \"rules\": []
}" > tmp.json

echo $(cat tmp.json)

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    -H "Content-Type:application/json" \
    -d @tmp.json \
    $APPWRITE_ENDPOINT/database/collections)

echo "create result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    collectionId=$(jq -r '."$id"' <<< $listJson)
    echo "collection $collectionId created successfully"
    echo $collectionId > _create_collection.txt
else
    echo "ERROR creating collection: $message"
    exit 500;
fi
