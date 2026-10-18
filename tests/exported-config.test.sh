#!/usr/bin/env bash

function test_sourcing_plugin_with_pipefail_does_not_warn_about_exported_config() {
    # Make the export listing larger than a pipe buffer, so that a reader
    # exiting early makes export fail with SIGPIPE, see #560.
    output=$(bash -c '
        export ZZ_PAD1=$(head -c 100000 /dev/zero | tr "\0" x)
        export ZZ_PAD2=$(head -c 100000 /dev/zero | tr "\0" x)
        export ZZ_PAD3=$(head -c 100000 /dev/zero | tr "\0" x)
        set -o pipefail
        source forgit.plugin.sh
    ' 2>&1)

    assert_empty "$output"
}
