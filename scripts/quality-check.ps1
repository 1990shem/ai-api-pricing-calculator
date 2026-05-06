$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
  "index.html",
  "about.html",
  "privacy-policy.html",
  "disclaimer.html",
  "affiliate-disclosure.html",
  "recommended-tools.html",
  "openai-pricing.html",
  "claude-pricing.html",
  "gemini-pricing.html",
  "llm-api-cost-comparison-guide.html",
  "ai-api-cost-optimization.html",
  "make-ai-automation-guide.html",
  "updates.html",
  "styles.css",
  "app.js",
  "assets/ai-api-cost-guide-mark.svg",
  "data/pricing.json",
  "data/affiliate-candidates.json",
  "sitemap.xml",
  "sitemap.txt",
  "robots.txt",
  "_headers",
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
  'id="pricingRows"',
  'id="guides"',
  'data-result-sort=',
  'data-pricing-sort='
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

$affiliatePath = Join-Path $root "data/affiliate-candidates.json"
$affiliate = Get-Content $affiliatePath -Raw -Encoding UTF8 | ConvertFrom-Json

if (-not $affiliate.last_checked) {
  throw "affiliate-candidates.json must include last_checked"
}

if (-not $affiliate.candidates -or $affiliate.candidates.Count -lt 1) {
  throw "affiliate-candidates.json must include at least one candidate"
}

foreach ($candidate in $affiliate.candidates) {
  foreach ($field in @("name", "category", "source_url", "application_status")) {
    if ($null -eq $candidate.$field -or $candidate.$field -eq "") {
      throw "affiliate candidate is missing field '$field'"
    }
  }
}

$recommendedTools = Get-Content (Join-Path $root "recommended-tools.html") -Raw -Encoding UTF8
if ($recommendedTools -like "*make.com/en/register?pc=aiapicost*" -and $recommendedTools -notlike "*rel=`"sponsored noreferrer`"*") {
  throw "Make affiliate link must include rel=`"sponsored noreferrer`""
}

if ($recommendedTools -like "*embeddable.co/?via=shogo*" -and $recommendedTools -notlike "*rel=`"sponsored noreferrer`"*") {
  throw "Embeddable affiliate link must include rel=`"sponsored noreferrer`""
}

if ($recommendedTools -like "*ofox.ai/x/aiapicost*" -and $recommendedTools -notlike "*rel=`"sponsored noreferrer`"*") {
  throw "Ofox AI affiliate link must include rel=`"sponsored noreferrer`""
}

$sitemap = Get-Content (Join-Path $root "sitemap.xml") -Raw -Encoding UTF8
if ($sitemap -like "*.html*") {
  throw "sitemap.xml should use canonical extensionless URLs, not .html URLs"
}

$sitemapText = Get-Content (Join-Path $root "sitemap.txt") -Raw -Encoding UTF8
$robots = Get-Content (Join-Path $root "robots.txt") -Raw -Encoding UTF8
$headers = Get-Content (Join-Path $root "_headers") -Raw -Encoding UTF8
if ($robots -notlike "*https://ai-api-pricing-calculator.pages.dev/sitemap.xml*") {
  throw "robots.txt must reference sitemap.xml"
}

if ($robots -notlike "*https://ai-api-pricing-calculator.pages.dev/sitemap.txt*") {
  throw "robots.txt must reference sitemap.txt"
}

foreach ($headerMarker in @("/sitemap.xml", "Content-Type: application/xml; charset=utf-8", "/sitemap.txt", "Content-Type: text/plain; charset=utf-8")) {
  if ($headers -notlike "*$headerMarker*") {
    throw "_headers is missing marker: $headerMarker"
  }
}

$htmlFiles = Get-ChildItem $root -Filter "*.html" | Where-Object { $_.Name -ne "index.html" }
foreach ($file in $htmlFiles) {
  $slug = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
  $canonicalUrl = "https://ai-api-pricing-calculator.pages.dev/$slug"
  $content = Get-Content $file.FullName -Raw -Encoding UTF8

  if ($sitemap -notlike "*<loc>$canonicalUrl</loc>*") {
    throw "sitemap.xml is missing canonical URL for $($file.Name): $canonicalUrl"
  }

  if ($sitemapText -notlike "*$canonicalUrl*") {
    throw "sitemap.txt is missing canonical URL for $($file.Name): $canonicalUrl"
  }

  if ($content -notlike "*rel=`"canonical`" href=`"$canonicalUrl`"*") {
    throw "$($file.Name) must include canonical URL: $canonicalUrl"
  }
}

$allHtmlFiles = Get-ChildItem $root -Filter "*.html"
foreach ($file in $allHtmlFiles) {
  $content = Get-Content $file.FullName -Raw -Encoding UTF8
  if ($content -match 'href="\./[^"]+\.html') {
    throw "$($file.Name) should link to canonical extensionless internal URLs"
  }
}

Write-Host "Quality check passed."
