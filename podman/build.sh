nginx_id=$(buildah from docker.io/nginx:1.23.1-alpine)
copy $nginx_id /tmp/index.html /usr/share/nginx/html
buildah config --port 8080 $nginx_id
buildah commit $nginx_id nginx-alpine-custom
