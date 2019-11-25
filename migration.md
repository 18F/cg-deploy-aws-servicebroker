# How to Migrate from Kubernetes Elasticsearch to AWS Elasticsearch
## Requirements
This assumes you have 3 required services:
* elasticsearch56 service
* s3 service
* elasticsearch-online

That is either bound to application or `service-key` created to get credentials to be used.


## Back Up to S3
#### 1. Add S3 as a snapshot repository
```
curl -X PUT -u "<OLD_ES_USERNAME>:<OLD_ES_PASSWORD>" "<HOSTNAME>/_snapshot/my_s3_repository" -d @<(cat <<EOF
{
  "type": "s3",
  "settings": {
    "bucket": "<S3_BUCKET>",
    "region": "us-gov-west-1",
    "access_key": "<S3_ACCESS_KEY_ID>",
    "secret_key": "<S3_SECRET_ACCESS_KEY>"
  }
}
EOF
)
```
Output should be this if successful:
```
{"acknowledged":true}
```

#### 2. Run the backup to S3
```
curl -X PUT -u "<OLD_ES_USERNAME>:<OLD_ES_PASSWORD>" "<HOSTNAME>/_snapshot/my_s3_repository/my_s3_snapshot"
```
Output should be:
```
{"accepted":true}
```

and you can see snapshots are in S3

## Use Snapsnot from S3 to import ES data to AWS Elasticsearch
Note: Currently Only Operators can do this part due to AWS Permissions
#### 1. SSH into Diego Cell that has access to the AWS Elasticsearch
#### 2. Change folder to somewhere to store python script
#### 3. Install python + install libraries that will be used
```
apt-get install python
pip install boto3
pip install requests_aws4auth
```

#### 4. Create Role
Create a role with the policy so the elasticsearch domain has access to the S3 bucket
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws-us-gov:s3:::<S3_BUCKET>"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws-us-gov:s3:::<S3_BUCKET>/*"
        }
    ]
}
```

#### 5. Copy script and include correct credentials
```
import boto3
import requests
from requests_aws4auth import AWS4Auth

host = 'https://<AWS_ES_HOSTNAME>/' # include https:// and trailing /
region = 'us-gov-west-1' # e.g. us-west-1
service = 'es'
access_key = '<YOUR_ACCESS_KEY>'
secret_key = '<YOUR_SECRET_KEY>'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(access_key, secret_key, region, service)

# Register repository

path = '_snapshot/my_s3_repository' # the Elasticsearch API endpoint
url = host + path

payload = {
  "type": "s3",
    "settings": {
      "bucket": "<S3_BUCKET>",
      "region": "us-gov-west-1",
      "role_arn": "<ARN_CREATED_FOR_ROLE_ABOVE>"
    }
}

headers = {"Content-Type": "application/json"}

r = requests.put(url, auth=awsauth, json=payload, headers=headers)

print(r.status_code)
print(r.text)

 Restore snapshots (all indices)

path = '_snapshot/my_s3_repository/my_s3_snapshot/_restore'
url = host + path

r = requests.post(url, auth=awsauth)

print(r.text)
```

Output:
```
200
{"acknowledged":true}
{"accepted":true}
```

#### 6. Get a nice glass of ice water and cheers! You're done!