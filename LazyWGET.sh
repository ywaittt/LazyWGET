#!/bin/bash

# in prima faza, luam link-ul de la tastatura ca argument (primul)
# argumentul va fii salvat in variabila RECEIVED_URL

received_url=$1

if [[ -z "$1" ]]; then
    echo "Empty argument, NOT proceding..."
    exit 1 #failsafe, in orice caz
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

# verificam cu --spider daca URL-ul poate fi deschis (conexiune okay, server okay etc.)
if wget --spider "$received_url"; then
    echo "URL opened with success, proceeding..."
else
    echo "URL could not be opened, NOT proceeding..."
    exit 1 #failsafe iarasi
fi

#preluam numele file-ului, ${received_url%%[\?#]*} taie tot ce urmeaza dupa ? sau #
# si basename da ultimul segment 
name="$(basename -- "${received_url%%[\?#]*}")"

#apare totusi problema cand URL-ul se termina cu /, asa ca il vom trata ca index daca name devine gol
if [[  -z "$name" ]]; then
    name="index"
elif [[ "$name" != *.html ]]; then
    name+=".html"
fi

wget "$received_url" -O "$dir_download/$name"
# in cazul in care unele URL-uri mai primare contin .html la final de URL, il pastram,
# iar daca nu au il adaugam, astfel sigur orice ajunge la wget-ul de download are extensia HTML

mkdir -p "$dir_download/.lwget/" # fisierul de istoric
touch "$dir_download/.lwget/pending.txt" # lista de promisiuni evaluate
touch "$dir_download/.lwget/downloaded.txt" # lista de file uri descarcate anterior

#variabila pt fiecare fisier pentru a fii mai usor de citit
pending_file="$dir_download/.lwget/pending.txt"
downloaded_file="$dir_download/.lwget/downloaded.txt"

# verifica daca URL-ul abia downloadat se afla in vreuna dintre file uri si urmeaza logica:
# nu este in niciun file -> downloaded.txt
# este in pending.txt -> delete from pending.txt si pune-l in downloaded
# este in downloaded(caz care nu ar trebuii sa se intample nimic) -> duplicat, programul nu face nimic

if grep -Fqx  "$received_url" "$pending_file"; then
    # sterge din pending.txt si pune acolo
    grep -qv "$received_url" "$pending_file" > "$dir_download/.lwget/temp.txt"
    mv "$dir_download/.lwget/temp.txt" "$pending_file"
    if ! grep -q "$received_url" "$downloaded_file"; then 
        echo "$received_url" >> "$downloaded_file"
    fi
elif grep -Fqx "$received_url" "$downloaded_file" && ! grep -Fqx "$received_url" "$pending_file"; then
    true
else # nu e in niciuna? pune-o in downloaded.txt
    echo "$received_url" >> "$downloaded_file"
fi

# pup(scoti usor href din a, fara sa reinventezi roata) sau html-xml-utils
# pup 'a[href^="http"] attr{href}' < "$dir_download/$name" | while read -r received_url; do
#    if grep -q  "$received_url" "$pending_file"; then
#        # sterge din pending.txt si pune acolo
#        sed -i "/$received_url/d" "$pending_file"
#        echo "$received_url" >> "$downloaded_file" 
#    elif grep -q "$received_url" "$downloaded_file"; then
#        true
#    else # nu e in niciuna? pune-o in downloaded.txt
#        echo "$received_url" >> "$downloaded_file"
#    fi
# done
# pup nu este pe o instalare standard linux :(


# implementare semi esuata, dureaza foarte mult in rest e chiar okay, merge bine
# wget --spider \
#     --force-html \
#     --base="$received_url" \
#     --follow-tags=a,link \
#     -i "$dir_download/$name" \
#     -o "$dir_download/.lwget/spider.log"

# hai cu grep :(
# daca ai gasit un href in HTML-ul downloadat, sectioneaza linkurile dupa / si citeste-le pe fiecare
grep -Ei -o 'href="[^\"]+"' "$dir_download/$name" | sed 's/href="//i;s/"//' | while read -r found_link; do    
    if [[ "$found_link" =~ ^http ]]; then # ai gasit minim http?
        if grep -Fqx "$found_link" "$downloaded_file" || grep -Fqx "$found_link" "$pending_file"; then
            true # daca e deja la locul lui, nu mai conteaza
        else
            echo "$found_link" >> "$pending_file" # altfel, pune-l in pending_file.
        fi
    fi
done
