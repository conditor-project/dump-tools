#!/bin/bash

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then
    echo "usage : ./restore-es-dump <dump_dir> <es_host> <es_port>"
    echo "   OR : ./restore-es-dump --dev|--integ|--prod"
    echo " !!! Port is fixed at '9200'"
    exit 
fi

today=`date +%Y%m%d`
es_host='localhost'
es_env="$es_host"
es_port="$es_port"

if [ "$1" = "--dev" ]; then
    es_host="vd-conditor-es.intra.inist.fr"
    es_env="dev"
elif [ "$1" = "--integ" ]; then
    es_host="vi-conditor-es.intra.inist.fr"
    es_env="integ"
elif [ "$1" = "--prod" ]; then
    es_host="vp-conditor-es.intra.inist.fr"
    es_env="prod"
elif [ "$1" != "" ]; then
    es_host="$2"
    es_port="$3"
    es_env="$es_host"
fi

if [ "$es_index" = "" ]; then
    es_index=records
fi

dump_dir="$1"

if [ ! -d "$dump_dir" ]; then
    echo "Le répertoire de dump $dump_dir n'exist pas, on s'arrête..."
    exit 1
fi
echo "Dump settings from $dump_dir/settings.json to http://$es_host:$es_port/$es_index"
elasticdump --output http://$es_host:$es_port/$es_index --type settings --input=$dump_dir/settings.json

echo "Dump analyzers from $dump_dir/analyzer.json to http://$es_host:$es_port/$es_index"
elasticdump --output http://$es_host:$es_port/$es_index --type analyzer --input=$dump_dir/analyzer.json

echo "Dump mapping from $dump_dir/mapping.json to http://$es_host:$es_port/$es_index"
elasticdump --output http://$es_host:$es_port/$es_index --type mapping --input=$dump_dir/mapping.json

echo "Dump date from $dump_dir/data.json to http://$es_host:$es_port/$es_index"
elasticdump --output http://$es_host:$es_port/$es_index --type data --input=$dump_dir/data.json

