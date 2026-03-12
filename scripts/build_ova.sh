#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKER_VARS="${PACKER_VARS:-${ROOT_DIR}/packer/variables.pkr.hcl}"
DIST_DIR="${DIST_DIR:-${ROOT_DIR}/dist}"
POWERSHELL_BIN="${POWERSHELL_BIN:-powershell.exe}"
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: bash scripts/build_ova.sh [options]

Options:
  --vars FILE       Override the packer variables file
  --dist-dir DIR    Override the export output directory
  --dry-run         Print the export command without running it
  -h, --help        Show this help message
EOF
}

die() {
  echo "$*" >&2
  exit 1
}

run_cmd() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

trim() {
  local value="$1"
  value="${value%$'\r'}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "${value}"
}

resolve_from_root() {
  local path="$1"

  if [[ "${path}" = /* ]]; then
    printf '%s' "${path}"
    return
  fi

  printf '%s' "${ROOT_DIR}/${path}"
}

read_packer_var() {
  local key="$1"
  local raw_value

  raw_value="$(
    awk -F '=' -v key="${key}" '
      $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
        sub(/^[^=]*=/, "", $0)
        print $0
        exit
      }
    ' "${PACKER_VARS}"
  )"
  raw_value="$(trim "${raw_value}")"
  raw_value="${raw_value#\"}"
  raw_value="${raw_value%\"}"

  [[ -n "${raw_value}" ]] || die "Required setting not found or empty in ${PACKER_VARS}: ${key}"
  printf '%s' "${raw_value}"
}

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" || -n "${WSL_INTEROP:-}" ]] && return 0
  grep -qi microsoft /proc/version 2>/dev/null
}

is_windows_style_path() {
  [[ "$1" =~ ^[A-Za-z]:\\ ]]
}

is_windows_executable() {
  [[ "$1" =~ \.[Ee][Xx][Ee]$ ]]
}

require_wslpath() {
  command -v wslpath >/dev/null 2>&1 || die "wslpath is required to bridge WSL paths for Windows tools."
}

resolve_ovftool_path() {
  local candidate="$1"

  if is_wsl && is_windows_style_path "${candidate}"; then
    require_wslpath
    wslpath -u "${candidate}"
    return
  fi

  printf '%s' "${candidate}"
}

to_ovftool_arg() {
  local path="$1"

  if is_wsl && is_windows_executable "${OVFTOOL}"; then
    require_wslpath
    wslpath -w "${path}"
    return
  fi

  printf '%s' "${path}"
}

to_windows_path() {
  local path="$1"

  if is_wsl && [[ "${path}" = /* ]]; then
    require_wslpath
    wslpath -w "${path}"
    return
  fi

  printf '%s' "${path}"
}

invoke_via_powershell() {
  command -v "${POWERSHELL_BIN}" >/dev/null 2>&1 || die "PowerShell not found: ${POWERSHELL_BIN}"

  local powershell_script
  powershell_script="$(to_windows_path "${ROOT_DIR}/scripts/export_ova.ps1")"

  run_cmd "${POWERSHELL_BIN}" \
    -NoProfile \
    -ExecutionPolicy Bypass \
    -File "${powershell_script}" \
    -VmName "${VM_NAME}" \
    -OutputDir "$(to_windows_path "${VMX_DIR}")" \
    -DistDir "$(to_windows_path "${DIST_DIR}")" \
    -OvfTool "$(to_windows_path "${OVFTOOL}")"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vars)
      [[ $# -ge 2 ]] || die "--vars requires a value"
      PACKER_VARS="$2"
      shift 2
      ;;
    --dist-dir)
      [[ $# -ge 2 ]] || die "--dist-dir requires a value"
      DIST_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

if [[ ! -f "${PACKER_VARS}" ]]; then
  die "packer variables file not found: ${PACKER_VARS}"
fi

DIST_DIR="$(resolve_from_root "${DIST_DIR}")"
mkdir -p "${DIST_DIR}"

VM_NAME="${VM_NAME:-$(read_packer_var vm_name)}"
OUTPUT_DIR="${OUTPUT_DIR:-$(read_packer_var output_directory)}"
OVFTOOL_RAW="${OVFTOOL_PATH:-$(read_packer_var ovftool_path_windows)}"
OVFTOOL="$(resolve_ovftool_path "${OVFTOOL_RAW}")"

if [[ "${OUTPUT_DIR}" = /* ]]; then
  VMX_DIR="${OUTPUT_DIR}"
else
  VMX_DIR="${ROOT_DIR}/packer/${OUTPUT_DIR}"
fi

VMX_PATH="${VMX_DIR}/${VM_NAME}.vmx"
OVA_PATH="${DIST_DIR}/${VM_NAME}.ova"

if [[ ! -f "${VMX_PATH}" ]]; then
  die "VMX not found: ${VMX_PATH}"
fi

if [[ ! -f "${OVFTOOL}" ]]; then
  die "OVF Tool not found: ${OVFTOOL}. Update packer/variables.pkr.hcl or OVFTOOL_PATH."
fi

VMX_ARG="$(to_ovftool_arg "${VMX_PATH}")"
OVA_ARG="$(to_ovftool_arg "${OVA_PATH}")"

if run_cmd "${OVFTOOL}" --acceptAllEulas --skipManifestCheck "${VMX_ARG}" "${OVA_ARG}"; then
  echo "OVA exported: ${OVA_PATH}"
  exit 0
fi

if is_wsl; then
  echo "Direct OVF Tool execution failed. Retrying with PowerShell." >&2
  invoke_via_powershell
  echo "OVA exported: ${OVA_PATH}"
  exit 0
fi

die "OVA export failed: ${OVA_PATH}"
