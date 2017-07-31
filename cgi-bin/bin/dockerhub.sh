#!/bin/sh
#
# Creates list of images on docker hub
. /var/www/cgi-bin/tmp/globals

#Put master list in tmp
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${J2USER}'", "password": "'${J2PASS}'"}' https://hub.docker.com/v2/users/login/|jq -r .token)
curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/j2systems/docker/tags/|jq -r '.results|.[]|"\(.name) \(.full_size) \(.last_updated)"'>tmp/dockerhub
chmod 666 tmp/dockerhub

