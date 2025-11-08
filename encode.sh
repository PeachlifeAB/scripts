#!/usr/bin/env bash
#
# Finds .mkv, .mp4, .mov, .m4v, .avi, .mpg, .mpeg files over MIN_SIZE megabytes
# in TARGET_PATH (defaults to "." if not specified). Renames each file to
# filename.extension.bak, converts it to .mkv, and reverts if conversion fails.
#
# If you don't provide any ffmpeg arguments after the size, it defaults to:
#   -c:v hevc_videotoolbox -c:a copy
# and uses -nostdin to avoid the interactive prompt.
#
# Usage examples:
#   ./myscript.sh 100
#   ./myscript.sh /Volumes/Media 200
#   ./myscript.sh /Volumes/Media 200 -c:v libx264 -c:a aac
#
#   [TARGET_PATH] is optional; if omitted, current directory is used.
#   <MIN_SIZE_MB> is required.

if [ $# -eq 0 ]; then
  echo "Usage: $0 [TARGET_PATH] <MIN_SIZE_MB> [ffmpeg args]"
  exit 1
fi

if [ $# -eq 1 ]; then
  TARGET_PATH="."
  MIN_SIZE="$1"
  shift
else
  TARGET_PATH="$1"
  MIN_SIZE="$2"
  shift 2
fi

if ! [[ "$MIN_SIZE" =~ ^[0-9]+$ ]]; then
  echo "Error: MIN_SIZE must be a numeric value (in MB)."
  echo "Usage: $0 [TARGET_PATH] <MIN_SIZE_MB> [ffmpeg args]"
  exit 1
fi

EXTRA_ARGS=${@:-"-c:v hevc_videotoolbox -c:a copy"}

fd -e mkv -e mp4 -e mov -e m4v -e avi -e mpg -e mpeg -S +"${MIN_SIZE}"m . "$TARGET_PATH" -0 |
while IFS= read -r -d '' FILE; do
  marker_encoded="$(dirname "$FILE")/.$(basename "$FILE").encoded"
  marker_skipped="$(dirname "$FILE")/.$(basename "$FILE").skipped"

  if [ -e "$marker_encoded" ] || [ -e "$marker_skipped" ]; then
    continue
  fi

  BAK="$FILE.bak"
  OUT="${FILE%.*}.mkv"
  
  mv "$FILE" "$BAK" || continue
  
  if ffmpeg -nostdin -i "$BAK" $EXTRA_ARGS "$OUT"; then
    ORIG_SIZE=$(stat -f "%z" "$BAK")
    NEW_SIZE=$(stat -f "%z" "$OUT")
    ORIG_MB=$((ORIG_SIZE / 1024 / 1024))
    NEW_MB=$((NEW_SIZE / 1024 / 1024))
    
    if [ "$NEW_SIZE" -lt "$ORIG_SIZE" ]; then
      echo "$(date +'%Y-%m-%d %H:%M:%S') :: $FILE :: original=${ORIG_MB}MB, encoded=${NEW_MB}MB" > "$marker_encoded"
      rm "$BAK"
    else
      echo "$(date +'%Y-%m-%d %H:%M:%S') :: $FILE :: original=${ORIG_MB}MB, encoded=${NEW_MB}MB" > "$marker_skipped"
      echo "Encoded file for $FILE is larger than original, reverting."
      rm "$OUT"
      mv "$BAK" "$FILE"
    fi
  else
    mv "$BAK" "$FILE"
  fi
done
