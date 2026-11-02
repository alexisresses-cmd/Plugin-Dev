#!/usr/bin/env bash
exec bash "$(dirname "$0")/../../_fixtures/scaffold.sh" php-legacy-shop --analysis php-legacy-refactor-01-planned --branch fix/12-centraliser-frais-de-port
