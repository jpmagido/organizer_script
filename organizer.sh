#!/bin/bash

# Licence MIT
#
# Copyright (c) 2023 Jean-Philippe MAGIDO
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

VERSION="1.2"
SOURCE_DIR=~/Desktop
DEST_DIR=~/Pictures/screenshots
PATTERN=^Capture\ d’écran
UNIQ_NAME=0
FILE_MOVED=0

display_copyright() {
  echo "Nom du script: $(basename "$0")"
  echo "Auteur: Jean-Philippe MAGIDO"
  echo "Contact: jpmagido@me.com"
  echo -e "Version: $VERSION \n"
}

help_opt() {
  echo "*** AIDE ***"
  case "$1" in
  "")
    echo "Les Options disponibles sont: [-dspuc]"
    echo "Ce script vous aidera à organiser vos screenshots sur MACOS"
    echo "Vous pourrez également le customiser pour vos besoins personnels"
    echo "Vous pouvez faire: $O -h [dspuc] pour plus d'informations"
    ;;
  "d")
    echo "NAME"
    echo "  -d -- Destination"
    echo "SYNOPSIS"
    echo "  organizer.sh [-d] [PATH]"
    echo "DESCRIPTION"
    echo -e "  Les fichiers sélectionnés seront envoyés vers ce répertoire. \n S'il n'existe pas il sera crée"
    ;;
  "s")
    echo "NAME"
    echo "  -s -- Source"
    echo "SYNOPSIS"
    echo "  organizer.sh [-s] [PATH]"
    echo "DESCRIPTION"
    echo -e "  Les fichiers sélectionnés depuis ce répertoire. \n   Il doit exister au préalable"
    ;;
  "p")
    echo "NAME"
    echo "  -p -- Pattern"
    echo "SYNOPSIS"
    echo "  organizer.sh [-p] [REGEX]"
    echo "DESCRIPTION"
    echo -e "  Les fichiers seront sélectionnés selon ce pattern,  attention le pattern sera retiré du nom, si vous avez des \n  problèmes d'unicité ajoutez l'option -u"
    ;;
  "u")
    echo "NAME"
    echo "  -u -- Unique"
    echo "SYNOPSIS"
    echo "  organizer.sh [-u]"
    echo "DESCRIPTION"
    echo -e "  Les fichiers seront automatiquement renommés. \n  Pour des questions d'unicité, nous ajouterons un identifiant unique date +%s)_\$RANDOM"
    ;;
  "c")
    echo "NAME"
    echo "  -c -- Cron, tâche de fond"
    echo "SYNOPSIS"
    echo "  organizer.sh [-c]"
    echo "DESCRIPTION"
    echo -e "  Instructions pour ajouter le script en tâche de fond"
    ;;
  *)
    echo "Option non reconnue"
    ;;
  esac

  exit
}

create_dest_dir() {
  if ! [ -d "$DEST_DIR" ]; then
    mkdir $DEST_DIR
  fi
}

move_files() {
  if ! [ -d "$SOURCE_DIR" ]; then
    echo "Une erreur s'est produite : Le répertoire source n'existe pas." >&2
    exit 1
  fi

  for file in "$SOURCE_DIR"/*; do
    if [ -f "$file" ] && [[ $(basename "$file") =~ $PATTERN ]]; then
      new_name=$(basename "$file" | awk -F 'Capture d’écran' '{print $2}')

      if [ $UNIQ_NAME -eq 1 ]; then
        mv "$file" "$DEST_DIR/$new_name$(date +%s)_$RANDOM"
      else
        mv "$file" "$DEST_DIR/$new_name"
      fi
      FILE_MOVED=$((FILE_MOVED + 1))
    fi
  done
}

log_trace() {
  echo -e "\nTerminé 👍🏽"
  echo "$FILE_MOVED ficher(s) traité(s)"
}

display_cron_help() {
  echo "Vous pouvez ajouter ce script à vos tâches de fond:"
  echo "\$(crontab -e) pour ouvrir l'éditeur CRON"
  echo "exemple: Pour lancer le script toutes les 5 minutes"
  echo "\$(*/5 * * * * /chemin/vers/votre/script.sh)"

  exit
}

display_copyright

if [ "$#" -eq 1 ] && [ "$1" = "-h" ]; then
  help_opt ""
fi

while getopts ":h:d:s:p:uc:" Option; do
  case $Option in
  h) help_opt "${OPTARG}" ;;
  d) DEST_DIR="${OPTARG}" ;;
  s) SOURCE_DIR="${OPTARG}" ;;
  p) PATTERN="${OPTARG}" ;;
  u) UNIQ_NAME=1 ;;
  c) display_cron_help ;;
  esac
done

create_dest_dir
move_files
log_trace
