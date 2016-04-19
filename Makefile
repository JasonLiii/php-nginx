#!/usr/bin/make -f
IMAGE := $(shell basename $(shell pwd))
VERSION := latest

.PHONY: build

# ------------------------------------------------------------------------------

all: build

build:
	docker build -t=$(IMAGE):$(VERSION) .
