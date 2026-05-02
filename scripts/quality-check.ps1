$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
  "index.html",
  "about.html",
  "disclaimer.html",
  "affiliate-disclosure.html",
  "updates.html",
  "styles.css",
  "app.js",
  "data/pricing.json",
  "README.md",
  "docs/operations.md",
  "docs/quality-check.md"
)

foreach ($file in $requiredFiles) {
  $path = Join-Path $root $file
  if (-not (Test-Path $path)) {
    throw "Missing required file: $file"
  }
}

$html = Get-Content (Join-Path $root "index.html") -Raw -Encoding UTF8
$requiredHtml = @(
  'id="calculator"',
  'id="comparison"',
  'id="requests"',
  'id="inputTokens"',
  'id="outputTokens"',
  'id="resultRows"',
  'id="pricingRows"'
)

foreach ($marker in $requiredHtml) {
  if ($html -notlike "*$marker*") {
    throw "Missing required HTML marker: $marker"
  }
}

$jsonPath = Join-Path $root "data/pricing.json"
$pricing = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

if (-not $pricing.last_checked) {
  throw "pricing.json must include last_checked"
}

if (-not $pricing.models -or $pricing.models.Count -lt 1) {
  throw "pricing.json must include at least one model"
}

foreach ($model in $pricing.models) {
  foreach ($field in @("provider", "model", "input_per_million_usd", "output_per_million_usd", "source_url")) {
    if ($null -eq $model.$field -or $model.$field -eq "") {
      throw "pricing model is missing field '$field'"
    }
  }
}

Write-Host "Quality check passed."
