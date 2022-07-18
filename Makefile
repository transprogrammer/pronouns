# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# NOTE: For a list of targets, run `make help`. <skr>

NAME = euphony

SHELL = /usr/bin/env bash

TRACE ?= no

ifeq ($(TRACE),yes)
  V = v
else
  Q = @
endif

BD := $(shell tput bold)
BL := $(shell tput setaf 4)
CY := $(shell tput setaf 6)
RS := $(shell tput sgr0)

VENV ?= .venv

APT_PACKAGES ?= python3-pip python3-venv

.PHONY: help
help:
	$(Q)echo
	$(Q)echo '$(BD)Main:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)install$(RS) - $(BL)runs install targets.$(RS)'
	$(Q)echo '$(CY)run$(RS)     - $(BL)runs harmony.$(RS)'
	$(Q)echo '$(CY)clean$(RS)     - $(BL)cleans up file targets.$(RS)'
	$(Q)echo
	$(Q)echo '$(BD)Install:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)apt$(RS)     - $(BL)installs apt packages.$(RS)'
	$(Q)echo '$(CY)pip$(RS)     - $(BL)installs pip packages.$(RS)'
	$(Q)echo '$(CY)venv$(RS)    - $(BL)creates the python venv.$(RS)'
	$(Q)echo
	$(Q)echo '$(BD)Utility:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)shell$(RS)   - $(BL)starts an interactive shell in a docker dev env.$(RS)'
	$(Q)echo

.PHONY: pip
install: apt pip 

.PHONY: run
run:
	$(Q)$(call activate); \
	src/main.py

.PHONY: pip
pip: $(VENV)
	$(Q)$(call activate); \
	python3 -m pip install -r requirements.txt

.PHONY: exec-main
exec-main:
	$(Q)src/main.py || $(info run failed.)

define activate
source $(VENV)/bin/activate
endef

.PHONY: venv
ifeq ($(shell dpkg-query -W --showformat='$${db:Status-Status}' python3-venv),installed)
venv: $(VENV)
else
venv: python3-venv $(VENV)
endif

$(VENV):
	$(Q)python3 -m venv .venv

.PHONY: apt
apt: $(APT_PACKAGES)

.PHONY: $(APT_PACKAGES)
$(APT_PACKAGES) &:
	$(Q)sudo apt-get update
	$(Q)sudo apt-get install $(APT_PACKAGES)

.PHONY: shell
shell:
	$(Q)docker container exec -it -- $(NAME) /usr/bin/env bash -c ' \
	  export REMOTE_CONTAINERS_IPC=$$( \
	    find /tmp -name '\''vscode-remote-containers-ipc*'\'' -type s \
	      -echo "%T@ %p\n" | sort -n | cut -d " " -f 2- | tail -n 1);$$SHELL -l'

.PHONY: clean
clean:
	$(Q)rm -fr$(V) $(VENV)

FORCE:

