#!/usr/bin/env bash
./cf-mgmt export-config\
  --system-domain=system.codex.starkandwayne.com\
  --user-id=\
  --client-secret=\

# //TODO:
# - check on the user id, where it should come from
# - check on the client secret
# - client in that context is the OAuth2 UAA client