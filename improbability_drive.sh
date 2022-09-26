rann=$(shuf -i 0-99 -n 1)

# you can rip these by logging in vrchat and poaching them from the headers 
apiKey=""
auth=""

# todo: this could be made a little kinder to the vrchat api
# on closer expection "shuffle" isn't very random, so we introduce our own randomness 
curl 'https://vrchat.com/api/1/worlds?maxUnityVersion=2019.4.31f1&sort=shuffle&tag=system_approved&order=descending&n=100' \
-X 'GET' \
-H "Cookie: apiKey=${apiKey}; auth=${auth}" \
-H 'Accept: application/json; charset=utf-8' \
-H 'Host: vrchat.com' \
-H 'User-Agent: Improbability Drive Mk.1' \
-H 'Connection: keep-alive' \
--output - \
| jq ".[${rann}]" > world.json 

# bot data
USERNAME="Improbability Drive Mk.1"
AVATAR_URL="https://static.wikia.nocookie.net/hitchhikers/images/7/74/Infinitedrive.jpg"

# world data 
TITLE=$(cat world.json | jq -r .name)
# todo: this can be improved to generate instances instead
URL="https://vrchat.com/home/launch?worldId="$(cat world.json | jq -r .id)
THUMBNAIL_URL=$(cat world.json | jq -r .thumbnailImageUrl)
AUTHOR_NAME=$(cat world.json | jq -r .authorName)

# discord embed 
PAYLOAD="{\"username\":\"${USERNAME}\",\"avatar_url\":\"${AVATAR_URL}\",\"embeds\":[{\"title\":\"${TITLE}\",\"url\":\"${URL}\",\"thumbnail\":{\"url\":\"${THUMBNAIL_URL}\"},\"author\":{\"name\":\"${AUTHOR_NAME}\"}}]}"

# curl throws a fit about the format of the json when provied inline. Passing as a file is fine
echo $PAYLOAD | jq '.' > world_payload.json

# generate these from discord chanel options
WEBHOOK=""

curl \
    -X POST \
    -g \
    -d @world_payload.json \
    -H 'Content-Type: application/json' \
    --url $WEBHOOK

