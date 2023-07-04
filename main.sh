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

mkdir -p "$TMP_DIR/input"
while IFS="=" read -r dependent dependencies; do
  echo "$dependencies" | xargs -n 1 echo > "$TMP_DIR/input/$(encode_octal "$dependent")"
  echo "$dependencies" | xargs -n 1 echo | while IFS= read -r line; do
    touch "$TMP_DIR/input/$(encode_octal "$line")"
  done
done

mkdir -p "$TMP_DIR/process"
(cd "$TMP_DIR/input" && echo * | xargs -n 1 echo | grep -v '^*$') | sort | while IFS= read -r line; do
  TMP_DIR="$TMP_DIR" sh "$(dirname "$0")/sub.sh" "$line"
done
