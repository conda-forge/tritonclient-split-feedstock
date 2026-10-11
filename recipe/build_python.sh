#!/bin/bash

set -ex

"$PYTHON" - "$SRC_DIR/client/src/python/library/requirements/requirements_grpc.txt" <<'PY'
from importlib.metadata import version
from pathlib import Path
import sys

requirements = Path(sys.argv[1])
requirements.write_text(requirements.read_text().replace("grpcio>=1.82", "grpcio>=" + version("grpcio-tools")))
PY

cmake ${CMAKE_ARGS} \
  -S "$SRC_DIR/client/src/python" \
  -B build-python \
  -GNinja \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
  -DFETCHCONTENT_SOURCE_DIR_REPO-COMMON="$SRC_DIR/common" \
  -DPython_EXECUTABLE="$PYTHON" \
  -DTRITON_ENABLE_EXAMPLES=OFF \
  -DTRITON_ENABLE_GPU=OFF \
  -DTRITON_ENABLE_PYTHON_GRPC=ON \
  -DTRITON_ENABLE_PYTHON_HTTP=ON \
  -DTRITON_ENABLE_TESTS=OFF \
  -DTRITON_VERSION="$PKG_VERSION"
cmake --build build-python --target generic-client-wheel --parallel "$CPU_COUNT"
"$PYTHON" -m pip install build-python/library/generic/tritonclient-*.whl --no-deps --no-build-isolation -vv
