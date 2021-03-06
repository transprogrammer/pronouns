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
$(CY)all$(RS)             - $(BL)installs build targets.$(RS)\n\
$(CY)run$(RS)             - $(BL)runs harmony.$(RS)\n\
$(CY)clean$(RS)           - $(BL)uninstalls build targets.$(RS)\n\
$(CY)reset$(RS)           - $(BL)resets the project.$(RS)\n\
\n\
$(BD)build:$(RS)\n\
$(CY)apt$(RS)              - $(BL)installs apt packages.$(RS)\n\
$(CY)python$(RS)           - $(BL)installs python.$(RS)\n\
$(CY)pip$(RS)              - $(BL)installs pip packages.$(RS)\n\
$(CY)venv$(RS)             - $(BL)creates the python venv.$(RS)\n\
\n\
$(BD)podman:$(RS)\n\
$(CY)machine$(RS)          - $(BL)creates the machine.$(RS)\n\
$(CY)start-machine$(RS)    - $(BL)starts the machine.$(RS)\n\
$(CY)stop-machine$(RS)     - $(BL)starts the machine.$(RS)\n\
$(CY)restart-machine$(RS)  - $(BL)restarts the machine.$(RS)\n\
$(CY)remove-machine$(RS)   - $(BL)removes the machine.$(RS)\n\
$(CY)container$(RS)        - $(BL)creates the container.$(RS)\n\
$(CY)start-container$(RS)  - $(BL)starts the container.$(RS)\n\
$(CY)remove-container$(RS) - $(BL)removes the container.$(RS)\n\
\n'

.PHONY: rm
reset:
ifeq ($(shell $(call container_exists,$(CONTAINER))),0)	
	podman rm $(CONTAINER) 
endif

VENV ?= .venv

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

MACHINE = podman-machine-default

COMMITISH = @{u}
REVISION  = $(shell git rev-parse --abbrev-ref $(COMMITISH))
REMOTE    = $(shell cut -d/ -f1 <<<$(REVISION))
CONTAINER = $(shell basename $$(git remote get-url $(REMOTE)) .git)

define machine_exists
podman machine inspect $(MACHINE) >/dev/null 2>&1; echo $$?
endef

.PHONY: machine
machine:
ifeq ($(shell $(call machine_exists)),125)
	podman machine init
endif

define machine_running
state=$$(podman machine inspect $(MACHINE) | jq -r .[0].State); 
[[ $$state == running ]];
echo $$?
endef

define command_machine
podman machine $(1) $(MACHINE)
endef

.PHONY: start-machine
start-machine: machine
	$(if $(filter $(shell $(call machine_running)),1),\
	$(call command_machine,start),\
	$(error here))

.PHONY: stop-machine
stop-machine:
	podman machine stop $(MACHINE)

.PHONY: remove-machine
remove-machine:
	podman machine rm $(MACHINE)

.PHONY: restart-machine
ifeq ($(shell $(call machine_exists)),125)	
restart-machine: stop-machine start-machine
	$(error machine $(MACHINE) does not exist.)
else
restart-machine: stop-machine start-machine
endif

define container_exists
podman container exists $(1) 2>/dev/null; echo $$?
endef

 .PHONY: container
container: IMAGE = debian:bookworm-slim
container:
ifeq ($(shell $(call container_exists,$(CONTAINER))),1)	
	podman create \
	--tty \
  --interactive \
  --mount type=bind,source=$(PWD),destination=/src \
  --name $(CONTAINER) \
  -- $(IMAGE) 
endif

.PHONY: start-container
start-container: container
	podman start --attach -- $(CONTAINER)

.PHONY: remove-container
remove-container:
ifeq ($(shell $(call container_exists,$(CONTAINER))),0)	
	podman rm $(CONTAINER) 
endif

.PHONY: clean
clean:
	rm -fr$(V) $(VENV)

.PHONY: reset
reset: remove-container clean
	git config --local --remove-section user 2>/dev/null || [[ $$? -eq 128 ]]

FORCE:

