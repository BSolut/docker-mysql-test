#https://github.com/slimtoolkit/slim

# 8.0, not 8: Docker Hub moved 8.4 LTS into the `8` tag, so `mysql:8` crosses a
# major version. Aurora 3.x and every deployed environment are on 8.0.
BASE = mysql:8.0

# Both tags are pushed from the same build. 8.test-slim keeps existing consumers
# working without coordination; 8.0.test-slim is what new ones should pin, so the
# next upstream move is visible in the tag instead of silent.
TAG="ghcr.io/bsolut/mysql:8.0.test-slim"
TAG_COMPAT="ghcr.io/bsolut/mysql:8.test-slim"

build:
	docker-slim build --pull --tag ${TAG} --tag ${TAG_COMPAT}\
	  --cro-shm-size 512000000 \
	  --http-probe-off \
	  --env MYSQL_ROOT_PASSWORD=test \
	  --include-shell \
	  --include-exe awk \
	  --include-exe chown \
	  --include-exe df  \
	  --continue-after 10 \
	  ${BASE}

push:
	docker push ${TAG}
	docker push ${TAG_COMPAT}

version:
	docker run --rm ${TAG} mysqld --version

test-slim:
	docker run --rm --env MYSQL_ROOT_PASSWORD=test --health-cmd="df -h && mysqladmin ping" --rm ${TAG}  mysqld 

enter:
	docker run --rm -it --entrypoint /bin/bash ${TAG}

test-original:
	docker run --rm --env MYSQL_ROOT_PASSWORD=test --rm ${BASE} mysqld
