#!/bin/sh
set -euo pipefail

TEMP_REPO_DIR="wiki_action_$GITHUB_REPOSITORY$GITHUB_SHA"
TEMP_WIKI_DIR="temp_wiki_$GITHUB_SHA"
WIKI_DIR=$1
GH_TOKEN=$2

if [ -z "$WIKI_DIR" ]; then
    echo "Wiki location is not specified, using default wiki/"
    WIKI_DIR='wiki'
fi

if [ -z "$GH_TOKEN" ]; then
    echo "Token is not specified"
    exit 1
fi


#Clone repo
git clone https://$GITHUB_ACTOR:$GH_TOKEN@github.com/$GITHUB_REPOSITORY $TEMP_REPO_DIR

#Clone wiki repo
cd $TEMP_REPO_DIR
git clone https://$GITHUB_ACTOR:$GH_TOKEN@github.com/$GITHUB_REPOSITORY.wiki.git $TEMP_WIKI_DIR

#Get commit details
author=`git log -1 --format="%an"`
email=`git log -1 --format="%ae"`
message=`git log -1 --format="%s"`

cp -R $TEMP_WIKI_DIR/.git $WIKI_DIR/

cd $WIKI_DIR
git config --local user.email $email
git config --local user.name $author 
git add .
if git diff-index --quiet HEAD; then
  echo "Nothing changed"
  exit 0
fi

git commit -m "$message" && git push "https://$GITHUB_ACTOR:$GH_TOKEN@github.com/$GITHUB_REPOSITORY.wiki.git"