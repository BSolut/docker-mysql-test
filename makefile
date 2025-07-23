#https://github.com/slimtoolkit/slim
TAG="ghcr.io/bsolut/mysql:8.test-slim"
build:
	docker-slim build --pull --tag ${TAG}\
	  --http-probe-off \
	  --env MYSQL_ROOT_PASSWORD=test \
	  --include-shell \
	  --include-exe awk \
	  --include-exe chown \
	  --continue-after 10 \
	  --exec 'docker-entrypoint.sh' \
	  mysql:8

push:
	docker push ${TAG}
