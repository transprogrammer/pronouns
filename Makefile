# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# NOTE: For a list of targets, run `make help`. <skr>

DEBUG ?= no

ifeq (DEBUG,yes)
  Q =
else
  Q = @
endif

BD := $(shell tput bold)
BL := $(shell tput setaf 4)
MG := $(shell tput setaf 5)
CY := $(shell tput setaf 6)
RS := $(shell tput sgr0)

.PHONY: help
help:
	$(Q)echo
	$(Q)echo '$(BD)Main:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)install$(RS) - $(BL)runs install targets$(RS)'
	$(Q)echo '$(CY)run$(RS)     - $(BL)runs harmony$(RS)'
	$(Q)echo
	$(Q)echo '$(BD)Install:$(RS)'
	$(Q)echo
	$(Q)echo '$(CY)apt$(RS)     - $(BL)installs apt packages (pip, venv)$(RS)'
	$(Q)echo '$(CY)pip$(RS)     - $(BL)installs pip packages from requirements.txt$(RS)'
	$(Q)echo '$(CY)venv$(RS)    - $(BL)creates the python virtual environment$(RS)'
	$(Q)echo

SHELL = /usr/bin/env bash

VENV = .venv

.PHONY: apt-get install pip venv

install : apt pip venv

apt:
	sudo apt-get update
	sudo apt-get install python3-pip python3-venv

venv : $(VENV)
$(VENV):
	python3 -m venv .venv

pip: $(VENV)
	$(call activate); \
	pip install -r requirements.txt

define activate
	source $(VENV)/bin/activate
endef

.PHONY: run
run : pip
	src/main.py

