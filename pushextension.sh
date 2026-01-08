#! /bin/sh
appname=$1
commit=$2
virsion=$3

git add .
git commit -m "$virsion / $commit"
zip -r "release/${appname}_${virsion}.zip" . -x "*/release/*" "*.git/*"
git push
