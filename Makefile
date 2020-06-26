# Originally from: https://github.com/katapultmedia/training-drying-up-terraform

# TODO check one password is signed in before execution
# TODO Add a SSH key an generation action
# TODO Add a ssh trusted host clearer action
.ONESHELL:
.SHELL := /bin/bash
.PHONY: ALL
.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "Reminder: Only tested on MacOS"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check: ## Run any pre-commit tests you want outside of an acutal commit
	@pre-commit run -a

# TODO identify requirements and just check everything looks OK
# init: os_test ## Install required tools for local hygene checks

core: os_test bootstrap_vpc bastion ## Bring up VPC, Subnets, Basion and NAT

tear_core_down: os_test tear_bastion_down tear_vpc_down ## Destroy VPC, Subnets, Bastion and NAT

bootstrap_vpc: os_test ## Prepare repository for use: will setup VPC and subnets
	@echo "Creating VPC and subnets"
	cd global/vpc && \
	terraform init && \
	terraform apply

tear_vpc_down: os_test ## Remove VPC and subnets
	@echo "Removing and destroying VPC/Subnets"
	cd global/vpc && \
	terraform init && \
	terraform destroy

bastion: bootstrap_vpc ## Bring up bastion and NAT service
	cd services/nat-instance && \
	terraform init && \
	direnv exec . terraform apply && \
	echo "Remember - ssh-keygen -R _BASTION_"

tear_bastion_down: ## Destory Bastion and NAT service
	cd services/nat-instance && \
	terraform init && \
	direnv exec . terraform destroy

# Save me from myself if I am not running on MacOS - abort
UNAME_S := $(shell uname -s)
os_test:
ifneq ($(UNAME_S),Darwin)
	@echo "Only MacOS AFAIK."
	exit 1
endif

define PRE_COMMIT_INIT
NOTICE: You may also need to updated your git configuration for 'pre-commit'
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
endef