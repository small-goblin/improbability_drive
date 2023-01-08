# your secret keys
apiKey=""
auth=""
WEBHOOK=""

function get_vrc {
    curl $1 \
        -s \
        -X 'GET' \
        -H "Cookie: apiKey=$2; auth=$3" \
        -H 'Accept: application/json; charset=utf-8' \
        -H 'User-Agent: Improbability Drive Mk.1.2' \
        -H 'Connection: keep-alive'
}

function post_vrc {
    curl \
        -s \
        -X POST \
        -g \
        -d $1 \
        -H 'User-Agent: Improbability Drive Mk.1.2' \
        -H 'Content-Type: application/json' \
        --url $2
}

function capacity {
    jq -r .capacity world.json
}

function pick_world {
    rann=$(shuf -i 0-99 -n 1)
    jq ".[${rann}]" worlds.json > world.json 
}

worlds_api="https://vrchat.com/api/1/worlds?maxUnityVersion=2019.4.31f1&sort=shuffle&tag=system_approved&order=descending&n=100"

get_vrc $worlds_api $apiKey $auth > worlds.json

pick_world

until [[ $(capacity) > 15 ]]
do
    pick_world
done

world_id=$(cat world.json | jq -r .id)
instance_id="12345"
user_id="usr_b3073d77-20b9-4a59-b902-c342540b3dd3"

instance_URL="https://vrchat.com/api/1/instances/${world_id}:${instance_id}~hidden(${user_id})~region(us)~nonce(9bad2427-f458-40d1-85b2-6b4a5b260f55)/shortName?permanentify=true"

get_vrc $instance_URL $apiKey $auth &> /dev/null

USERNAME="Improbability Drive Mk.1.1"
AVATAR_URL="https://static.wikia.nocookie.net/hitchhikers/images/7/74/Infinitedrive.jpg"
TITLE=$(cat world.json | jq -r .name)
launch_url="https://vrchat.com/home/launch?worldId=${world_id}&instanceId=${instance_id}~hidden(usr_b3073d77-20b9-4a59-b902-c342540b3dd3)~region(us)~nonce(9bad2427-f458-40d1-85b2-6b4a5b260f55)"
THUMBNAIL_URL=$(cat world.json | jq -r .thumbnailImageUrl)
AUTHOR_NAME=$(cat world.json | jq -r .authorName)

PAYLOAD="{\"username\":\"${USERNAME}\",\"avatar_url\":\"${AVATAR_URL}\",\"embeds\":[{\"title\":\"${TITLE}\",\"url\":\"${launch_url}\",\"thumbnail\":{\"url\":\"${THUMBNAIL_URL}\"},\"author\":{\"name\":\"${AUTHOR_NAME}\"}}]}"

# curl throws a fit about the format of the json when provided inline. Passing as a file is fine
echo $PAYLOAD | jq '.' > world_payload.json

payload_file="@world_payload.json"

post_vrc $payload_file $WEBHOOK
