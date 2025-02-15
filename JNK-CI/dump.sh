#!/bin/bash
# Script that:
#- dump galaxy galaxy-tools db in $DUMP_DIR
#- create the _conda directory and shed_tool dir tarball  in $DUMP_DIR
#- copy the shed_tool_conf.xml file  in $DUMP_DIR

DUMP_ROOT=/tmp/dump
G_DIR=/home/galaxy/galaxy
G_SHEDTOOLS_DIR=/home/galaxy/galaxy/var/shed_tools
G_CONDA_DIR=/export/tool_deps/_conda

usage() { echo "Usage $0:
-f flavour_name 
-v flavour_version 
-i image
optional:

-d dump_dir: directory that will contain the flavour package Files DEFAULT: /tmp/dump
-c galaxy root directory DEFAULT /home/galaxy/galaxy
-s galaxy shedtools dir  DEFAULT /home/galaxy/galaxy/var/shed_tools
-t conda dir DEFAULT /export/tool_deps/_conda
-p use pigz for faster gzip
	" 1>&2; exit 1; }

while getopts "d:c:s:t:v:f:pi:" o; do
    case "${o}" in

        d)
            DUMP_ROOT=${OPTARG}
            ;;
        c)
            G_DIR=${OPTARG}
            ;;
        s)
            G_SHEDTOOLS_DIR=${OPTARG}
            ;;
        t)
            G_CONDA_DIR=${OPTARG}
            ;;
        v)
            f_version=${OPTARG}
            ;;
        i)
            image=${OPTARG}
            ;;
        f)
            f_name=${OPTARG}
            ;;
        p)
           pigz=true
           ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${f_version}" ] || [ -z "${f_name}" ] || [ -z "${image}" ]; then
    usage
fi

G_CONFIG_DIR=${G_DIR}/config
G_SERVER_DIR=${G_DIR}/server

sudo su - postgres << BASH
pg_dump -f galaxy_tools.psql galaxy_tools;
BASH

g_version=$( cd $G_SERVER_DIR && git branch | awk '/release/ { print $2}')
DUMP_DIR=${DUMP_ROOT}/${image}_${g_version}_${f_name}_${f_version}
mkdir -p $DUMP_DIR && chown -R galaxy:galaxy $DUMP_DIR ;
mv /var/lib/pgsql/galaxy_tools.psql $DUMP_DIR/dump.psql &>$DUMP_DIR/dump.log &
cp $G_CONFIG_DIR/shed_tool_conf.xml $DUMP_DIR &>> $DUMP_DIR/dump.log &
if ( $pigz )

then
echo "using pigz";

cd $G_SHEDTOOLS_DIR && tar cf $DUMP_DIR/tar_shed_tools.tar.gz -I pigz . &>>$DUMP_DIR/dump.log && echo 'Shed_tool dump_package created' &
cd $G_CONDA_DIR/.. && tar cf $DUMP_DIR/tar_conda.tar.gz -I pigz . &>>$DUMP_DIR/dump.log && echo 'Conda dump_package created' &

else
cd $G_SHEDTOOLS_DIR && tar cf $DUMP_DIR/tar_shed_tools.tar.gz . &>>$DUMP_DIR/dump.log && echo 'Shed_tool dump_package created' &
cd $G_CONDA_DIR/.. && tar cf $DUMP_DIR/tar_conda.tar.gz . &>>$DUMP_DIR/dump.log && echo 'Conda dump_package created' &


fi

wait

WORKFLOW_DIR="/data/Galaxy-flavours/${f_name}/workflows"

if [ -d "$WORKFLOW_DIR" ];

then
	cp -R $WORKFLOW_DIR $DUMP_DIR
fi

echo "packages created"

