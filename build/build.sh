#!/usr/bin/env bash

DST_VERSION="$(cat version)"

DST_BOX="hackoregon-dst-${DST_VERSION}.box"
DST_URL="https://hackoregon-dst.s3.amazonaws.com/${DST_BOX}"
AWS_REGION=$(cat ~/.aws/config | grep region | cut -d= -f2 | tr -d ' ')

if [ ! -f isos/ubuntu-14.04.3-server-amd64.iso ]; then
  cd isos; wget http://releases.ubuntu.com/14.04/ubuntu-14.04.3-server-amd64.iso
fi

echo "AWS_REGION: ${AWS_REGION}" 
echo -n 'DST_URL: '
echo $DST_URL | tee url

sleep 5

## Update version of dst package and try to upload package to PyPi
#< ../manager/setup.py.j2 sed "s/{{version}}/${DST_VERSION}/" > ../manager/setup.py
#( cd ../manager; python setup.py sdist upload )

if [ !-f isos/ubuntu-14.04.3-server-amd64.iso ]; then
  cd isos; wget http://releases.ubuntu.com/14.04/ubuntu-14.04.3-server-amd64.iso
fi

#echo "Current boxes:"
#aws s3api list-objects --bucket data-science-toolbox | jq '.Contents[].Key' | tr -d \"

echo "URL: ${DST_URL}"

rm -rf output-virtualbox-iso
rm -rf packer_virtualbox-iso_virtualbox.box

#1. build AMI and Vagrant with Packer
echo "Build AMI and Vagrant with Packer"
#packer build -var-file=variables.json -var "dst_version=${DST_VERSION}" -only=virtualbox-iso template.json 
packer build -var-file=variables.json -var "dst_version=${DST_VERSION}" template.json

##2. Rename and upload Vagrant box to S3
echo "Rename and upload Vagrant box to S3"
mv packer_virtualbox-iso_virtualbox.box boxes/$DST_BOX #
aws s3 cp boxes/$DST_BOX s3://hackoregon-dst/$DST_BOX --acl public-read

###Update local Vagrant box
vagrant box remove hackoregon-dst
vagrant box add dst boxes/$DST_BOX
