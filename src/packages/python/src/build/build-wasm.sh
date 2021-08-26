#!/usr/bin/env bash
set -ev

export SRC="$INIT_CWD"/src


if [ -f .patched ]; then
    echo "Already patched"
else
    echo "Patching..."
    # Apply all the patches to the code to make it WASM friendly.
    # These patches initially come from pyodide.  They add a WASM cross compilation target
    # to the config scripts (shouldn't that get upstreamed to Python?).
    cat $SRC/build/python-patches/*.patch | patch -p1

    # TEMPORARY HACK
    echo ""> Python/pyfpe.c

    cp  $SRC/build/pthread-stub.c .

    # Also copy the config.site, which answers some questions needed for
    # cross compiling, without which ./configure won't work.
    cp $SRC/build/config.site .

    touch .patched
fi

# Do the cross-compile ./configure.  Here's an explanation of each
# of the options we use:
#     --prefix=$PREFIX: we install the build locally, then copy from there.
#     --enable-big-digits=30: see pyodide notes.
#     --enable-optimizations: we want speed (e.g. ,compile with -O3)
#     --disable-shared: do not need shared library, since WASM doesn't use them
#     --disable-ipv6: no need, given the WASM sandbox.
#     --with-ensurepip=no: because otherwise "make install" below fails
#       trying to do something with pip; obviously, I don't understand this well yet.
#     --host=wasm32-unknown-emscripten: target we are cross compiling for; matches paches above.
#     --build=`./config.guess`: the host machine for cross compiling is easily computed via
#       this config.guess autoconf script.

export CC="zig cc -target wasm32-wasi-musl -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_SIGNAL -DGRND_NONBLOCK"
export CXX="zig c++ -target wasm32-wasi-musl -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_SIGNAL -DGRND_NONBLOCK"
export AR="zig ar"
export LDFLAGS="-lwasi-emulated-mman -lwasi-emulated-signal"

if [ -f Makefile ]; then
    echo "Already ran configure".
else
    CONFIG_SITE=./config.site READELF=true ./configure \
        --prefix=$PREFIX \
        --enable-big-digits=30 \
        --enable-optimizations \
        --disable-shared \
        --disable-ipv6 \
        --with-ensurepip=no \
        --host=wasm32-unknown-emscripten \
        --build=`./config.guess`
fi

make install

# "$CC" Programs/python.o pthread-stub.c libpython3.9.a -ldl -lm -lc -o python.wasm

# Rebuild python interpreter with the entire Python library as a filesystem:
## TODO -- see sagejs.
# # TODO: This is *brittle* and needs to be done better!
# # In particular the "3.9" will break for sure.
# # Options:
# #    --preload-file $PREFIX/lib/python3.9: the Python standard lib, which is needed
# #       for Python to do anything.  This is BIG, unfortunately.
# #    -s ALLOW_MEMORY_GROWTH=1: so Python can use more than a tiny amount of memory
# #    -s ASSERTIONS=0: otherwise *much* use of stubs (related to signals/posix) gets
# #       displayed to stderr.
# cc -o python.js Programs/python.o libpython3.9.a -ldl  -lm --lz4 \
#      --preload-file $PREFIX/lib/python3.9 \
#      -s ALLOW_MEMORY_GROWTH=1 \
#      -s ASSERTIONS=0

# mkdir -p $DIST
# cp python.js python.data python.wasm $DIST
# Now you can do
#  cd dist; node ./python.js -c 'print("hello world", 2+3)'
# and get
#  hello world 5
# However, just "node ./python" doesn't work, since it terminates instead of waiting for input.
# But we *don't* want the Python repl.  We want a function that evaluates a block of code, so
# we can build a Jupyter kernel, node.js library interface, etc.
