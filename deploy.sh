#!/bin/bash

# From https://github.com/runemadsen/runemadsen-2013/blob/master/deploy.sh
rm -rf _site/

printf "\n\n    Building Jekyl Site\n\n"

jekyll build

printf "\n\n    -> Uploading to S3"

# Sync html files with 0 seconds cache control
printf "\n    --> Syncing .html\n\n"
s3cmd sync --acl-public --guess-mime-type --exclude '*.*' --include  '*.html' --add-header="Cache-Control: max-age=0, must-revalidate"  _site/ s3://someairplan.es

# Sync everything else with a year in cache control
printf "\n    --> Syncing everything else\n\n"
s3cmd sync --acl-public --guess-mime-type --exclude '*.html' --add-header="Cache-Control: max-age=31536000"  _site/ s3://someairplan.es

printf "\n    --> Deleting removed\n\n"
s3cmd sync --delete-removed _site/ s3://someairplan.es

printf "\n    --> Done!\n\n"
