VERSION="build"

all: build

version: ../../version.go
	$(eval VERSION := $(shell grep "VERSION" ../../version.go | cut -f2 -d'"'))

build: version
	mkdir -p ./target
	cp -Rv ../../etc target/
	cp -Rv DEBIAN target/
	echo $(VERSION)
	sed -i "s|Version:.*|Version: $(VERSION)|" target/DEBIAN/control
	mkdir -p ./target/usr/local/bin
	cp ../../dist/rbd-docker-plugin target/usr/local/bin

clean:
	rm -rf ./target

