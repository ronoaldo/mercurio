# discord_message sends the first argument as a text message to discord.
# The message can be formatted using discord formatting.
discord_message() {
    if [ x"${MINETEST_DISCORD_WEBHOOK}" == x"" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') discord: MINETEST_DISCORD_WEBHOOK not configured, skipping."
        return
    fi
    MESSAGE="${1}"

    # JSON encode the message with the `jq` tool.
    ENCODED_MESSAGE="`printf "%s" "${MESSAGE}" | jq -Rsa .`"
    echo "$(date '+%Y-%m-%d %H:%M:%S') discord: Posting ${ENCODED_MESSAGE} (${#ENCODED_MESSAGE} characters) to webhook channel"
    curl --silent \
        -X POST \
        -H 'Content-Type: application/json' \
        --data "{ \"content\": $ENCODED_MESSAGE }" \
        "${MINETEST_DISCORD_WEBHOOK}"
}
