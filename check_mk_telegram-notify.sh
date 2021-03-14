#!/bin/bash
# Telegram (Shell)
#
# Script Name   : check_mk_telegram-notify.sh
# Description   : Send Check_MK notifications by Telegram
# Author        : https://github.com/filipnet/checkmk-telegram-notify
# License       : BSD 3-Clause "New" or "Revised" License
# ======================================================================================

# Telegram API Token
# Find telegram bot named "@botfarther", type /mybots, select your bot and select "API Token" to see your current token
TOKEN='CHANGEME'

# Telegram Chat-ID or Group-ID
# Open "https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates" inside your Browser and send a HELLO to your bot, refresh side
# If you leave 'CHANGEME' this script will use the checkmk custom attribute 'TELEGRAM_CHAT_ID' - See README.md for more information
CHAT_ID='CHANGEME'

# Write Check_MK output to a temporary file, delete depricated macros and create variable OUTPUT
env | grep NOTIFY_ | grep -v "This macro is deprecated" | sort > $OMD_ROOT/tmp/telegram.out
OUTPUT=$OMD_ROOT/tmp/telegram.out

# Try and use the custom Attribute from checkmk in case is not explicitly set above
if [ -z ${CHAT_ID} ] || [ ${CHAT_ID} == "CHANGEME" ] || [ ${CHAT_ID} == "" ]
then
  CHAT_ID=$(grep NOTIFY_CONTACT_TELEGRAM_CHAT_ID $OUTPUT | cut -d'=' -f2)
fi

# Function to url encode a string (Kudos to: https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command)
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

# Read OUTPUT variable and create some more variables for every text-part you want to use afterwards
HOSTNAME=$(grep NOTIFY_HOSTNAME $OUTPUT | cut -d'=' -f2)
HOSTALIAS=$(grep NOTIFY_HOSTALIAS $OUTPUT | cut -d'=' -f2)
WHAT=$(grep NOTIFY_WHAT $OUTPUT | cut -d'=' -f2)
SERVICEDESC=$(grep NOTIFY_SERVICEDESC $OUTPUT | cut -d'=' -f2)
SERVICEOUTPUT=$(grep NOTIFY_SERVICEOUTPUT $OUTPUT | cut -d'=' -f2)
HOSTOUTPUT=$(grep NOTIFY_HOSTOUTPUT $OUTPUT | cut -d'=' -f2)
PREVIOUSHOSTHARDSHORTSTATE=$(grep NOTIFY_PREVIOUSHOSTHARDSHORTSTATE $OUTPUT | cut -d'=' -f2)
HOSTSHORTSTATE=$(grep NOTIFY_HOSTSHORTSTATE $OUTPUT | cut -d'=' -f2)
PREVIOUSSERVICEHARDSHORTSTATE=$(grep NOTIFY_PREVIOUSSERVICEHARDSHORTSTATE $OUTPUT | cut -d'=' -f2)
SERVICESHORTSTATE=$(grep NOTIFY_SERVICESHORTSTATE $OUTPUT | cut -d'=' -f2)
HOST_ADDRESS_4=$(grep NOTIFY_HOST_ADDRESS_4 $OUTPUT | cut -d'=' -f2)
HOST_ADDRESS_6=$(grep NOTIFY_HOST_ADDRESS_6 $OUTPUT | cut -d'=' -f2)

# Create the message to send to your Telegram bot
if [[ $HOSTALIAS == "$HOSTNAME" ]]; then
        HEADER="*${HOSTNAME}* | "
else
        HEADER="*${HOSTNAME}* (_${HOSTALIAS}_) | "
fi
if [[ $WHAT == "SERVICE" ]]; then
        HEADER+="${SERVICEDESC} | ${PREVIOUSSERVICEHARDSHORTSTATE} -> ${SERVICESHORTSTATE}"
        OUTPUT="${SERVICEOUTPUT}"
else
        HEADER+="${PREVIOUSHOSTHARDSHORTSTATE} -> ${HOSTSHORTSTATE}"
        OUTPUT="${HOSTOUTPUT}"
fi
if [ -z "$HOST_ADDRESS_6" ]
then
        ADDRESS="${HOST_ADDRESS_4}"
elif [ -z "$HOST_ADDRESS_4" ]
then
        ADDRESS="${HOST_ADDRESS_6}"
else
        ADDRESS="
        *IPv4*: ${HOST_ADDRESS_4}
        *IPv6*: ${HOST_ADDRESS_6}
        "
fi

# Compose the final message
MESSAGE="
${HEADER}
*Address*: ${ADDRESS}

*Output*: ${OUTPUT}
"

# Replace special characters (this could be nicer but it works reasonably)
MESSAGE="${MESSAGE//-/\\-}"
MESSAGE="${MESSAGE//|/\\|}"
MESSAGE="${MESSAGE//>/\\>}"
MESSAGE="${MESSAGE//(/\\(}"
MESSAGE="${MESSAGE//)/\\)}"
MESSAGE="${MESSAGE//!/\\!}"
MESSAGE="${MESSAGE//./\\.}"

# Send Message
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d chat_id=$CHAT_ID -d parse_mode="MarkdownV2" -d text="$(rawurlencode "$MESSAGE")" >> /dev/null

# End of script
exit 0
