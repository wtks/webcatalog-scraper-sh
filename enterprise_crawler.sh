#!/bin/bash
set -eu
PATH=/usr/local/bin:/usr/local/sbin:$PATH
cd $(dirname $0)

catalog_domain='webcatalog.circle.ms'

if [[ -v FREE_MODE ]]; then
    catalog_domain='webcatalog-free.circle.ms'
fi

if [[ -v WAIT_TIME ]]; then
    WAIT_TIME=1
fi


# Initialize
if [[ -e 'cookie.txt' ]]; then
	rm 'cookie.txt'
fi
if [[ -e 'data_e.csv' ]]; then
	rm 'data_e.csv'
fi
touch 'data_e.csv'

# Login
echo -n 'username> ' 1>&2
read username
echo -n 'password> ' 1>&2
read -s password
curl -Ssf -o /dev/null -c cookie.txt -d "Username=$username" -d "Password=$password" -d "ReturnUrl=https://webcatalog.circle.ms/Account/Login" -d "state=/" -XPOST "https://auth2.circle.ms/"

echo ''
echo 'Login Successful.' 1>&2

# Fetch
echo 'Start fetching...' 1>&2
links=$(curl -Ssf -b cookie.txt -c cookie.txt "https://$catalog_domain/Booth/Syllabary" | pup 'div.md-circlelist > div > ul > li > div > a attr{href}')
for link in $links; do
    echo "Fetching $link" 1>&2
    curl -Ssf -b cookie.txt -c cookie.txt "https://$catalog_domain$link" | pup 'table td json{}' | jq -r '[(map(select(.text != null)) | .[0:2] | map(.text) | [if (.[1] | tonumber) > 7000 then "東" else "西" end, .[]] | .[]), (map(select(.children != null)) | .[].children[].children[0].children[0].href)] | @csv' | sed -e "s/\&amp;/\&/g" >> 'data_e.csv'
done
echo 'All Done!!!' 1>&2
