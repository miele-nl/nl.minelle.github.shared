variables=$1

if [[ -z $1 ]]; then
  variables="[]"
fi

# read each item in the JSON array to an item in the Bash array
readarray -t vars < <(echo $variables | jq -c '.[]')

# iterate through the Bash array
result=""
for var in "${vars[@]}"; do
  key=$(echo $var | jq -r '.key' | tr [:lower:] [:upper:])
  value=$(echo $var | jq -r '.value')

  stmt="--dart-define ${key//-/_}=\"$value\" \\"
  echo "new statement: $stmt"

  result=$("echo $result
  $stmt")

done

echo $result > _prepare_build.txt
