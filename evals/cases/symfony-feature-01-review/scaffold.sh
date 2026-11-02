#!/usr/bin/env bash
exec bash "$(dirname "$0")/../../_fixtures/scaffold.sh" symfony-api --analysis symfony-feature-01 --branch feat-42-product-archive
