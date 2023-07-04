#!/bin/sh

encode_octal() {
  STRING="$1"
  RESULT=""
  for c in $(printf "%s" "$STRING" | od -An -v -t o1 | tr -d ' '); do
    RESULT="$RESULT$c"
  done
  echo "$RESULT"
}

decode_octal() {
  STRING="$1"
  RESULT=""
  while [ -n "$STRING" ]; do
    c=$(printf "%s\n" "$STRING" | cut -c 1-3)
    # shellcheck disable=SC2059
    RESULT="$RESULT$(printf "\\$c")"
    STRING=$(printf "%s\n" "$STRING" | cut -c 4-)
  done
  echo "$RESULT"
}

[ -f "$TMP_DIR/process/$1" ] || {
  touch "$TMP_DIR/process/$1"
  < "$TMP_DIR/input/$1" grep -v '^$' | while IFS= read -r line; do
    sh "$0" "$(encode_octal "$line")"
  done
  decode_octal "$1"
}
