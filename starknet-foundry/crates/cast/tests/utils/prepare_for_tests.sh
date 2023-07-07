#!/bin/bash
set -e

COMPILER_DIRECTORY="$(git rev-parse --show-toplevel)/starknet-foundry/crates/cast/tests/utils/"
CAIRO_REPO="https://github.com/starkware-libs/cairo/releases/download"
COMPILER_VERSION="v1.1.1"
SCARB_VERSION="0.4.1"

install_scarb_version() {
  asdf install scarb "$1"
  asdf global scarb "$1"
  scarb --version
}

if ! which starknet-devnet > /dev/null 2>&1; then
  echo "starknet-devnet not found, please install"
  echo "https://0xspaceshard.github.io/starknet-devnet/docs/intro"
  exit 1
fi

if ! command -v asdf 2>&1 /dev/null; then
  echo "asdf not found, please install"
  echo "https://asdf-vm.com/guide/getting-started.html#_2-download-asdf"
  exit 1
fi

if command -v scarb 2>&1 /dev/null; then
    installed_version=$(scarb --version | grep -e "scarb" | awk '{print $2}')

    if [[ "$installed_version" != "$SCARB_VERSION" ]]; then
      install_scarb_version $SCARB_VERSION
    fi

  else
    asdf plugin add scarb
    install_scarb_version $SCARB_VERSION
  fi

if [ ! -x "$COMPILER_DIRECTORY/cairo/bin/starknet-sierra-compile" ]; then
  if [[ $(uname -s) == 'Darwin' ]]; then
    wget "$CAIRO_REPO/$COMPILER_VERSION/release-aarch64-apple-darwin.tar" -P "$COMPILER_DIRECTORY"
    pushd "$COMPILER_DIRECTORY"
    tar -xvf "$COMPILER_DIRECTORY/release-aarch64-apple-darwin.tar" cairo/bin/starknet-sierra-compile
    popd

  elif [[ $(uname -s) == 'Linux' ]]; then
    wget "$CAIRO_REPO/$COMPILER_VERSION/release-x86_64-unknown-linux-musl.tar.gz" -P "$COMPILER_DIRECTORY"
    pushd "$COMPILER_DIRECTORY"
    tar -xzvf "$COMPILER_DIRECTORY/release-x86_64-unknown-linux-musl.tar.gz" cairo/bin/starknet-sierra-compile
    popd
  fi

  else
    echo "System $(uname -s) currently not supported"
    exit 1
fi

echo "All done!"
exit 0
