# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# NOTE: For targets run `make help`. <>

SHELL = /usr/bin/env bash

BD := $(shell tput bold)
BL := $(shell tput setaf 4)
CY := $(shell tput setaf 6)
RS := $(shell tput sgr0)

.PHONY: help
help:
	@printf '\n\
$(BD)main:$(RS)\n\
\n\
$(CY)all$(RS)       - $(BL)installs build targets.$(RS)\n\
$(CY)clean$(RS)     - $(BL)uninstalls build targets.$(RS)\n\
$(CY)reset$(RS)     - $(BL)resets the project.$(RS)\n\
\n\
$(BD)build:$(RS)\n\
\n\
$(CY)apt$(RS)       - $(BL)installs apt packages.$(RS)\n\
$(CY)python$(RS)    - $(BL)installs python.$(RS)\n\
$(CY)pip$(RS)       - $(BL)installs pip packages.$(RS)\n\
$(CY)venv$(RS)      - $(BL)creates the python venv.$(RS)\n\
\n\
$(BD)utility:$(RS)\n\
\n\
$(CY)container$(RS) - $(BL)creates the debian container.$(RS)\n\
$(CY)rm$(RS)        - $(BL)removes the debian container.$(RS)\n\
$(CY)start$(RS)     - $(BL)starts the debian container.$(RS)\n\
$(CY)run$(RS)       - $(BL)runs harmony.$(RS)\n\
\n'

.PHONY: rm
reset:
ifeq ($(shell $(call container_exists,$(NAME))),0)	
	podman rm $(NAME) 
endif

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
	cd /tmp && \
	wget --directory-prefix /tmp --$(PY_URL) | tar x && \
	cd $(PY_DIR) && \
 	./configure && \
	make && \
	sudo make install	
endif

.PHONY: install
install: apt python pip 

.PHONY: run
run: install
	$(call activate); \
	src/main.py

.PHONY: pip
pip: $(VENV)
	$(call activate); \
	python3 -m pip install -r requirements.txt

.PHONY: exec-main
exec-main:
	src/main.py || $(info run failed.)

define activate
source $(VENV)/bin/activate
endef

define dpkg-query 
status=$$(dpkg-query --show --showformat='$${db:Status-Status}' $(1) 2>/dev/null); \
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
	python3 -m venv .venv

.PHONY: apt
apt: $(APT_PACKAGES)

.PHONY: $(APT_PACKAGES)
$(APT_PACKAGES) &:
	sudo apt-get update
	sudo apt-get install $(APT_PACKAGES)

COMMITISH = @{u}
REVISION  = $(shell git rev-parse --abbrev-ref $(COMMITISH))
REMOTE    = $(shell cut -d/ -f1 <<<$(REVISION))
NAME      = $(shell basename $$(git remote get-url $(REMOTE)) .git)

define container_exists
podman container exists $(1) 2>/dev/null; echo $$?
endef

 .PHONY: container
container: IMAGE = debian:bookworm-slim
container:
ifeq ($(shell $(call container_exists,$(NAME))),1)	
	podman create \
	--tty \
  --interactive \
  --mount type=bind,source=$(PWD),destination=/src \
  --name $(NAME) \
  -- $(IMAGE) 
endif

.PHONY: shell
shell:
	podman start --attach -- $(NAME)

.PHONY: clean
clean:
	rm -fr$(V) $(VENV)

.PHONY: reset
reset: clean
ifeq ($(shell $(call container_exists,$(NAME))),0)	
	podman rm $(NAME) 
endif
	git config --local --remove-section user 2>/dev/null || [[ $$? -eq 128 ]]

FORCE:

