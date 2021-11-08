collectionName=$1

. ./search_collection.sh
return_code=$?

echo "the return code was $return_code"

if [[ "$return_code" -eq 0 ]]; then
    collection=$(cat _search_collection.txt)
    collectionId=$(jq -r '."$id"' <<< $collection)
    if [ "$collectionId" == "null" ]; then
        collectionId=""
    fi 
    echo "get_collection_id result: $collectionId"
    echo $collectionId > _get_collection_id.txt
else
    echo "exit $return_code"
    exit $return_code
fi
