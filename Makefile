OUTER_DOCKER_IMAGE_NAME = nmap:latest
OUTER_DOCKER_CONTAINER_NAME = container-outer

INNER_DOCKER_IMAGE_NAME = scanner_test:latest
INNER_DOCKER_CONTAINER_NAME = container-inner

lint:
	pre-commit run --all-files --show-diff-on-failure

inner: build_inner_docker run_inner_docker
outer: build_outer_docker run_outer_docker 

reset_outer_docker:
	-docker stop $(OUTER_DOCKER_CONTAINER_NAME)
	-docker rm $(OUTER_DOCKER_CONTAINER_NAME)
	-docker rmi $(OUTER_DOCKER_IMAGE_NAME)

reset_inner_docker:
	-docker stop $(INNER_DOCKER_CONTAINER_NAME)
	-docker rm $(INNER_DOCKER_CONTAINER_NAME)
	-docker rmi $(INNER_DOCKER_IMAGE_NAME)

build_outer_docker:
	echo "Building outer docker image $(OUTER_DOCKER_IMAGE_NAME)"
	-make reset_outer_docker
	docker build -t $(OUTER_DOCKER_IMAGE_NAME) .

run_outer_docker:
	echo "Starting outer docker container $(OUTER_DOCKER_CONTAINER_NAME)"
	docker run -v /var/run/docker.sock:/var/run/docker.sock -p 5050:5050 $(OUTER_DOCKER_IMAGE_NAME)
	echo "Outer docker container $(OUTER_DOCKER_CONTAINER_NAME) started"

build_inner_docker:
	cd scanner && \
	echo "Building inner docker image $(INNER_DOCKER_IMAGE_NAME)" && \
	$(MAKE) -C .. reset_inner_docker && \
	docker build -t $(INNER_DOCKER_IMAGE_NAME) .

run_inner_docker:
	echo "Starting inner docker container $(INNER_DOCKER_CONTAINER_NAME)"
	docker run -p 8080:8080 $(INNER_DOCKER_IMAGE_NAME)
	echo "Inner docker container $(INNER_DOCKER_CONTAINER_NAME) started"
