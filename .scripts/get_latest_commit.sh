repository=$1
branch=$2
token=$3

echo "$GITHUB_ACTOR:$token $GITHUB_API_URL/repos/$repository/commits/$branch"
response=$(curl -s -u $GITHUB_ACTOR:$token $GITHUB_API_URL/repos/$repository/commits/$branch)
echo $response
sha=$(echo $response | jq -r '.sha')

echo $sha > _get_latest_commit.txt