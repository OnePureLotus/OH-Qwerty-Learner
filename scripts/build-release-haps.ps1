$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ReleaseDir = Join-Path $ProjectRoot "releases"
$JavaHome = "C:\Program Files\Huawei\DevEco Studio\jbr"
$DevecoSdk = "C:\Program Files\Huawei\DevEco Studio\sdk"
$NodeHome = "C:\Program Files\Huawei\DevEco Studio\tools\node"
$Ohpm = "C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin\ohpm.bat"
$Hvigor = "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat"

$env:JAVA_HOME = $JavaHome
$env:DEVECO_SDK_HOME = $DevecoSdk
$env:NODE_HOME = $NodeHome
$env:PATH = "$JavaHome\bin;$NodeHome;$env:PATH"

$Branches = @(
    "main",
    "app/github",
    "app/51fans",
    "app/clockify",
    "app/memos",
    "app/qwerty-learner",
    "app/qwerty-learner-local"
)

New-Item -ItemType Directory -Force -Path $ReleaseDir | Out-Null
$Results = @()

Set-Location $ProjectRoot
git fetch origin

foreach ($Branch in $Branches) {
    Write-Host "`n========== Building $Branch ==========" -ForegroundColor Cyan

    $checkout = git checkout $Branch 2>&1
    if ($LASTEXITCODE -ne 0) {
        git checkout -B $Branch "origin/$Branch" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "git checkout failed for $Branch" }
    }

    $AppJsonPath = Join-Path $ProjectRoot "AppScope\app.json5"
    $AppJson = Get-Content $AppJsonPath -Raw
    $BundleName = [regex]::Match($AppJson, '"bundleName"\s*:\s*"([^"]+)"').Groups[1].Value
    $VersionName = [regex]::Match($AppJson, '"versionName"\s*:\s*"([^"]+)"').Groups[1].Value
    $AppSlug = ($Branch -replace '^app/', '' -replace '/', '-')
    if ($AppSlug -eq 'main') { $AppSlug = 'baidu' }

    if ($Branch -eq "app/qwerty-learner-local") {
        $BundleScript = Join-Path $ProjectRoot "scripts\bundle-qwerty-learner-local.ps1"
        if (Test-Path $BundleScript) {
            & $BundleScript
            if ($LASTEXITCODE -ne 0) { throw "bundle-qwerty-learner-local failed on $Branch" }
        }
    }

    & $Ohpm install --all
    if ($LASTEXITCODE -ne 0) { throw "ohpm install failed on $Branch" }

    & $Hvigor clean --no-daemon
    & $Hvigor assembleHap -p product=default -p buildMode=release --no-daemon
    if ($LASTEXITCODE -ne 0) { throw "hvigor build failed on $Branch" }

    $HapSrc = Join-Path $ProjectRoot "entry\build\default\outputs\default\entry-default-unsigned.hap"
    if (-not (Test-Path $HapSrc)) {
        $Signed = Join-Path $ProjectRoot "entry\build\default\outputs\default\entry-default-signed.hap"
        if (Test-Path $Signed) {
            Write-Warning "Found signed HAP on $Branch; expected unsigned. Using signed artifact."
            $HapSrc = $Signed
        } else {
            throw "HAP not found for $Branch"
        }
    }

    $HapName = "arkweb-$AppSlug-v$VersionName-unsigned.hap"
    $HapDest = Join-Path $ReleaseDir $HapName
    Copy-Item $HapSrc $HapDest -Force

    $Results += [PSCustomObject]@{
        Branch = $Branch
        BundleName = $BundleName
        Version = $VersionName
        HapFile = $HapName
        HapPath = $HapDest
    }

    Write-Host "OK: $HapName ($BundleName)" -ForegroundColor Green
}

$Results | Format-Table -AutoSize
$Results | ConvertTo-Json | Set-Content (Join-Path $ReleaseDir "build-manifest.json")
Write-Host "`nAll builds completed. Output: $ReleaseDir" -ForegroundColor Green
