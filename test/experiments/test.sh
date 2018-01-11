#!/bin/bash

# Experiment with curl and TargetProcess REST API

TP_DOMAIN="mydomain.tpondemand.com"
TP_USER="TODO"
TP_PASSWORD="TODO"

# get 1 user story with specified ID
# curl -X GET -u $TP_USER:$TP_PASSWORD https://$TP_DOMAIN/api/v1/UserStories/7517?format=json

# get 1 user story with specified ID and additional fields
# like Bugs-Count, Tasks-Count, Comments-Count
# -g to turn of curl globbing, to allow [] usage
# http://stackoverflow.com/questions/8333920/passing-a-url-with-brackets-to-curl
# curl -X GET -u $TP_USER:$TP_PASSWORD -g "https://$TP_DOMAIN/api/v1/UserStories/7514?format=json&append=[Bugs-Count,Tasks-Count,Comments-Count]"

# get a collection of comments for a UserStory
# curl -X GET -u $TP_USER:$TP_PASSWORD -g https://$TP_DOMAIN/api/v1/UserStories/7517/Comments?format=json

# get a collection of MasterRelations for a UserStory
# curl -X GET -u $TP_USER:$TP_PASSWORD -g https://$TP_DOMAIN/api/v1/UserStories/7517/MasterRelations?format=json

# get features within IDs range
# curl -X GET -g -u $TP_USER:$TP_PASSWORD "http://$TP_DOMAIN/api/v1/Features?where=(Id%20in%20(2782,2784))"

# get metadata about 1 attachment
# curl -X GET -u $TP_USER:$TP_PASSWORD https://$TP_DOMAIN/api/v1/Attachments/22?format=json

# get metadata about 2 Attachments
curl -X GET -u $TP_USER:$TP_PASSWORD "https://$TP_DOMAIN/api/v1/Attachments/?take=2&format=json"
