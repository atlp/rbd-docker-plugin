VERSION=build
PACKAGE=target/rbd-docker-plugin-$(VERSION)

.PHONY: all build clean version

all: build

version: ../../version.go
	$(eval VERSION := $(shell grep "VERSION" ../../version.go | cut -f2 -d'"'))

build: version
	echo "$(PACKAGE)"
	mkdir -p $(PACKAGE)
	cp -Rv ../../etc $(PACKAGE)
	cp -Rv DEBIAN $(PACKAGE)
	sed -i "s|Version:.*|Version: $(VERSION)|" $(PACKAGE)/DEBIAN/control
	mkdir -p $(PACKAGE)/usr/local/bin
	cp ../../dist/rbd-docker-plugin $(PACKAGE)/usr/local/bin
	dpkg-deb --build $(PACKAGE)

clean:
	rm -rf ./target

