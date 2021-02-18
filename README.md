## Parameters

This Docker image is based on the official nginx image, and inherits some
of its environmental variables like:

     NGINX_HOST=qr.hal9k.dk

The added "software" in the image adds its own configuration via
environmental variables:

A folder to watch for files which may contain HQR code references:

     QRR_WATCH_FOLDER=/config/dokuwiki/data/pages

A URL prefix for redirecting to HQR code references to:

     QRR_PREFIX=https://wiki.hal9k.dk

A URL path to send unknown HQR code references to, appended to
`QRR_PREFIX`:

     QRR_NOT_FOUND="/infrastruktur/it-services/qr/qr-kode_infoside"

Cool down period between calls to inotify watch used internally to
discover HQR code references:

     QRR_REBUILD_RATE_LIMIT=10

How often to run the scheduled HQR code reference discovering, to pick up
references missed by watching the filesystem:

     QRR_REBUILD_FREQ=600

Where to place a list oF links to all discovered HQR code references
relative to `QRR_WATCH_FOLDER`:

     QRR_LINK_MAP=qr.txt

## How to use

To use with dokuwiki you can try the following:

    docker run \
      --rm \
      --name dokuwiki \
      -e PUID=1000 \
      -e PGID=1000 \
      -e TZ=Europe/Copenhagen \
      -v $(pwd)/dokuwiki:/config \
      -p 8080:8081 \
      ghcr.io/linuxserver/dokuwiki
    
    docker run \
      --rm \
      --name qr \
      -e NGINX_HOST=qr.hal9k.dk \
      -e QRR_WATCH_FOLDER=/config/dokuwiki/data/pages \
      -e QRR_PREFIX=https://wiki.hal9k.dk \
      -e QRR_NOT_FOUND="/infrastruktur/it-services/qr/qr-kode_infoside" \
      -e QRR_REBUILD_RATE_LIMIT=10 \
      -e QRR_REBUILD_FREQ=600 \
      -e QRR_LINK_MAP=/config/dokuwiki/data/pages/qr.txt \
      --volumes-from dokuwiki \
      -p 8080:80 \
      hal9k-dk/qr-redirect
