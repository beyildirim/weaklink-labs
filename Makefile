# WeakLink Labs — Makefile
# Structured lifecycle management for the training platform.

SHELL := /bin/bash
PYTHON ?= python3
NAMESPACE := weaklink
HELM_RELEASE := weaklink-labs
HELM_CHART := helm/weaklink-labs

.DEFAULT_GOAL := help

# ──────────────────────────────────────────────
# Lifecycle
# ──────────────────────────────────────────────

.PHONY: start stop restart status

start: ## Start the entire platform (idempotent)
	@$(PYTHON) -m weaklink_platform.cli start

stop: ## Tear down the platform
	@$(PYTHON) -m weaklink_platform.cli stop

restart: stop start ## Full restart (stop + start)

# ──────────────────────────────────────────────
# Build
# ──────────────────────────────────────────────

.PHONY: build build-guide build-workstation build-lab-setup

build: build-guide build-workstation build-lab-setup ## Build all Docker images

build-guide: ## Build the guide image
	@$(PYTHON) -m weaklink_platform.cli build-images guide

build-workstation: ## Build the workstation image
	@$(PYTHON) -m weaklink_platform.cli build-images workstation

build-lab-setup: ## Build the lab-setup image
	@$(PYTHON) -m weaklink_platform.cli build-images lab-setup

# ──────────────────────────────────────────────
# Deploy
# ──────────────────────────────────────────────

.PHONY: deploy deploy-dry-run lint

deploy: build ## Build images and deploy via Helm
	@$(PYTHON) -m weaklink_platform.cli deploy

deploy-dry-run: ## Preview what Helm would deploy
	@helm template $(HELM_RELEASE) $(HELM_CHART)

lint: ## Lint the Helm chart
	@helm lint $(HELM_CHART)

# ──────────────────────────────────────────────
# Docker Compose (Alternative to Minikube)
# ──────────────────────────────────────────────

.PHONY: compose-up compose-down compose-logs compose-build

compose-up: ## Start the platform using Docker Compose. Set WEAKLINK_IMAGE_TAG to pin a GHCR release.
	@docker compose up -d

compose-down: ## Tear down the Docker Compose platform
	@docker compose down -v

compose-logs: ## View Docker Compose logs
	@docker compose logs -f

compose-build: ## Build images using Docker Compose
	@docker compose build

# ──────────────────────────────────────────────
# Observe
# ──────────────────────────────────────────────

.PHONY: status pods logs logs-setup events

status: ## Show pod status
	@$(PYTHON) -m weaklink_platform.cli status

pods: status ## Alias for status

logs: ## Tail logs for all pods
	@$(PYTHON) -m weaklink_platform.cli logs

logs-setup: ## View lab-setup job logs
	@kubectl logs -n $(NAMESPACE) job/lab-setup --all-containers 2>&1 || echo "No lab-setup job found."

events: ## Show recent cluster events
	@kubectl get events -n $(NAMESPACE) --sort-by='.lastTimestamp' | tail -20

# ──────────────────────────────────────────────
# Development
# ──────────────────────────────────────────────

.PHONY: shell guide-dev docs-check test test-tier verify

shell: ## Open a shell in the workstation pod
	@./cli/weaklink shell

guide-dev: ## Serve the guide locally with hot-reload (no k8s needed)
	@cd guide && mkdocs serve -a 0.0.0.0:8000

docs-check: ## Build the guide strictly and fail on broken relative links
	@$(PYTHON) -m weaklink_platform.cli docs-check

test: ## Smoke test all lab environments against the cluster
	@$(PYTHON) -m weaklink_platform.cli smoke-test --namespace $(NAMESPACE)

verify: test ## Alias for test

# ──────────────────────────────────────────────
# Cleanup
# ──────────────────────────────────────────────

.PHONY: teardown clean clean-images

teardown: stop ## Alias for stop

clean: stop ## Stop platform and delete minikube cluster
	@$(PYTHON) -m weaklink_platform.cli clean

clean-images: ## Remove all weaklink Docker images from minikube
	@$(PYTHON) -m weaklink_platform.cli clean-images

.PHONY: sign sign-keyless

sign: ## Sign local Docker images with Cosign using a local key
	@$(PYTHON) -m weaklink_platform.cli sign-images

sign-keyless: ## Sign local Docker images with Cosign keyless OIDC flow
	@$(PYTHON) -m weaklink_platform.cli sign-images --keyless

# ──────────────────────────────────────────────
# Help
# ──────────────────────────────────────────────

.PHONY: help
help: ## Show this help
	@echo ""
	@echo "WeakLink Labs — Makefile targets"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
