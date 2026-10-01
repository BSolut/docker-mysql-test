#https://github.com/slimtoolkit/slim
.PHONY: list build push version test-slim test-original enter

list:
	@grep -E '^[a-zA-Z0-9_-]+:' $(MAKEFILE_LIST) | grep -v '^\.' | sed 's/:.*//' | sort

# Bare `make` lists rather than builds: the build pulls, slims and retags, which
# is not what anyone wants by accident.
.DEFAULT_GOAL := list


# 8.0, not 8: Docker Hub moved 8.4 LTS into the `8` tag, so `mysql:8` crosses a
# major version. Aurora 3.x and every deployed environment are on 8.0.
BASE = mysql:8.0

# Both tags are pushed from the same build. 8.test-slim keeps existing consumers
# working without coordination; 8.0.test-slim is what new ones should pin, so the
# next upstream move is visible in the tag instead of silent.
TAG="ghcr.io/bsolut/mysql:8.0.test-slim"
TAG_COMPAT="ghcr.io/bsolut/mysql:8.test-slim"

# The datadir is bind-mounted so initialisation writes land outside the image.
# The base declares VOLUME /var/lib/mysql, but an anonymous volume is not
# materialised as a mount, so --exclude-mounts never applied and the observation
# run baked an initialised datadir - with a known root password - into the
# image. That also made the entrypoint skip init at runtime, silently ignoring
# MYSQL_DATABASE and MYSQL_USER.
#
# Mounting it keeps init running and observable, which is how chown and friends
# end up retained: --include-exe and --include-bin both silently fail to pull
# them in.
DATADIR = /tmp/slim-mysql-datadir

build:
	rm -rf ${DATADIR} && mkdir -p ${DATADIR}
	docker-slim build --pull --tag ${TAG} --tag ${TAG_COMPAT}\
	  --mount ${DATADIR}:/var/lib/mysql \
	  --cro-shm-size 512000000 \
	  --http-probe-off \
	  --env MYSQL_ROOT_PASSWORD=test \
	  --include-shell \
	  --include-bin /usr/bin/awk \
	  --include-bin /usr/bin/chown \
	  --include-bin /usr/bin/df \
	  --exclude-pattern '/var/lib/mysql/**' \
	  --continue-after 10 \
	  ${BASE}
	-rm -rf ${DATADIR} 2>/dev/null || docker run --rm -v ${DATADIR}:/d alpine rm -rf /d/. 2>/dev/null || true

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
