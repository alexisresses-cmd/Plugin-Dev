#!/usr/bin/env bash
exec bash "$(dirname "$0")/../../_fixtures/scaffold.sh" symfony-api --analysis symfony-fastlane-01-planned --branch fix/61-message-nom-obligatoire
