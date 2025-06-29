#!/bin/bash
set -e

usage() {
    echo "Usage: $0 [ow|ow16|djgpp|cross]" >&2
    echo "  ow     - build 32-bit version with Open Watcom" >&2
    echo "  ow16   - build 16-bit version with Open Watcom" >&2
    echo "  djgpp  - build using djgpp.mak" >&2
    echo "  cross  - build with a DJGPP cross compiler" >&2
    exit 1
}

[ $# -eq 0 ] && usage

target=$1

ensure_djgpp_cross() {
    if [ -x "djgpp-cross/bin/i586-pc-msdosdjgpp-gcc" ]; then
        export PATH="$PWD/djgpp-cross/bin:$PATH"
        return
    fi
    if command -v i586-pc-msdosdjgpp-gcc >/dev/null 2>&1; then
        return
    fi
    echo "DJGPP cross tools not found. Downloading prebuilt toolchain..." >&2
    tmpdir=$(mktemp -d)
    url=$(curl -s https://api.github.com/repos/andrewwutw/build-djgpp/releases/latest \
        | grep linux64 | grep browser_download_url | cut -d '"' -f4 | head -n1)
    if [ -z "$url" ]; then
        echo "Failed to determine DJGPP toolchain URL" >&2
        exit 1
    fi
    mkdir -p djgpp-cross
    curl -L "$url" -o "$tmpdir/djgpp.tar.bz2"
    tar -xjf "$tmpdir/djgpp.tar.bz2" -C djgpp-cross --strip-components=1
    rm -rf "$tmpdir"
    if ! ldconfig -p | grep -q libfl.so.2; then
        sudo apt-get update && sudo apt-get install -y libfl2
    fi
    export PATH="$PWD/djgpp-cross/bin:$PATH"
}

ensure_jwasm() {
    if command -v jwasm.exe >/dev/null 2>&1; then
        return
    fi
    if command -v jwasm >/dev/null 2>&1; then
        # create a jwasm.exe symlink for makefiles expecting the DOS name
        jwasm_path=$(command -v jwasm)
        ln -sf "$jwasm_path" "${jwasm_path%/*}/jwasm.exe"
        return
    fi
    echo "jwasm not found, building it" >&2
    tmpdir=$(mktemp -d)
    (cd "$tmpdir" && \
        curl -L -s https://github.com/Baron-von-Riedesel/JWasm/archive/refs/tags/v2.19.zip -o jwasm.zip && \
        unzip -q jwasm.zip && \
        cd JWasm-* && make -f GccUnix.mak && \
        cp build/GccUnixR/jwasm "$OLDPWD"/jwasm && \
        mv "$OLDPWD"/jwasm /usr/local/bin/jwasm)
    rm -rf "$tmpdir"
    # ensure jwasm.exe is present
    jwasm_path=$(command -v jwasm)
    ln -sf "$jwasm_path" "${jwasm_path%/*}/jwasm.exe"
}

if [[ "$target" == ow* ]]; then
    if ! command -v wmake >/dev/null 2>&1; then
        # try to initialize an in-tree Open Watcom distribution
        if [ -x "./open-watcom-v2" ]; then
            . ./open-watcom-v2 >/dev/null 2>&1 || true
        elif [ -f "./open-watcom-v2/owsetenv.sh" ]; then
            . ./open-watcom-v2/owsetenv.sh >/dev/null 2>&1 || true
        fi
    fi

    if ! command -v wmake >/dev/null 2>&1; then
        echo "wmake not found. Please install or initialize Open Watcom (open-watcom-v2)." >&2
        exit 1
    fi
fi

case "$target" in
    ow)
        ensure_jwasm
        wmake
        ;;
    ow16)
        ensure_jwasm
        wmake -f OW16.mak
        ;;
    djgpp)
        if ! command -v make >/dev/null 2>&1; then
            echo "make not found." >&2
            exit 1
        fi
        ensure_jwasm
        make -f djgpp.mak
        ;;
    cross)
        if ! command -v make >/dev/null 2>&1; then
            echo "make not found." >&2
            exit 1
        fi
        ensure_djgpp_cross
        ensure_jwasm
        make -f djgpp.mak CROSS=i586-pc-msdosdjgpp-
        ;;
    *)
        usage
        ;;
esac
