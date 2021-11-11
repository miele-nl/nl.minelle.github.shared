functionName=$1

if [[ -z $1 ]]; then
    echo "required arguments missing"
    exit 1
fi

. search-function.sh
return_code=$?

echo "the return code was $return_code"

if [[ "$return_code" -eq 0 ]]; then
    function=$(cat _search_function.txt)
    functionId=$(jq -r '."$id"' <<< $function)
    if [ "$functionId" == "null" ]; then
        functionId=""
    fi 
    echo "get_function_id result: $functionId"
    echo $functionId > _get_function_id.txt
else
    echo "exit $return_code"
    exit $return_code
fi
