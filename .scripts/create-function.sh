functionName=$1
templateFile=$2

if [[ -z $1 || -z $2 || -z $APPWRITE_PROJECT || -z $APPWRITE_APIKEY || -z $APPWRITE_ENDPOINT]]; then
    echo "required arguments missing"
    exit 1
fi

echo "create function $functionName"

## build function json
functionJson=$(envsubst < $templateFile)
echo $(jq --arg functionName $functionName \
    '{ 
        name: $functionName, 
        execute: .execute, 
        runtime: .runtime,
        vars: .vars, 
        events: .events, 
        schedule: .schedule, 
        timeout: .timeout
    }' <<< $functionJson) > tmp.json

echo $(cat tmp.json)

listJson=$(curl -s \
    -H "x-appwrite-project:$APPWRITE_PROJECT" \
    -H "x-appwrite-key:$APPWRITE_APIKEY" \
    -H "Content-Type:application/json" \
    -d @tmp.json \
    $APPWRITE_ENDPOINT/functions/)

echo "create result: $listJson"

# test if result is valid json
echo $listJson | jq empty > /dev/null 2>&1

if [ "$?" -ne "0" ]; then
    message=$listJson
else
    message=$(jq -r '.message' <<< $listJson)
fi

if [ "$message" == "null" ]; then
    functionId=$(jq -r '."$id"' <<< $listJson)
    echo "function $functionId created successfully"
    echo $functionId > _create_function.txt
else
    echo "ERROR creating function: $message"
    exit 500;
fi
