#!/bin/bash

APP_DIR=/srv/app

# Source the Python virtual environment
source $APP_DIR/bin/activate

# run CMD passed
$@
