# Lab 0 -- Environment & Toolchain Warm-up
# Do not modify this file.

COMPOSE   ?= docker compose
CONTAINER ?= lab0

.PHONY: all help pretest build up test test-offline policy check-update update shell logs clean

all: up test

help:
	@echo "make pretest       diagnose Docker engine host prerequisites (non-scoring)"
	@echo "make up            build and start the supplied Lab 0 environment"
	@echo "make test          check release freshness, policy, and all Lab 0 checks"
	@echo "make test-offline  run policy and Lab 0 checks without a freshness claim"
	@echo "make check-update  compare your starter with the required release"
	@echo "make update        prepare a lossless instructor/update-<tag> branch"

pretest:
	@python3 -B .github/golden/pretest.py

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d --build
	@echo "waiting for $(CONTAINER) to be ready ..."
	@sh tests/wait_ready.sh

policy:
	@bash .github/policy/00_layout.sh
	@bash .github/policy/01_integrity.sh

check-update:
	@python3 .github/release/upgrade.py check

update:
	@python3 .github/release/upgrade.py update

define run_lab_checks
@sh tests/00_env.sh
@sh tests/10_ovs.sh
@sh tests/20_ping.sh
@sh tests/30_pingall.sh
@sh tests/40_git.sh
@echo ""
@echo "All five checks passed."
endef

test: check-update policy
	$(run_lab_checks)

test-offline: policy
	@echo "OFFLINE local run: remote release freshness is NOT checked."
	@echo "Official grading still enforces canonical protected files and release metadata."
	$(run_lab_checks)

shell:
	docker exec -it $(CONTAINER) bash

logs:
	-$(COMPOSE) ps
	-$(COMPOSE) logs --no-color --tail=200

clean:
	-docker exec $(CONTAINER) mn -c >/dev/null 2>&1 || true
	-$(COMPOSE) down -v --remove-orphans
