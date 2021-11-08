collectionName=$1
collectionId=$2
rules=$3
templateFile=$4

echo "update collection $collectionName ($collectionId) from template $templateFile"

collectionJson=$(cat $templateFile)

# first create without rules
collection=$(echo $collectionJson | jq --arg collectionId $collectionId \
    --arg collectionName $collectionName \
    '{ 
        name: $collectionName, 
        collectionId: $collectionId, 
        read: .read, 
        write: .write, 
        rules: []
    }')

# then add the rules
collection=$(echo $collection { \"rules\": $rules } | jq -s add)

## build collection json
echo $collection > tmp.json
echo $(cat tmp.json)

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    -H "Content-Type:application/json" \
    -X PUT \
    -d @tmp.json \
    $APPWRITE_ENDPOINT/database/collections/$collectionId)

echo "update result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    echo "collection updated successfully"
else
    echo "ERROR updating collection: $message"
    exit 500;
fi
