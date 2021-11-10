repository=$1
branch=$2
token=$3

if [[ -z $1 || -z $2 || -z $3 || -z $GITHUB_ACTOR || -z $GITHUB_API_URL ]]; then
    echo "required arguments missing"
    exit 1
fi


echo "$GITHUB_ACTOR:$token $GITHUB_API_URL/repos/$repository/commits/$branch"
response=$(curl -s -u $GITHUB_ACTOR:$token $GITHUB_API_URL/repos/$repository/commits/$branch)
echo $response
sha=$(echo $response | jq -r '.sha')

echo $sha > _get_latest_commit.txt