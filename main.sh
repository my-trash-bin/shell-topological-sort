#!/bin/sh

set -e

TMP_DIR="tmp.$$"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
trap cleanup INT
trap cleanup TERM

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

add_node() {
  ENCODED="$1"
  [ -f "$TMP_DIR/process/$ENCODED" ] || {
    touch "$TMP_DIR/process/$ENCODED"
    < "$TMP_DIR/input/$ENCODED" grep -v '^$' | while IFS= read -r line; do
      add_node "$(encode_octal "$line")"
    done
    decode_octal "$1"
  }
}

mkdir -p "$TMP_DIR/input"
while IFS="=" read -r dependent dependencies; do
  echo "$dependencies" | xargs -n 1 echo > "$TMP_DIR/input/$(encode_octal "$dependent")"
  echo "$dependencies" | xargs -n 1 echo | while IFS= read -r line; do
    touch "$TMP_DIR/input/$(encode_octal "$line")"
  done
done

mkdir -p "$TMP_DIR/process"
(cd "$TMP_DIR/input" && echo * | xargs -n 1 echo | grep -v '^*$') | sort | while IFS= read -r line; do
  add_node "$line"
done
