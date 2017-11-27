#!/usr/bin/env bash

DIR=$1

pkill ceph-mon || true
pkill ceph-osd || true
pkill ceph-mds || true
rm -fr ${DIR}
