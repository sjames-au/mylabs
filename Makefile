# Originally from: https://github.com/katapultmedia/training-drying-up-terraform
.ONESHELL:
.SHELL := /bin/bash
.PHONY: ALL
.DEFAULT_GOAL := help


help:
	@echo "Available targets:"
	@echo "Reminder: Only for MacOS"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check: ## Run any pre-commit tests you want outside of an acutal commit
	@pre-commit run -a

init: os_test ## Install required tools for local hygene checks
	@echo "Going to brew tap https://github.com/antonbabenko/pre-commit-terraform"
	@brew tap liamg/tfsec || exit 0
	@brew install pre-commit gawk terraform-docs tflint tfsec coreutils || exit 0
	@echo "NOTICE: You may also need to updated your git configuration for 'pre-commit' e.g.:"
	@echo "DIR=~/.git-template"
	@echo "git config --global init.templateDir ${DIR}"
	@echo "pre-commit init-templatedir -t pre-commit ${DIR}"

# TODO establish a bootstrao that enables the use of s3 and DynoDB for tfstate
bootstrap_vpc: os_test ## Prepare repository for use: will setup VPC and s3 for state
	@echo "Creating VPC and subnets"
	cd global/vpc && \
	terraform init && \
	terraform apply

tear_vpc_down: os_test ## Remove VPC and subnets
	@echo "Removing and destroying VPC/Subneys"
	cd global/vpc && \
	terraform init && \
	terraform destroy

fmt: os_test ## Formats the .tf files
	terraform fmt -recursive

plan: ## You need to include the comment for help
	cd terraform && \
	terraform init && \
	terraform plan

# Save me from myself if I am not running on MacOS - abort
UNAME_S := $(shell uname -s)
os_test:
ifeq ($(UNAME_S),Darwin)
	@echo "Only MacOS AFAIK."
	exit 1
endif

define PRE_COMMIT_INIT
NOTICE: You may also need to updated your git configuration for 'pre-commit'
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
endef