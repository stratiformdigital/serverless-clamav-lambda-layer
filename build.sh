#!/bin/bash

rm -rf ./layer
mkdir layer

docker build --platform=linux/x86_64 -t clamav -f Dockerfile .
docker run --name clamav clamav
docker cp clamav:/home/build/clamav_lambda_layer.zip .
docker rm clamav
cp clamav_lambda_layer.zip ./layer

pushd layer
unzip -n clamav_lambda_layer.zip
rm clamav_lambda_layer.zip
popd
