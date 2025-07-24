#https://github.com/slimtoolkit/slim
TAG="ghcr.io/bsolut/mysql:8.test-slim"
build:
	docker-slim build --pull --tag ${TAG}\
	  --cro-shm-size 512000000 \
	  --http-probe-off \
	  --env MYSQL_ROOT_PASSWORD=test \
	  --include-shell \
	  --include-exe awk \
	  --include-exe chown \
	  --include-exe df  \
	  --continue-after 10 \
	  mysql:8

push:
	docker push ${TAG}

test-slim:
	docker run --rm --env MYSQL_ROOT_PASSWORD=test --health-cmd="df -h && mysqladmin ping" --rm ${TAG}  mysqld 

enter:
	docker run --rm -it --entrypoint /bin/bash ${TAG}

test-original:
	docker run --rm --env MYSQL_ROOT_PASSWORD=test --rm mysql:8 mysqld
