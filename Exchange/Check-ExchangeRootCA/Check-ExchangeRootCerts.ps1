#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Check-ExchangeRootCerts.ps1
    Checks for the DigiCert Global Root G2 and intermediate CA required for Exchange Online
    mail flow, and remediates if missing (deadline: March 22, 2026 - MC1224565).

.DESCRIPTION
    Verifies that the DigiCert Global Root G2 root CA and the Microsoft RSA TLS CA 01
    intermediate CA are present in the local machine certificate store.
    If the root CA is missing, the script downloads the Microsoft 365 certificate bundle
    (.p7b) and installs it via certutil.

.NOTES
    Author  : Peter Schmidt | NeoConsulting (neoconsulting.dk)
    Blog    : msdigest.net
    Version : 1.0
    Created : 2026-03-18

    Run as Administrator on any on-premises Exchange Server or SMTP relay host.
    Reference: https://techcommunity.microsoft.com/blog/exchange/trust-digicert-global-root-g2-certificate-authority-to-avoid-exchange-online-ema/4488311
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    # Skip the automatic download/install prompt and just report status
    [switch]$CheckOnly
)

# ── Constants ────────────────────────────────────────────────────────────────
$ROOT_THUMBPRINT  = "DF3C24F9BFD666761B268073FE06D1CC8D4F82A4"  # DigiCert Global Root G2
$INTER_THUMBPRINT = "1B511ABEAD59C6CE207077C0BF0E0043B1382612"  # Microsoft RSA TLS CA 01
$ROOT_CRT_URL     = "https://cacerts.digicert.com/DigiCertGlobalRootG2.crt"
$INTER_CRT_URL    = "https://cacerts.digicert.com/DigiCertGlobalG2TLSRSASHA2562020CA1-1.crt"
$DEADLINE         = [datetime]"2026-03-22"

# ── Helper ───────────────────────────────────────────────────────────────────
function Write-Status {
    param([string]$Label, [bool]$Ok, [string]$Detail = "")
    $icon   = if ($Ok) { "[OK]  " } else { "[MISS]" }
    $color  = if ($Ok) { "Green" } else { "Yellow" }
    Write-Host "$icon $Label" -ForegroundColor $color
    if ($Detail) { Write-Host "       $Detail" -ForegroundColor DarkGray }
}

# ── Banner ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  Exchange Online – DigiCert Root CA Check  (MC1224565)"           -ForegroundColor Cyan
Write-Host "  Deadline : $($DEADLINE.ToString('yyyy-MM-dd'))  |  Host: $env:COMPUTERNAME"   -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

$daysLeft = ($DEADLINE - (Get-Date)).Days
if ($daysLeft -le 0) {
    Write-Host "  *** Deadline has passed. Mail flow may already be disrupted! ***" -ForegroundColor Red
    Write-Host ""
} else {
    Write-Host "  Days until deadline: $daysLeft" -ForegroundColor $(if ($daysLeft -lt 14) { "Red" } else { "White" })
    Write-Host ""
}

# ── 1. Check Root CA ─────────────────────────────────────────────────────────
Write-Host "[ Root CA ]" -ForegroundColor White
$rootCert = Get-ChildItem -Path Cert:\LocalMachine\Root\ |
            Where-Object { $_.Thumbprint -eq $ROOT_THUMBPRINT }

