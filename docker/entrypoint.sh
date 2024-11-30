#!/bin/bash

if [ -z "$AWS_DEFAULT_REGION" ]; then
    echo "AWS_DEFAULT_REGION env value not set"
    return
fi

if [ -z "$AWS_PROFILE" ]; then
    echo "AWS_PROFILE env value not set"
    return
fi

declare -A ACTION_HANDLERS=(
    [Add]='create read'
    [Modify]='read update'
    [Remove]='delete read'
    [Import]='create list read'
    [Dynamic]='create delete read update'
)

PERMISSIONS="[]"

for TEMPLATE in /var/app/cfn/*.json; do
    echo "Processing $TEMPLATE"
    STACK_NAME=$(basename "$TEMPLATE" .template.json)
    STACK_SIZE=$(aws cloudformation list-stack-resources --stack-name "$STACK_NAME" --query "StackResourceSummaries | length(@)" 2> /dev/null || echo "0")
    if [ "$STACK_SIZE" -gt "0" ]; then
        echo "$STACK_NAME already exists, interpreting as UPDATE operation"
        CHANGE_SET_TYPE="UPDATE"
    else
        echo "$STACK_NAME does not exist, interpreting as CREATE operation"
        CHANGE_SET_TYPE="CREATE"
    fi
    CHANGE_SET_NAME="$STACK_NAME-$(date +%s)"
    CHANGE_SET_ID=$(aws cloudformation create-change-set --change-set-name "$CHANGE_SET_NAME" --stack-name "$STACK_NAME" --change-set-type "$CHANGE_SET_TYPE" --template-body "file://$TEMPLATE" --query "Id" --output text)
    echo "Created change set with ID: $CHANGE_SET_ID"
    until [ "$(aws cloudformation describe-change-set --change-set-name "$CHANGE_SET_ID" --query "Status" --output text)" = "CREATE_COMPLETE" ]
    do
        echo "Waiting for change set to transition to CREATE_COMPLETE"
        sleep 5
    done
    CHANGE_SET_CHANGES=$(aws cloudformation describe-change-set --change-set-name "$CHANGE_SET_ID" --query "Changes")
    aws cloudformation delete-change-set --change-set-name "$CHANGE_SET_ID"
    echo "Deleted change set with ID: $CHANGE_SET_ID"
    if [ "$CHANGE_SET_TYPE" = "CREATE" ]; then
        aws cloudformation delete-stack --stack-name "$STACK_NAME"
        echo "Deleted $STACK_NAME"
    fi
    CHANGES=("$(echo $CHANGE_SET_CHANGES | jq -c '.[].ResourceChange | {Action, ResourceType}')")
    for CHANGE in $CHANGES; do
        RESOURCE_TYPE=$(echo "$CHANGE" | jq -r '.ResourceType')
        ACTION=$(echo "$CHANGE" | jq -r '.Action')
        HANDLERS="${ACTION_HANDLERS[$ACTION]}"
        for HANDLER in $HANDLERS; do
            PERMISSIONS="$(jq --arg HANDLER $HANDLER --arg RESOURCE_TYPE $RESOURCE_TYPE '.[$RESOURCE_TYPE][$HANDLER]' /var/app/schemas/$AWS_DEFAULT_REGION.json | jq --argjson CURR "$PERMISSIONS" '. + $CURR | unique | sort')"
        done
     done
    echo $PERMISSIONS | jq '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":.,"Resource":"*"}]}' > /var/app/iam/$STACK_NAME.json
    echo "Wrote IAM policy to /var/app/iam/$STACK_NAME.json"
done