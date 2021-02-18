#!/usr/bin/env bash
# Create empty redirect map
echo Building empty redirect map
(
echo 'map $request_uri $redirect_uri {'
echo '}'
) > /etc/nginx/redirect-map.conf

# Start background job to watch for changes to wiki pages
# update redirect map if change happens
(
limit="${QRR_RATE_LIMIT:=10}"
echo Watching "$QRR_WATCH_FOLDER"
while inotifywait -r --exclude "$QRR_LINK_MAP" -e modify -e create -e move -e delete "$QRR_WATCH_FOLDER"; do
  echo Change detected, regenerating redirect map
  /usr/local/lib/generate_redirect_map
  /usr/local/lib/generate_qr_map
  echo Done building redirect map
  echo Waiting "$limit" before listening again
  sleep "$limit"
done
) &
disown

# Start background job to rebuild every so often
(
freq="${QRR_REBUILD_FREQ:=600}"
echo Scheduling redirect map update in "$freq" seconds
while true; do
  sleep "$freq"
  echo Scheduled update, regenerating redirect map
  /usr/local/lib/generate_redirect_map
  /usr/local/lib/generate_qr_map
  echo Done building redirect map
  echo Waiting "$freq" before listening again
done
) &
disown

# Wait for pages to be mounted and update redirect map
(
while [ ! -d "$QRR_WATCH_FOLDER" ]; do
  echo Waiting for "$QRR_WATCH_FOLDER"
  sleep 1
done

while [ ! -f  /var/run/nginx.pid ]; do
  echo Waiting for nginx to start up
  sleep 1
done

echo Building initial redirect map
/usr/local/lib/generate_redirect_map
/usr/local/lib/generate_qr_map
echo Done building initial redirect map
) &
disown
