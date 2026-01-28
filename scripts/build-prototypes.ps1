$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

function Assert-Command($name) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if (-not $cmd) {
    throw "Required tool '$name' not found in PATH."
  }
}

Assert-Command "zine"
Assert-Command "hugo"
Assert-Command "zola"

$publicRoot = Join-Path $root "public"
if (Test-Path $publicRoot) {
  Remove-Item -Recurse -Force $publicRoot
}
New-Item -ItemType Directory -Force -Path $publicRoot | Out-Null

Write-Host "Building Zine..."
$zinePublic = Join-Path $root "prototypes\zine\public"
if (Test-Path $zinePublic) {
  Remove-Item -Recurse -Force $zinePublic
}
Push-Location (Join-Path $root "prototypes\zine")
try {
  zine release
} finally {
  Pop-Location
}
New-Item -ItemType Directory -Force -Path (Join-Path $publicRoot "zine") | Out-Null
Copy-Item -Recurse -Force (Join-Path $zinePublic "*") (Join-Path $publicRoot "zine")

Write-Host "Building Hugo..."
Push-Location (Join-Path $root "prototypes\hugo")
try {
  hugo --destination (Join-Path $publicRoot "hugo")
} finally {
  Pop-Location
}

Write-Host "Building Zola..."
Push-Location (Join-Path $root "prototypes\zola")
try {
  zola build --output-dir (Join-Path $publicRoot "zola") --force
} finally {
  Pop-Location
}

Write-Host "Done. Output in: $publicRoot"