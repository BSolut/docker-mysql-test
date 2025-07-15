TAG="bsolut/mysql-test:8"
build:
	docker build . --pull -t ${TAG}

build-nocache:
	docker build . --pull --no-cache -t ${TAG}

build-debug:
	docker --debug build . --pull -t ${TAG}

push:
	docker push ${TAG}

enter:
	docker run --rm -it --entrypoint /bin/bash ${TAG}
