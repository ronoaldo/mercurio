# discord_message sends the first argument as a text message to discord.
# The message can be formatted using discord formatting.
discord_message() {
    if [ x"${MINETEST_DISCORD_WEBHOOK}" == x"" ]; then
        echo "[discord.sh] MINETEST_DISCORD_WEBHOOK not configured, skipping."
        return
    fi

    ENCODED_MESSAGE="`printf "%s" "${1}" | jq -Rsa .`"
    echo "[discord.sh] Posting [${ENCODED_MESSAGE}] to webhook channel"
    curl --silent \
        -X POST \
        -H 'Content-Type: application/json' \
        --data "{ \"content\": $ENCODED_MESSAGE }" \
        "${MINETEST_DISCORD_WEBHOOK}"
    echo ""
}
