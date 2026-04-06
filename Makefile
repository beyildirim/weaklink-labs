# WeakLink Labs — Makefile
# Structured lifecycle management for the training platform.

SHELL := /bin/bash
NAMESPACE := weaklink
HELM_RELEASE := weaklink-labs
HELM_CHART := helm/weaklink-labs

.DEFAULT_GOAL := help

# ──────────────────────────────────────────────
# Lifecycle
# ──────────────────────────────────────────────

.PHONY: start stop restart status

start: ## Start the entire platform (idempotent)
	@./start.sh

stop: ## Tear down the platform
	@./stop.sh

restart: stop start ## Full restart (stop + start)

# ──────────────────────────────────────────────
# Build
# ──────────────────────────────────────────────

.PHONY: build build-guide build-workstation build-lab-setup

build: build-guide build-workstation build-lab-setup ## Build all Docker images

build-guide: ## Build the guide image
	@eval $$(minikube docker-env) && \
		docker build -t weaklink-labs/guide:latest -f images/guide/Dockerfile .

build-workstation: ## Build the workstation image
	@eval $$(minikube docker-env) && \
		docker build -t weaklink-labs/workstation:latest -f images/workstation/Dockerfile .

build-lab-setup: ## Build the lab-setup image
	@eval $$(minikube docker-env) && \
		docker build -t weaklink-labs/lab-setup:latest -f images/lab-setup/Dockerfile .

# ──────────────────────────────────────────────
# Deploy
# ──────────────────────────────────────────────

.PHONY: deploy deploy-dry-run lint

deploy: build ## Build images and deploy via Helm
	@eval $$(minikube docker-env) && \
		helm upgrade --install $(HELM_RELEASE) $(HELM_CHART) \
			-n $(NAMESPACE) --create-namespace \
			--wait --timeout 5m

deploy-dry-run: ## Preview what Helm would deploy
	@helm template $(HELM_RELEASE) $(HELM_CHART)

lint: ## Lint the Helm chart
	@helm lint $(HELM_CHART)

# ──────────────────────────────────────────────
# Docker Compose (Alternative to Minikube)
# ──────────────────────────────────────────────

.PHONY: compose-up compose-down compose-logs compose-build

compose-up: ## Start the platform using Docker Compose
	@docker-compose up -d

compose-down: ## Tear down the Docker Compose platform
	@docker-compose down -v

compose-logs: ## View Docker Compose logs
	@docker-compose logs -f

compose-build: ## Build images using Docker Compose
	@docker-compose build

# ──────────────────────────────────────────────
# Observe
# ──────────────────────────────────────────────

.PHONY: status pods logs logs-setup events

status: ## Show pod status
	@kubectl get pods -n $(NAMESPACE) -o wide

pods: status ## Alias for status

logs: ## Tail logs for all pods
	@for pod in $$(kubectl get pods -n $(NAMESPACE) -o jsonpath='{.items[*].metadata.name}'); do \
		echo ""; \
		echo "--- $$pod ---"; \
		kubectl logs "$$pod" -n $(NAMESPACE) --all-containers --tail=20 2>&1 || true; \
	done

logs-setup: ## View lab-setup job logs
	@kubectl logs -n $(NAMESPACE) job/lab-setup --all-containers 2>&1 || echo "No lab-setup job found."

events: ## Show recent cluster events
	@kubectl get events -n $(NAMESPACE) --sort-by='.lastTimestamp' | tail -20

# ──────────────────────────────────────────────
# Development
# ──────────────────────────────────────────────

.PHONY: shell guide-dev test test-tier verify

shell: ## Open a shell in the workstation pod
	@./cli/weaklink shell

guide-dev: ## Serve the guide locally with hot-reload (no k8s needed)
	@cd guide && mkdocs serve -a 0.0.0.0:8000

test: ## Run all lab verify scripts against the cluster
	@WORKSTATION_POD=$$(kubectl get pod -n $(NAMESPACE) \
		-l app.kubernetes.io/component=workstation \
		-o jsonpath='{.items[0].metadata.name}') && \
	FAILED=0 && \
	for verify_script in $$(find labs -name "verify.sh" -type f | sort); do \
		LAB_NAME=$$(basename $$(dirname "$$verify_script")) && \
		kubectl cp "$$verify_script" "$(NAMESPACE)/$$WORKSTATION_POD:/tmp/verify.sh" && \
		if kubectl exec "$$WORKSTATION_POD" -n $(NAMESPACE) -- bash /tmp/verify.sh; then \
			echo "  ✓ $$LAB_NAME"; \
		else \
			echo "  ✗ $$LAB_NAME"; \
			FAILED=$$((FAILED + 1)); \
		fi; \
	done && \
	echo "" && \
	if [ "$$FAILED" -gt 0 ]; then \
		echo "$$FAILED lab(s) failed." && exit 1; \
	else \
		echo "All labs passed."; \
	fi

verify: test ## Alias for test

# ──────────────────────────────────────────────
# Cleanup
# ──────────────────────────────────────────────

.PHONY: teardown clean clean-images

teardown: stop ## Alias for stop

clean: stop ## Stop platform and delete minikube cluster
	@minikube delete 2>/dev/null || true
	@echo "Cluster deleted."

clean-images: ## Remove all weaklink Docker images from minikube
	@eval $$(minikube docker-env) && \
		docker images --filter=reference='weaklink-labs/*' -q | xargs -r docker rmi -f
	@echo "Images cleaned."

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
