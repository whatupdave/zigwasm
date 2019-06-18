#!/bin/bash
set -ex

scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
function finish {
  rm -rf "$scratch"
}
trap finish EXIT

zig build install --prefix .

(
  cd web
  rm -rf dist
  yarn build --out-dir $scratch
)

git checkout gh_pages
