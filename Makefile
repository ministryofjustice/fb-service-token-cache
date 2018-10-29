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

install_build_dependencies: init
	# Needs ECR_REPO_NAME & ECR_REPO_URL env vars
	# document the version travis is using
	docker --version && \
	  pip install --upgrade pip && \
		# install aws cli w/o sudo
	  pip install --user awscli && \
		# put aws in the path
	  $(eval export PATH=$PATH:$HOME/.local/bin)

build: init
	docker build -t ${ECR_REPO_NAME}:latest-${env_stub} -f docker/Dockerfile . && \
	  docker tag ${ECR_REPO_NAME}:latest-${env_stub} ${ECR_REPO_URL}:latest-${env_stub}

login: init
	# needs AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY envvars
	# have to use backticks as cmd-substitution somehow results in empty string
	eval "`aws ecr get-login --no-include-email --region eu-west-1`"

push: login
	docker push ${ECR_REPO_URL}:latest-${env_stub}

.PHONY := init push build login
