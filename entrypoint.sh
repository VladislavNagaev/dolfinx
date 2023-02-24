#!/bin/bash

COMMAND="${1:-}"


if [ "${COMMAND}" == "jupyterlab" ]; then

    echo "Starting Jupyter Lab ..."

    python3.10 -m jupyter lab --ip=0.0.0.0 --port=${JUPYTERLAB_PORT:-8888} --no-browser --allow-root --NotebookApp.token=""

fi

if [ "${COMMAND}" == "sshd" ]; then

    echo "Starting sshd server ..."

    # service ssh restart

    /usr/sbin/sshd -D -e

    # tail -f /dev/null

fi

exit $?
