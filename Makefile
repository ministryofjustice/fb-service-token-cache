dev:
	$(eval export env_stub=dev)
	@true

staging:
	$(eval export env_stub=staging)
	@true

production:
	$(eval export env_stub=production)
	@true

init:
	$(eval export ECR_REPO_NAME=fb-service-token-cache)
	$(eval export ECR_REPO_URL=926803513772.dkr.ecr.eu-west-1.amazonaws.com/formbuilder-dev/fb-service-token-cache)

# Needs ECR_REPO_NAME & ECR_REPO_URL env vars
install_build_dependencies: init
	# install aws cli w/o sudo
	docker --version
	pip install --user awscli
	$(eval export PATH=${PATH}:${HOME}/.local/bin/)
	echo $(shell which aws)


build: install_build_dependencies
	docker build -t ${ECR_REPO_NAME}:latest-${env_stub} -f docker/Dockerfile . && \
		docker tag ${ECR_REPO_NAME}:latest-${env_stub} ${ECR_REPO_URL}:latest-${env_stub}

login: init
	@eval $(shell aws ecr get-login --no-include-email --region eu-west-1)

push: login
	docker push ${ECR_REPO_URL}:latest-${env_stub}

.PHONY := init push build login
