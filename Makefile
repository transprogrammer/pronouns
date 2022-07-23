# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# NOTE: For targets run `make help`. <>

SHELL = /usr/bin/env bash

ifneq ($(TRACE),yes)
  Q = @
endif

.PHONY: help
help:
	$(Q)echo
	$(Q)echo '$(BD)Main:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)install$(RS) - $(BL)runs install targets.$(RS)'
	$(Q)echo '$(CY)run$(RS)     - $(BL)runs harmony.$(RS)'
	$(Q)echo '$(CY)clean$(RS)   - $(BL)cleans up file targets.$(RS)'
	$(Q)echo '$(CY)reset$(RS)   - $(BL)resets the project.$(RS)'
	$(Q)echo
	$(Q)echo '$(BD)Install:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)apt$(RS)     - $(BL)installs apt packages.$(RS)'
	$(Q)echo '$(CY)python$(RS)  - $(BL)installs python.$(RS)'
	$(Q)echo '$(CY)pip$(RS)     - $(BL)installs pip packages.$(RS)'
	$(Q)echo '$(CY)venv$(RS)    - $(BL)creates the python venv.$(RS)'
	$(Q)echo
	$(Q)echo '$(BD)Utility:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)shell$(RS)   - $(BL)starts an interactive shell in a docker dev env.$(RS)'
	$(Q)echo

BRANCH_NAME := $(shell git name-rev --name-only HEAD)

REMOTE_NAME := $(shell git config branch.$(BRANCH_NAME).remote)
REMOTE_URL  := $(shell git config remote.$(REMOTE_NAME).url)

REPO_NAME   := $(shell basename $(REMOTE_URL) .git)

BD := $(shell tput bold)
BL := $(shell tput setaf 4)
CY := $(shell tput setaf 6)
RS := $(shell tput sgr0)

VENV ?= .venv

APT_PACKAGES += build-essential
APT_PACKAGES += ccache
APT_PACKAGES += gdb
APT_PACKAGES += lcov
APT_PACKAGES += libb2-dev
APT_PACKAGES += libbz2-dev
APT_PACKAGES += libffi-dev
APT_PACKAGES += libgdbm-compat-dev
APT_PACKAGES += libgdbm-dev
APT_PACKAGES += liblzma-dev
APT_PACKAGES += libncurses5-dev
APT_PACKAGES += libreadline6-dev
APT_PACKAGES += libsqlite3-dev
APT_PACKAGES += libssl-dev
APT_PACKAGES += lzma
APT_PACKAGES += lzma-dev
APT_PACKAGES += pkg-config
APT_PACKAGES += tk-dev
APT_PACKAGES += uuid-dev
APT_PACKAGES += xvfb
APT_PACKAGES += zlib1g-dev



PY_VERS ?= 3.10.5
PY_DIR = Python-$(PY_VERS)
PY_URL = https://www.python.org/ftp/python/$(PY_VERS)/$(PY_DIR).tgz

define py-vers
python3 -V | cut -d ' ' -f 2
endef

.PHONY: python
python: apt
ifneq ($(shell $(call py-vers)),$(PY_VERS))
	$(Q)cd /tmp && \
	wget --directory-prefix /tmp --$(PY_URL) | tar x && \
	cd $(PY_DIR) && \
 	./configure && \
	make && \
	sudo make install	
endif

.PHONY: install
install: apt python pip 

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

define dpkg-query 
status=$$(dpkg-query --show --showformat='$${db:Status-Status}' $(1)); \
[[ $$status == installed ]]; \
echo $$?
endef

.PHONY: venv
ifeq ($(shell $(call dpkg-query,python3-venv)),0)
venv: $(VENV)
else
venv: python3-venv $(VENV)
	echo here:$(shell $(call dpkg-query,python3-venv))
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
shell: COMMITISH = @{u}
shell: REVISION := $(shell git rev-parse --abbrev-ref $(COMMITISH))
shell: REMOTE   := $(shell cut -d/ -f1 <<<$(REVISION))
shell: NAME     := $(shell basename $$(git remote get-url $(REMOTE)))
shell:
	$(Q)docker container exec -it -- $(NAME) \
	/usr/bin/env bash -c 'export REMOTE_CONTAINERS_IPC=\
	$$(find /tmp -name '\''vscode-remote-containers-ipc*'\'' \
	-type s -print

.PHONY: clean
clean:
	$(Q)rm -fr$(V) $(VENV)

.PHONY: reset
reset: clean
	$(Q)git config --local --remove-section user 2>/dev/null || [[ $$? -eq 128 ]]

FORCE:

