OS := $(shell uname)

NAME := $(shell cat $(HOME)/NAME)
VERSION := $(shell cat $(HOME)/VERSION)

REGISTRY := $(shell cat $(HOME)/REGISTRY)
CHARTMUSEUM := $(shell cat $(HOME)/CHARTMUSEUM)

draft-init:
	draft version
	draft init
ifeq ($(REGISTRY),)
	draft config set registry $(REGISTRY)
endif

draft-up: draft-init
	sed -i -e "s/NAMESPACE/$(NAMESPACE)/g" draft.toml
	sed -i -e "s/NAME/$(NAME)-$(NAMESPACE)/g" draft.toml
	draft up -e $(NAMESPACE)

helm-init:
	helm version
	helm init --client-only
ifeq ($(CHARTMUSEUM),)
	helm repo add chartmuseum https://$(CHARTMUSEUM)
endif
	helm repo list
	helm repo update
	helm plugin install https://github.com/chartmuseum/helm-push
	helm plugin list

build-image:
	docker build -t $(REGISTRY)/$(NAME):$(VERSION) .
	docker push $(REGISTRY)/$(NAME):$(VERSION)

build-chart: helm-init
	helm lint .
ifeq ($(CHARTMUSEUM),)
	helm push . chartmuseum
endif
	helm repo update
	helm search $(NAME)

deploy: helm-init
	helm upgrade --install $(NAME)-$(NAMESPACE) chartmuseum/$(NAME) --version $(VERSION) --namespace $(NAMESPACE) --devel --set fullnameOverride=$(NAME)-$(NAMESPACE)
	helm history $(NAME)-$(NAMESPACE)

remove: helm-init
	helm search $(NAME)
	helm history $(NAME)-$(NAMESPACE)
	helm delete --purge $(NAME)-$(NAMESPACE)
