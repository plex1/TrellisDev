#!/bin/bash
set -e

# change back to user
su - trellisdev

# needed to run parameters CMD
exec "$@"
