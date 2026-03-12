Param(
  [string]$VmName = "nginx-sre",
  [string]$OutputDir = ".\packer\output-nginx-sre",
  [string]$DistDir = ".\dist",
  [string]$OvfTool = "C:\Program Files\VMware\VMware OVF Tool\ovftool.exe"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null

$vmx = Join-Path $OutputDir "$VmName.vmx"
$ova = Join-Path $DistDir "$VmName.ova"

if (!(Test-Path $vmx)) {
  throw "VMX not found: $vmx"
}
if (!(Test-Path $OvfTool)) {
  throw "OVF Tool not found: $OvfTool"
}

& $OvfTool --acceptAllEulas --skipManifestCheck $vmx $ova
Write-Host "OVA exported: $ova"
