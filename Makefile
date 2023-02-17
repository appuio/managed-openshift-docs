pages   := $(shell find . -type f -name '*.adoc')
out_dir := ./_archive
web_dir := ./_public

docker_cmd  ?= docker
docker_opts ?= --rm --tty --user "$$(id -u)"

antora_cmd  ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}":/antora vshn/antora:3.0.0
antora_opts ?= --cache-dir=.cache/antora
preview_cmd ?= $(docker_cmd) run --rm --publish 35729:35729 --publish 2020:2020 --volume "${PWD}":/preview/antora vshn/antora-preview:3.1.1.1 --antora=docs --style=appuio

vale_cmd ?= $(docker_cmd) run $(docker_opts) --volume "$${PWD}"/docs/modules:/pages vshn/vale:2.10.5.1 --minAlertLevel=error /pages

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
	OS = linux-x64
	OPEN = xdg-open
endif
ifeq ($(UNAME), Darwin)
	OS = darwin-x64
	OPEN = open
endif

.PHONY: all
all: html open

.PHONY: clean
clean:
	rm -rf $(out_dir) $(web_dir) .cache

.PHONY: open
open: $(web_dir)/index.html
	-$(OPEN) $<

.PHONY: html
html:    $(web_dir)/index.html

$(web_dir)/index.html: playbook.yml $(pages)
	$(antora_cmd) $(antora_opts) $<

.PHONY: check
check:
	$(vale_cmd)

.PHONY: preview
preview:
	$(preview_cmd)
