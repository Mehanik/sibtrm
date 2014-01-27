#!/bin/bash
# The main idea from http://habrahabr.ru/post/51419/

set -e

SRC_DIRS="/first/directory/to/backup /second/directory/to/backup"
DST_DIR="/path/to/destination/directory" # Where to store backups

RSYNC_OPTIONS="--archive --one-file-system"

backup(){
  if [ -d "$DST_DIR" ]; then
    echo "Running rsync..."
    rsync $RSYNC_OPTIONS $SRC_DIRS --delete "$DST_DIR/latest"
    cp --archive --link "$DST_DIR/latest" "$DST_DIR/`date +%F--%H-%M`"
  else
    echo "Wrong destination directory $DST_DIR"
  fi
}

show_diff(){
  RSYNC_OPTIONS="$RSYNC_OPTIONS --dry-run --verbose"
  rsync $RSYNC_OPTIONS $SRC_DIRS --delete "$DST_DIR/latest"
}

show_help(){
  echo "Simply incremental backups to removable media/local directory
backup.sh [-h] [-v] [-d]
  -h help
  -v vebose mode
  -d show difference between last backup and current state

  Edit DST_DIR and SRC_DIRS variables in the script"
}

OPTIND=1
while getopts "h?vd" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    v)  RSYNC_OPTIONS="$RSYNC_OPTIONS --verbose"
      ;;
    d)
      show_diff
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))

backup
