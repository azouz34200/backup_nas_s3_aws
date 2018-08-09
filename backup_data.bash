#!/usr/local/bin/bash

#Init Variables
ZONE=""
SLACK_HOOK_URL=""
SLACK_CHANNEL="backup_nas"
SLACK_MESSAGE="ok"
SLACK_STATUS_OK="good"
SLACK_STATUS_KO="danger"
SLACK_TITLE="Backup from ${ZONE}"
MESSAGE="SUCESS"
S3_BUCKET=""
BACKUP_DIRECTORY="/mnt/"
#####################################
# Send notification to slack channel
# $1 SLACK SERVICE
# $2 SLACK CHANNEL NAME
# $3 SLACK MESSAGE
# $4 SLACK COLOR MESSAGE
# $5 SLACK TITLE
#####################################
function send_notification_to_slack(){
read -d '' PAYLOAD << EOF
{
        "channel": "#${2}",
        "attachments": [
            {
                "color": "${4}",
                "title": "${5}",
                "footer": "Slack API",
                "footer_icon": "https://platform.slack-edge.com/img/default_application_icon.png",
                "text": "${3}"
            }
        ]
    }
EOF
HOOK=https://hooks.slack.com/services/$1
statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${PAYLOAD}" ${HOOK})

if [[ ${statusCode} == "200" ]]; then
    echo "posted successfully"
else
    echo "error"
fi
}

#####################################
# Send data to aws S3 bucket
# $1 Bucket NAME
# $2 Directory to backup
#
#
#####################################

function backup_data_on_aws_s3(){

s3cmd -v sync ${2} ${1}
if [ $? -eq 0 ];
then
send_notification_to_slack ${SLACK_HOOK_URL} ${SLACK_CHANNEL} "SUCESS !!!!!" "${SLACK_STATUS_OK}" "${SLACK_TITLE}"
else
send_notification_to_slack ${SLACK_HOOK_URL} ${SLACK_CHANNEL} "FAIL !!!!!" "${SLACK_STATUS_KO}" "${SLACK_TITLE}"
fi
}
backup_data_on_aws_s3 ${S3_BUCKET} ${BACKUP_DIRECTORY}