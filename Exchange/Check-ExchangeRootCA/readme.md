# Check-ExchangeRootCerts.ps1

A PowerShell script that verifies the DigiCert certificate chain required for uninterrupted Exchange Online mail flow, and remediates automatically if any certificates are missing.

> **Deadline: March 22, 2026** — on-premises Exchange Servers and SMTP relay hosts that do not trust the DigiCert Global Root G2 CA chain will experience mail flow disruption with Exchange Online after this date.
> See Microsoft Message Center post **MC1224565** and the [Exchange Team blog post](https://techcommunity.microsoft.com/blog/exchange/trust-digicert-global-root-g2-certificate-authority-to-avoid-exchange-online-ema/4488311?WT.mc_id=M365-MVP-4020462) for full details.

---

## Background

Microsoft Exchange Online is migrating its TLS certificates to the **DigiCert Global Root G2** certificate authority. Any on-premises server that sends or receives mail over SMTP to/from Exchange Online must trust this root CA and its subordinate intermediate CA.

Windows systems with the default Windows CTL (Certificate Trust List) updater enabled are handled automatically. Servers where CTL updates have been disabled, or that run in isolated/restricted network environments, may need manual intervention — which is what this script addresses.

---

## What the script checks

| Store | Certificate | Thumbprint (SHA1) |
|---|---|---|
| `Cert:\LocalMachine\Root\` | DigiCert Global Root G2 | `DF3C24F9BFD666761B268073FE06D1CC8D4F82A4` |
| `Cert:\LocalMachine\CA\` | DigiCert Global G2 TLS RSA SHA256 2020 CA1 | `1B511ABEAD59C6CE207077C0BF0E0043B1382612` |

---

## What the script does

1. Displays the host name and days remaining until the March 22, 2026 deadline.
2. Checks the local machine certificate store for the required **Root CA** thumbprint.
3. Checks the local machine certificate store for the required **Intermediate CA** thumbprint.
4. If both are present — exits cleanly with no further action.
5. If one or both are missing — prompts to download and install the missing certificates directly from DigiCert:
   - `DigiCertGlobalRootG2.crt` → imported into `Cert:\LocalMachine\Root\` via `certutil -addstore Root`
   - `DigiCertGlobalG2TLSRSASHA2562020CA1-1.crt` → imported into `Cert:\LocalMachine\CA\` via `certutil -addstore CA`
6. Re-verifies both thumbprints after installation and reports the final result.

Only missing certificates are downloaded — already-present certificates are skipped.

---

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Must be run as **Administrator** (elevated session)
- Outbound HTTPS access to `cacerts.digicert.com` (for remediation)

---

## Usage

### Check only — no changes made

```powershell
.\Check-ExchangeRootCerts.ps1 -CheckOnly
```

Reports the status of both certificates and exits. No download or installation is performed. Exits with code `1` if any certificate is missing, `0` if all present. Suitable for use in monitoring pipelines or pre-flight checks.

### Interactive check and remediate

```powershell
.\Check-ExchangeRootCerts.ps1
```

Checks both certificates. If any are missing, prompts `[Y/N]` before downloading and installing. Re-verifies after installation.

---

## Example output

**All certificates present:**
```
==================================================================
  Exchange Online – DigiCert Root CA Check  (MC1224565)
  Deadline : 2026-03-22  |  Host: EXCH01
==================================================================

  Days until deadline: 4

[ Root CA ]
[OK]   DigiCert Global Root G2  (DF3C24F9BFD666761B268073FE06D1CC8D4F82A4)
       Subject : CN=DigiCert Global Root G2, ...

[ Intermediate CA ]
[OK]   Microsoft RSA TLS CA 01  (1B511ABEAD59C6CE207077C0BF0E0043B1382612)
       Subject : CN=Microsoft RSA TLS CA 01, ...

Result: All required certificates are present. No action needed.
```

**Certificate missing — remediation flow:**
```
[ Root CA ]
[MISS] DigiCert Global Root G2  (DF3C24F9BFD666761B268073FE06D1CC8D4F82A4)
       NOT FOUND in Cert:\LocalMachine\Root\

Result: One or more required certificates are MISSING.

Download and install missing certificates now? [Y/N]: Y

[ DigiCert Global Root G2 (Root CA) ]
  Downloading: https://cacerts.digicert.com/DigiCertGlobalRootG2.crt
  Download complete.
  Installing into 'Root' store via certutil...
  certutil [Root] reported success.

Re-checking certificate store...

[OK]   DigiCert Global Root G2 (Root)
[OK]   Microsoft RSA TLS CA 01 (Intermediate)

All certificates now present. Exchange mail flow should be unaffected.
```

---

## Affected systems

Run this script on any Windows server that relays SMTP mail to or from Exchange Online, including:

- On-premises Exchange Server (all versions)
- SMTP relay hosts / smart hosts
- Any third-party mail gateway running on Windows

> Windows servers with the default CTL updater enabled do **not** require manual intervention.

---

## Author

**Peter Schmidt** | [NeoConsulting](https://neoconsulting.dk)  
Blog: [msdigest.net](https://msdigest.net)

---

## References

- [Exchange Team Blog – MC1224565](https://techcommunity.microsoft.com/blog/exchange/trust-digicert-global-root-g2-certificate-authority-to-avoid-exchange-online-ema/4488311?WT.mc_id=M365-MVP-4020462)
- [DigiCert Global Root G2 – DigiCert Knowledge Base](https://knowledge.digicert.com/generalinformation/digicert-root-and-intermediate-ca-certificate-download-information)
