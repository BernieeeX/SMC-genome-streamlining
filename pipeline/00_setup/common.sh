#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

PIPELINE_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${PIPELINE_SETUP_DIR}/../.." && pwd)"

log() {
    printf '[%s] %s\n' "$(date +'%F %T')" "$*"
}

die() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

require_file() {
    local path="$1"
    [[ -f "$path" ]] || die "Missing file: $path"
}

require_dir() {
    local path="$1"
    [[ -d "$path" ]] || die "Missing directory: $path"
}

ensure_dir() {
    local path="$1"
    mkdir -p "$path"
}

require_command() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found in PATH: $cmd"
}

load_config() {
    local config_file="${1:-$ROOT_DIR/config/config.sh}"
    if [[ ! -f "$config_file" ]]; then
        config_file="$ROOT_DIR/config/config.example.sh"
    fi
    require_file "$config_file"
    # shellcheck disable=SC1090
    source "$config_file"
    export PROJECT_ROOT="${PROJECT_ROOT:-$ROOT_DIR}"
}

activate_conda_env() {
    local conda_sh="${1:-}"
    local env_name="${2:-}"
    if [[ -n "$conda_sh" && -f "$conda_sh" ]]; then
        # shellcheck disable=SC1090
        source "$conda_sh"
        if [[ -n "$env_name" ]]; then
            conda activate "$env_name"
        fi
    fi
}
