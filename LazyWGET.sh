#!/bin/bash

# in prima faza, luam link-ul de la tastatura ca argument (primul)
# argumentul va fii salvat in variabila UNVERIFIED_URL

unverified_url=$1

if [[ -z "$1" ]]; then
    echo "Empty argument, NOT proceding..."
    exit 1
fi

# file urile de tip HTML vor fii descarcare in directorul DOWNLOADS
# DOAR in cazul in care este sugerat altfel (ca un al doilea argument).

dir_download="downloads"

# verificam daca user-ul a introdus un director si daca acesta este diferit de DOWNLOADS
# in caz afirmativ, facem directorul unde user-ul doreste sa descarce.
# in cazul in care, cumva, creearea fisierului nu este posibila, se da un mesaj sugestiv

if [[ -z "$2" ]]; then
    mkdir -p "$dir_download"
elif [[ "$2" != "$dir_download" ]]; then
    dir_download=$2
    mkdir -p "$dir_download" # -p creeaza directoarele parinte daca nu exista,
                             # si in acelasi timp trece peste daca directorul exista deja
    echo "Directory created with success, proceeding..."
elif [[ "$2" == "$dir_download" ]]; then
    echo "Directory already exists, proceeding..."
fi

# informam user-ul unde vor fii salvate file-urile
echo "Files will be downloaded in $dir_download"

# echo "$unverified_url"
# echo "$dir_download"