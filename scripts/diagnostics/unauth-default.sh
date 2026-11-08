#!/bin/bash
# Read-only: find the default unauthorized-DM behaviour and its config key.
R=/home/ugene05/.hermes/hermes-agent
grep -n -A14 'def _get_unauthorized_dm_behavior' $R/gateway/*.py | head -30
grep -rn -E 'unauthorized_dm_behavior' $R/gateway/config.py | head -8
