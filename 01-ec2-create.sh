#!/bin/bash

AIM="ami-0220d79f3f480ecf5"
SECURITY_GROUP="sg-0c38430134803699d"
ZONE_ID="Z086025214DK5VMINA2N"
DOMAIN_NAME="anuragaws.shop"

#echo "Creating EC2 Instance with AMI: $AIM and Security Group: $SECURITY_GROUP"

for instance in $@
do 
    echo "Creating EC2 Instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AIM --instance-type t3.micro --security-group-ids $SECURITY_GROUP --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    if [ $? -ne 0 ]; then
        echo "ERROR creating EC2 Instance: $instance"
        exit 1
    else
        echo "EC2 Instance: $instance created SUCCESSFULLY"
        if [ "$instance" == "frontend" ]; then
            IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
            echo "$instance Instance Public IP: $IP"
            RECORD_NAME="$DOMAIN_NAME"
        else
            IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
            echo "$instance Instance Private IP: $IP"
            RECORD_NAME="$instance.$DOMAIN_NAME"
        fi
        echo "Creating Route53 Record: $RECORD_NAME -> $IP"
        aws route53 change-resource-record-sets \
            --hosted-zone-id $ZONE_ID \
            --change-batch '
            {
                "Comment": "Updating record set"
                ,"Changes": [{
                "Action"              : "UPSERT"
                ,"ResourceRecordSet"  : {
                    "Name"              : "'$RECORD_NAME'"
                    ,"Type"             : "A"
                    ,"TTL"              : 1
                    ,"ResourceRecords"  : [{
                        "Value"         : "'$IP'"
                    }]
                }
                }]
            }
            '
    fi
done