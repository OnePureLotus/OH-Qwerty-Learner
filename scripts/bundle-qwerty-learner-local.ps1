$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ScriptDir = Join-Path $ProjectRoot "scripts\qwerty-learner-local"
$OverlayDir = Join-Path $ScriptDir "overlays"
$RawfileDest = Join-Path $ProjectRoot "entry\src\main\resources\rawfile\qwerty-learner"
$CloneDir = Join-Path $ProjectRoot ".cache\qwerty-learner-src"
$Upstream = "https://github.com/RealKai42/qwerty-learner.git"

New-Item -ItemType Directory -Force -Path (Split-Path $CloneDir) | Out-Null

if (-not (Test-Path (Join-Path $CloneDir ".git"))) {
    Write-Host "Cloning $Upstream ..."
    git clone --depth 1 $Upstream $CloneDir
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone $Upstream (check network). You can manually clone into $CloneDir and re-run."
    }
} else {
    Write-Host "Updating qwerty-learner clone ..."
    git -C $CloneDir fetch --depth 1 origin
    git -C $CloneDir checkout -f origin/HEAD
}

$commit = (git -C $CloneDir rev-parse --short HEAD).Trim()
Set-Content -Path (Join-Path $ScriptDir "SOURCE_COMMIT") -Value $commit -NoNewline
Write-Host "Upstream commit: $commit"

$versionJsonPath = Join-Path $ScriptDir "oh-app-version.json"
$versionMeta = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
$appVersion = [string]$versionMeta.version
$versionCode = [int]$versionMeta.versionCode
Write-Host "App version: $appVersion (versionCode $versionCode)"

$appJson5Path = Join-Path $ProjectRoot "AppScope\app.json5"
if (Test-Path $appJson5Path) {
    $appJson = Get-Content $appJson5Path -Raw
    $appJson = $appJson -replace '"versionCode"\s*:\s*\d+', "`"versionCode`": $versionCode"
    $appJson = $appJson -replace '"versionName"\s*:\s*"[^"]*"', "`"versionName`": `"$appVersion`""
    Set-Content -Path $appJson5Path -Value $appJson -NoNewline
}

Write-Host "Applying ArkWeb overlays ..."
Copy-Item -Path (Join-Path $OverlayDir "src\*") -Destination (Join-Path $CloneDir "src") -Recurse -Force
if (Test-Path (Join-Path $OverlayDir "vite.config.ts")) {
    Copy-Item -Path (Join-Path $OverlayDir "vite.config.ts") -Destination (Join-Path $CloneDir "vite.config.ts") -Force
}

Push-Location $CloneDir
try {
    if (-not (Test-Path "node_modules")) {
        npm install
    }
    $env:CI = "false"
    $env:REACT_APP_ARKWEB = "true"
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "vite build failed" }
} finally {
    Pop-Location
}

$BuildOut = Join-Path $CloneDir "build"
if (-not (Test-Path (Join-Path $BuildOut "index.html"))) {
    throw "Build output missing at $BuildOut"
}

if (Test-Path $RawfileDest) {
    Remove-Item -Recurse -Force $RawfileDest
}
New-Item -ItemType Directory -Force -Path $RawfileDest | Out-Null
Copy-Item -Path (Join-Path $BuildOut "*") -Destination $RawfileDest -Recurse -Force

$indexHtml = Join-Path $RawfileDest "index.html"
if (Test-Path $indexHtml) {
    $html = Get-Content $indexHtml -Raw -Encoding UTF8
    $html = $html -replace 'Qwerty Learner', 'OH QwertyLearner'
    Set-Content -Path $indexHtml -Value $html -Encoding UTF8 -NoNewline
}

Write-Host "Bundled to $RawfileDest ($commit)" -ForegroundColor Green
