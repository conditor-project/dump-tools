#!/bin/bash

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then
    echo "usage : ./make-es-dump <es_host> (localhost by default)"
    echo "   OR : ./make-es-dump --dev|--integ|--prod"
    echo " !!! Port is fixed at '9200'"
    exit 
fi

today=`date +%Y%m%d`
es_host='localhost'
es_env="$es_host"
es_port='9200'

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
    es_host="$1"
    es_env="$es_host"
fi

dump_dir="$es_env-$today"
dump_file="$es_env-$today.tar.gz"

if [ -d "$dump_dir" ]; then
    echo "Le répertoire de dump $dump_dir exist déjà, on s'arrête..."
    exit 1
fi
if [ -f "$dump_file" ]; then
    echo "Le fichier de dump $dump_file exist déjà, on s'arrête..."
    exit 1
fi

if [ -z "$es_index" ]; then
    es_index='records'
fi

mkdir "$dump_dir"

elasticdump --input http://$es_host:9200/$es_index --type data --output=$dump_dir/data.json
elasticdump --input http://$es_host:9200/$es_index --type analyzer --output=$dump_dir/analyzer.json
elasticdump --input http://$es_host:9200/$es_index --type settings --output=$dump_dir/settings.json
elasticdump --input http://$es_host:9200/$es_index --type mapping --output=$dump_dir/mapping.json

tar cvzf "$dump_dir-$es_index.tar.gz" "$dump_dir"
rm -rf "$dump_dir"



# Utilisé pour extraire les données de test pour l'API
# =====================================================
#
# elasticdump --input http://$es_host:9200/records-20190122 --type data --output=./vi-water-20190102.json --searchBody='{"query":{"term":{"title.default": "water"}}}'
# sed -i s/records-20190122/records/g vi-water-20190102.json

