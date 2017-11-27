#!/usr/bin/env bash
#
# Script to run an OSD for testing. To run this script, make sure to
# have Ceph installed:
#
#   sudo apt install ceph ceph-common
#
# This script is based on https://github.com/ceph/go-ceph/blob/master/ci/micro-osd.sh
# and carries the same GNU Affero General Public License. See the license for more
# details (https://www.gnu.org/licenses/agpl-3.0.en.html).

set -e
set -u

DIR=$1

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# stop running osd (if any)
${SCRIPT_DIR}/osd_stop.sh ${DIR}

# cluster wide parameters
mkdir -p ${DIR}/log
cat >> ${DIR}/ceph.conf <<EOF
[global]
fsid = $(uuidgen)
osd crush chooseleaf type = 0
run dir = ${DIR}/run
auth cluster required = none
auth service required = none
auth client required = none
osd pool default size = 1
EOF
export CEPH_ARGS="--conf ${DIR}/ceph.conf"

# single monitor
MON_DATA=${DIR}/mon
mkdir -p $MON_DATA

cat >> ${DIR}/ceph.conf <<EOF
[mon.0]
log file = ${DIR}/log/mon.log
chdir = ""
mon cluster log file = ${DIR}/log/mon-cluster.log
mon data = ${MON_DATA}
mon addr = 127.0.0.1
EOF

ceph-mon --id 0 --mkfs --keyring /dev/null
touch ${MON_DATA}/keyring
ceph-mon --id 0

# single osd
OSD_DATA=${DIR}/osd
mkdir ${OSD_DATA}

cat >> ${DIR}/ceph.conf <<EOF
[osd.0]
log file = ${DIR}/log/osd.log
chdir = ""
osd data = ${OSD_DATA}
osd journal = ${OSD_DATA}.journal
osd journal size = 100
osd objectstore = memstore
EOF

OSD_ID=$(ceph osd create)
ceph osd crush add osd.${OSD_ID} 1 root=default host=localhost
ceph-osd --id ${OSD_ID} --mkjournal --mkfs
ceph-osd --id ${OSD_ID}

# Create a test pool and image
ceph osd pool create test 128
rbd create test/image --size 1M --image-feature layering

# check that it works
ceph osd tree
ceph health

echo "Ceph OSD running (${DIR}/ceph.conf) ..."
export CEPH_CONF="${DIR}/ceph.conf"