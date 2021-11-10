collectionName=$1
collectionId=$2
templateFile=$3

if [[ -z $1 || -z $2 || -z $3 || -z $APPWRITE_PROJECT || -z $APPWRITE_APIKEY || -z $APPWRITE_ENDPOINT ]]; then
    echo "required arguments missing"
    exit 1
fi

echo "update collection $collectionName ($collectionId) from template $templateFile"

## build function json
collectionJson=$(envsubst < $templateFile)
echo $(echo $collectionJson | jq --arg collectionId $collectionId \
    --arg collectionName $collectionName \
    '{ 
        name: $collectionName, 
        collectionId: $collectionId, 
        read: .read, 
        write: .write, 
        rules: .rules
    }') > tmp.json

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
    exit 1;
fi