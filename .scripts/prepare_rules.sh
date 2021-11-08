templateFile=$1


# read each item in the JSON array to an item in the Bash array
readarray -t rules < <(cat $templateFile | jq -c '.rules[]')

# iterate through the Bash array
newRules="[]"
for rule in "${rules[@]}"; do
  type=$(jq -r '.type' <<< $rule)
  echo "preparing rule $(jq -r '.key' <<< $rule) (type=$type)"
  if [[ "$type" == "document" ]]; then
    newList="[]"
    readarray -t list < <(echo $rule | jq -c -r '.list[]')
    for item in "${list[@]}"; do
      echo "looking up collectionId for $item"
      . get_collection_id.sh $item
      collectionId=$(cat _get_collection_id.txt)
      newList=$(echo $newList [\"$collectionId\"] | jq -s '.[0] + .[1]')
    done

    rule=$(echo $rule | jq '{ 
            type: .type,
            key: .key,
            label: .label,
            default: .default,
            array: .array,
            required: .required,
            list: []
        }')
    rule=$(echo $rule { \"list\": $newList } | jq -s add)

  fi
  echo "new rule: $rule"

  newRules=$(echo $newRules [ $rule ] | jq -s '.[0] + .[1]')

done

echo $newRules > _prepare_rules.txt
