functionName=$1
functionId=$2
templateFile=$3

if [[ -z $1 || -z $2 || -z $3 || -z $APPWRITE_PROJECT || -z $APPWRITE_APIKEY || -z $APPWRITE_ENDPOINT ]]; then
    echo "required arguments missing"
    exit 1
fi


echo "update function $functionName ($functionId) from template $templateFile"

## build function json
functionJson=$(envsubst < $templateFile)
echo "$functionJson" | jq --arg functionId $functionId \
    --arg functionName $functionName \
    '{ 
        name: $functionName, 
        execute: .execute, 
        functionId: $functionId, 
        vars: .vars, 
        events: .events, 
        schedule: .schedule, 
        timeout: .timeout
    }' > tmp.json

echo $(cat tmp.json)

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    -H "Content-Type:application/json" \
    -X PUT \
    -d @tmp.json \
    $APPWRITE_ENDPOINT/functions/$functionId)

echo "update result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    echo "function updated successfully"
else
    echo "ERROR updating function: $message"
    exit 500;
fi
