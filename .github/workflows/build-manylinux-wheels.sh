#!/bin/bash

set -e -x

PY_MAJOR=${PYTHON_VERSION%%.*}
PY_MINOR=${PYTHON_VERSION#*.}

ML_PYTHON_VERSION="cp${PY_MAJOR}${PY_MINOR}-cp${PY_MAJOR}${PY_MINOR}"
if [ "${PY_MAJOR}" -lt "4" -a "${PY_MINOR}" -lt "8" ]; then
    ML_PYTHON_VERSION+="m"
fi

# Temporary workaround for https://github.com/actions/runner/issues/781
#if [$(uname -m) == x86_64]; then
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
#fi

# Compile wheels
PYTHON="/opt/python/${ML_PYTHON_VERSION}/bin/python"
PIP="/opt/python/${ML_PYTHON_VERSION}/bin/pip"
"${PIP}" install --upgrade setuptools pip wheel
cd "${GITHUB_WORKSPACE}"
make clean
"${PYTHON}" setup.py bdist_wheel
ls dist/

# Bundle external shared libraries into the wheels.
for whl in "${GITHUB_WORKSPACE}"/dist/*.whl; do
    ls dist/
    auditwheel repair $whl -w "${GITHUB_WORKSPACE}"/dist/
    rm "${GITHUB_WORKSPACE}"/dist/*-linux_*.whl
done
