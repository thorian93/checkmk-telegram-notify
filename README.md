# Checkmk Telegram notification

Telegram has long been one of my real-time communication media. It is obvious to output monitoring messages for server and network components as alarm messages. There are several scripts for this on the internet, but most of them are written in Python, many of them have problems with Python3 and its libraries. Instead of spending hours and hours with Python, I decided to use a scripting language I know and write a Linux Bash script for it.

<!-- TOC -->

- [Checkmk Telegram notification](#check_mk-telegram-notification)
    - [REQUIREMENTS](#requirements)
    - [INSTALLATION](#installation)
    - [CHECK_MK CONFIGURATION](#check_mk-configuration)
    - [LICENSE](#license)

<!-- /TOC -->

## Requirements

In order for Checkmk to send alerts (notifications) to the Telegram Messenger, we need

* a bot
* a username for the bot
* an API token
* a chat ID

There are a lot of good instructions for this on the Internet, so this is not part of this documentation.

## Installation
Change to your Checkmk site user
    
    su - mysite

Change to the notification directory

    cd ~/local/share/check_mk/notifications/

Download the Telegram notify script from Git repository

    git clone https://github.com/thorian93/checkmk-telegram-notify.git .

Adjusting your API Token and Chat/Group-ID in `check_mk_telegram-notify.sh`

    # Telegram API Token
    # Find telegram bot named "@botfarther", type /mybots, select your bot and select "API Token" to see your current token
    TOKEN='CHANGEME'

    # Telegram Chat-ID or Group-ID
    # Open "https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates" inside your Browser and send a HELLO to your bot, refresh side
    # If you leave 'CHANGEME' this script will use the checkmk custom attribute 'TELEGRAM_CHAT_ID' - See README.md for more information
    CHAT_ID='CHANGEME'

To use the custom attribute you need to go to  
`WATO → Users → Custom attributes → New attribute`  
and set the following values:
- **Name**: `TELEGRAM_CHAT_ID`
- **Topic**: `Personal Settings`
- **Data type**: `Simple Text`

**Title** can be chosen freely but keep that in mind. Now go to   
`WATO → Users → Edit your User`  
and enter the Chat ID in the new field with the name you gave to **Title**.

Give the script execution permissions

    chmod +x check_mk_telegram-notify.sh

## Checkmk Configuration
Now you can create your own alarm rules in Checkmk.

```WATO → Notifications → New Rule → Notification Method → Telegram (Shell)```

First create a clone of your existing mail notification rule

<img src="images/global_notification_rules_create_clone.png" alt="Create clone" width="600"/>

Change the description and select "Telegram (Shell)", no further settings are required for this.

<img src="images/create_new_notification_rule_for_telegram.png" alt="Adjust settings" width="600"/>

If everything was ok, you will see your new Notification Rule afterwards

<img src="images/notification_configuration_change.png" alt="Final result" width="600"/>

To activate it you have to press "1 Change" and "Activate affected"

<img src="images/activate_affected.png" alt="Activate changes and commit" width="100"/>

## LICENSE
checkmk-telegram-notify and all individual scripts are under the BSD 3-Clause license unless explicitly noted otherwise. Please refer to the LICENSE
