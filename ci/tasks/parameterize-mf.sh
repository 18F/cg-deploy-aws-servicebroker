#!/bin/sh

pushd release
	unzip *.zip
	yq w -i manifest.yml applications[0].env.AWS_ACCESS_KEY_ID "((aws_access_key_id))"
	yq w -i manifest.yml applications[0].env.AWS_SECRET_ACCESS_KEY: "((aws_secret_access_key))"
	yq w -i manifest.yml applications[0].env.SECURITY_USER_NAME: "((security_user_name))"
	yq w -i manifest.yml applications[0].env.SECURITY_USER_PASSWORD "((security_user_password))"
	yq w -i manifest.yml applications[0].env.AWS_DEFAULT_REGION: "((aws_default_region))"
	yq w -i manifest.yml applications[0].env.BROKER_ID: "((broker_id))"
	yq w -i manifest.yml applications[0].env.INSECURE "((insecure))"
	yq w -i manifest.yml applications[0].env.PRESCRIBE: "((prescribe))"
	yq w -i manifest.yml applications[0].env.S3_BUCKET: "((s3_bucket))"
	yq w -i manifest.yml applications[0].env.S3_KEY "((s3_key))"
	yq w -i manifest.yml applications[0].env.S3_REGION: "((s3_region))"
	yq w -i manifest.yml applications[0].env.TABLE_NAME: "((table_name))"
	yq w -i manifest.yml applications[0].env.TEMPLATE_FILTER "((template_filter))"
	yq w -i manifest.yml applications[0].env.VERBOSITY: "((verbosity))"
	mv manifest.yml ../manifest/manifest.yml
popd

cat manifest/manifest.yml