$rootOk = $null -ne $rootCert
Write-Status -Label "DigiCert Global Root G2  ($ROOT_THUMBPRINT)" `
             -Ok    $rootOk `
             -Detail $(if ($rootOk) { "Subject : $($rootCert.Subject)" } else { "NOT FOUND in Cert:\LocalMachine\Root\" })

Write-Host ""

# ── 2. Check Intermediate CA ─────────────────────────────────────────────────
Write-Host "[ Intermediate CA ]" -ForegroundColor White
$interCert = Get-ChildItem -Path Cert:\LocalMachine\CA\ |
             Where-Object { $_.Thumbprint -eq $INTER_THUMBPRINT }

$interOk = $null -ne $interCert
Write-Status -Label "Microsoft RSA TLS CA 01  ($INTER_THUMBPRINT)" `
             -Ok    $interOk `
             -Detail $(if ($interOk) { "Subject : $($interCert.Subject)" } else { "NOT FOUND in Cert:\LocalMachine\CA\" })

Write-Host ""

# ── 3. Summary / Remediation ─────────────────────────────────────────────────
if ($rootOk -and $interOk) {
    Write-Host "Result: All required certificates are present. No action needed." -ForegroundColor Green
    Write-Host ""
    exit 0
}

Write-Host "Result: One or more required certificates are MISSING." -ForegroundColor Yellow
Write-Host ""

if ($CheckOnly) {
    Write-Host "(-CheckOnly specified – skipping remediation)" -ForegroundColor DarkGray
    exit 1
}

# Only the root is missing → we need to import the bundle (intermediate is included in it)
# If only intermediate is missing, bundle import also covers that.

$prompt = Read-Host "Download and install missing certificates now? [Y/N]"
if ($prompt -notmatch '^[Yy]') {
    Write-Host "Aborted. Run the script again or install manually." -ForegroundColor DarkYellow
    exit 1
}

# ── 4. Download & Install ─────────────────────────────────────────────────────
# Each certificate is downloaded individually from DigiCert and imported into
# the correct store:
#   DigiCertGlobalRootG2.crt                   → certutil -addstore Root
#   DigiCertGlobalG2TLSRSASHA2562020CA1-1.crt  → certutil -addstore CA

$downloads = @(
    [PSCustomObject]@{
        Label    = "DigiCert Global Root G2 (Root CA)"
        Url      = $ROOT_CRT_URL
        Dest     = "$env:TEMP\DigiCertGlobalRootG2.crt"
        Store    = "Root"
        Required = -not $rootOk
    },
    [PSCustomObject]@{
        Label    = "DigiCert Global G2 TLS RSA SHA256 2020 CA1 (Intermediate)"
        Url      = $INTER_CRT_URL
        Dest     = "$env:TEMP\DigiCertGlobalG2TLSRSASHA2562020CA1-1.crt"
        Store    = "CA"
        Required = -not $interOk
    }
)

$wc = [System.Net.WebClient]::new()

foreach ($item in $downloads) {
    if (-not $item.Required) {
        Write-Host ""
        Write-Host "  Skipping '$($item.Label)' – already present." -ForegroundColor DarkGray
        continue
    }

    Write-Host ""
    Write-Host "[ $($item.Label) ]" -ForegroundColor Cyan
    Write-Host "  Downloading: $($item.Url)"
    Write-Host "  Destination: $($item.Dest)"

    try {
        $wc.DownloadFile($item.Url, $item.Dest)
        Write-Host "  Download complete." -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: Download failed – $_" -ForegroundColor Red
        continue
    }

    Write-Host "  Installing into '$($item.Store)' store via certutil..."
    $result = & certutil -addstore $item.Store $item.Dest 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  certutil [$($item.Store)] reported success." -ForegroundColor Green
    } else {
        Write-Host "  certutil [$($item.Store)] returned exit code $LASTEXITCODE" -ForegroundColor Yellow
        Write-Host "  Output: $result" -ForegroundColor DarkGray
    }
}

# ── 6. Re-verify ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Re-checking certificate store..." -ForegroundColor Cyan

$rootCertPost  = Get-ChildItem -Path Cert:\LocalMachine\Root\ |
                 Where-Object { $_.Thumbprint -eq $ROOT_THUMBPRINT }
$interCertPost = Get-ChildItem -Path Cert:\LocalMachine\CA\ |
                 Where-Object { $_.Thumbprint -eq $INTER_THUMBPRINT }

Write-Host ""
Write-Status -Label "DigiCert Global Root G2 (Root)"       -Ok ($null -ne $rootCertPost)
Write-Status -Label "Microsoft RSA TLS CA 01 (Intermediate)" -Ok ($null -ne $interCertPost)
Write-Host ""

if ($null -ne $rootCertPost -and $null -ne $interCertPost) {
    Write-Host "All certificates now present. Exchange mail flow should be unaffected." -ForegroundColor Green
} elseif ($null -ne $rootCertPost) {
    Write-Host "Root CA installed. Intermediate CA still missing - may resolve via Windows CTL update." -ForegroundColor Yellow
} else {
    Write-Host "Installation may have failed. Review certutil output above." -ForegroundColor Red
}

Write-Host ""
