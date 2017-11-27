# building the rbd docker plugin golang binary

.PHONY: all build install clean test dep-tool

TMPDIR?=/tmp
INSTALL?=install

BINARY=rbd-docker-plugin
PKG_SRC=main.go driver.go version.go
PKG_SRC_TEST=$(PKG_SRC) driver_test.go unlock_test.go


all: build

dep-tool:
	go get -u github.com/golang/dep/cmd/dep

vendor: dep-tool
	dep ensure

dist:
	mkdir dist

dist/$(BINARY): $(PKG_SRC) vendor
	go build -v -x -o dist/$(BINARY) .

build: dist/$(BINARY)

test: vendor
	TMP_DIR=$$(mktemp -d) && \
		./resources/ceph-test/osd_start.sh $$TMP_DIR && \
		export CEPH_CONF=$${TMP_DIR}/ceph.conf && \
		ceph -s && \
		go test -v && \
		./resources/ceph-test/osd_stop.sh $$TMP_DIR

install: build test
	go install .

clean:
	go clean
	rm -f dist/$(BINARY)
	rm -fr vendor/
