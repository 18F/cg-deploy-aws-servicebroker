#!/bin/bash
# Pull bucket contents
BUCKETNAME=$1
DIRECTION=$2
if [[ -z ${BUCKETNAME} ]]; then
 echo -n “You need to provide a BUCKETNAME”
 exit 1
fi

if [[ -z ${DIRECTION} ]]; then
 echo -n “You need to provide a DIRECTION”
 exit 1
fi

case $DIRECTION in

  UP | up )
    aws s3 cp ./templates/latest/* s3://$BUCKETNAME/templates/latest/
    aws s3 cp ./functions s3://$BUCKETNAME/functions/ --recursive
    aws s3 cp ./baseline s3://$BUCKETNAME/baseline/ --recursive
    aws s3 cp ./instructions.txt s3://$BUCKETNAME/
    aws s3 cp ./secrets.yml s3://$BUCKETNAME/
    aws s3 cp ./cf-app/manifest.yml s3://$BUCKETNAME/cf-app/
    ;;

  DOWN| down )
    aws s3 cp s3://$BUCKETNAME/templates/ ./templates/ --recursive
    aws s3 cp s3://$BUCKETNAME/functions/ ./functions  --recursive
    aws s3 cp s3://$BUCKETNAME/baseline/ ./baseline  --recursive
    aws s3 cp s3://$BUCKETNAME/instructions.txt  ./
    aws s3 cp s3://$BUCKETNAME/secrets.yml ./
    aws s3 cp s3://$BUCKETNAME/cf-app/ ./cf-app/ --recursive
    ;;
  *)
    echo -n "BAD DIRECTION"
    ;;
esac
