#!/bin/bash

REGIONS='
af-south-1
ap-east-1
ap-northeast-1
ap-northeast-2
ap-northeast-3
ap-south-1
ap-south-2
ap-southeast-1
ap-southeast-2
ap-southeast-3
ap-southeast-4
ap-southeast-5
ca-central-1
ca-west-1
eu-central-1
eu-central-2
eu-north-1
eu-south-1
eu-south-2
eu-west-1
eu-west-2
eu-west-3
il-central-1
me-central-1
me-south-1
sa-east-1
us-east-1
us-east-2
us-gov-east-1
us-west-1
us-west-2
'

for REGION in $REGIONS
do
    {
        mkdir "/var/app/schemas/$REGION"
        wget "https://schema.cloudformation.$REGION.amazonaws.com/CloudformationSchema.zip" -O "/var/app/schemas/$REGION/schemas.zip"
        unzip "/var/app/schemas/$REGION/schemas.zip" -d "/var/app/schemas/$REGION"
        jq 'map(select(.handlers) | {key: .typeName, value: (.handlers | with_entries({key, value: .value.permissions}))}) | from_entries' -s /var/app/schemas/"$REGION"/*.json > "/var/app/schemas/$REGION.json"
        rm -rf "/var/app/schemas/$REGION"
    }
done
