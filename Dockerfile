from nginx:latest

run apt-get update \
  && apt-get install -y \
    ripgrep \
    inotify-tools

copy default.conf.template /etc/nginx/templates/
copy generate_redirect_map /usr/local/lib/
copy generate_qr_map /usr/local/lib/
copy 99-redirect-gen-service.sh /docker-entrypoint.d/
