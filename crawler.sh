#!/bin/bash
set -eu
PATH=/usr/local/bin:/usr/local/sbin:$PATH
cd $(dirname $0)

DAYS=(Day1 Day2 Day3)
Day1=181
Day2=184
Day3=180
WAITTIME=3
DATEFORMAT='+%Y%m%d-%H%M%S'

# Initialize
if [ -e 'cookie.txt' ]; then
	rm 'cookie.txt'
fi
if [ -e 'data.csv' ]; then
	rm 'data.csv'
fi
touch 'data.csv'
if [ ! -d 'data' ]; then
	mkdir 'data'
fi

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
for day in "${DAYS[@]}"; do
	echo "Starting $day..." 1>&2
	for page in $(seq 1 ${!day}); do
		echo -n "page$page..." 1>&2
		now=$(date $DATEFORMAT)
		curl -Ssf -b cookie.txt -c cookie.txt "https://webcatalog.circle.ms/Circle/List?day=$day&orderBy=Space&page=$page" |
			pup '#TheModel text{}' |
			tee "data/$day-$page-$now.json" |
			jq -r '.Circles[] | [.Id, .Name, .Author, .Hall, .Day, .Block, .Space, .Genre, .PixivUrl, .TwitterUrl, .NiconicoUrl, .WebSite] | @csv' \
				>>'data.csv'
		echo "Done!" 1>&2
		sleep $WAITTIME
	done
	echo "$day finished!" 1>&2
done
echo 'All Done!!!' 1>&2
