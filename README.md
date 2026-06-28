# Dotfiles

Meine Windows-Konfigurationen, verwaltet mit [chezmoi](https://www.chezmoi.io/).

## Voraussetzungen

Auf einer frischen Windows-Installation wird benötigt:

* Windows 10 oder Windows 11
* PowerShell
* WinGet
* Git
* chezmoi

WinGet ist normalerweise über den Microsoft App Installer vorhanden.

## Quick Start

### 1. chezmoi installieren

```powershell
winget install --id twpayne.chezmoi --exact
```

### 2. Repository initialisieren

Über SSH:

```powershell
chezmoi init git@gogs.fluxkompensator.dedyn.io:fabian/dotfiles-new.git
```

Über HTTPS:

```powershell
chezmoi init https://gogs.fluxkompensator.dedyn.io/fabian/dotfiles-new.git
```

### 3. Änderungen prüfen

```powershell
chezmoi diff
```

Dry Run mit ausführlicher Ausgabe:

```powershell
chezmoi -n -v apply
```

### 4. Konfiguration anwenden

```powershell
chezmoi apply -v
```

Alternativ direkt beim Initialisieren:

```powershell
chezmoi init --apply https://gogs.fluxkompensator.dedyn.io/fabian/dotfiles-new.git
```

Nach dem ersten Apply Windows Terminal vollständig schließen und neu starten.

## Verwaltete Konfigurationen

Typische Zielpfade:

```text
PowerShell:
Documents\PowerShell\Microsoft.PowerShell_profile.ps1

Starship:
.config\starship.toml

Windows Terminal:
AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

Yazi:
AppData\Roaming\yazi\config

Neovim:
AppData\Local\nvim
```

Alle verwalteten Dateien anzeigen:

```powershell
chezmoi managed
```

## Bootstrap-Skripte

Die Bootstrap-Skripte liegen unter:

```text
.chezmoiscripts/
```

Beispiele:

```text
.chezmoiscripts/
├── run_once_before_10-install-packages.ps1.tmpl
├── run_once_before_15-install-firacode-nerd-font.ps1.tmpl
└── run_onchange_after_20-install-yazi-packages.ps1.tmpl
```

### Skripttypen

`run_once_`

Wird einmal pro gerendertem Skriptinhalt ausgeführt. Ändert sich der Inhalt, wird das Skript erneut ausgeführt.

`run_onchange_`

Wird beim ersten Apply und anschließend nur bei verändertem gerendertem Inhalt ausgeführt.

`run_`

Wird bei jedem `chezmoi apply` ausgeführt.

## Wichtigste chezmoi-Befehle

### Repository öffnen

```powershell
chezmoi cd
```

Source-Verzeichnis anzeigen:

```powershell
chezmoi source-path
```

### Datei hinzufügen

```powershell
chezmoi add <Pfad>
```

Beispiel:

```powershell
chezmoi add $PROFILE
```

Ganzes Verzeichnis hinzufügen:

```powershell
chezmoi add "$env:APPDATA\yazi\config"
```

### Zieldatei bearbeiten

```powershell
nvim $PROFILE
chezmoi re-add $PROFILE
```

Beispiel für Yazi:

```powershell
nvim "$env:APPDATA\yazi\config\yazi.toml"
chezmoi re-add "$env:APPDATA\yazi\config"
```

Beispiel für Windows Terminal:

```powershell
$TerminalConfig = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

nvim $TerminalConfig
chezmoi re-add $TerminalConfig
```

`re-add` erwartet den tatsächlichen Zielpfad, nicht den Pfad innerhalb des chezmoi-Source-Repositories.

### Source-Datei bearbeiten

```powershell
chezmoi edit <Pfad>
```

Bearbeiten und direkt anwenden:

```powershell
chezmoi edit --apply <Pfad>
```

### Status prüfen

```powershell
chezmoi status
```

Unterschiede anzeigen:

```powershell
chezmoi diff
```

Nur eine Datei prüfen:

```powershell
chezmoi diff $PROFILE
```

Gerenderten Zielinhalt anzeigen:

```powershell
chezmoi cat $PROFILE
```

### Änderungen anwenden

```powershell
chezmoi apply
```

Mit ausführlicher Ausgabe:

```powershell
chezmoi apply -v
```

Dry Run:

```powershell
chezmoi -n -v apply
```

### Änderungen vom Remote übernehmen

```powershell
chezmoi update -v
```

Dieser Befehl führt im Wesentlichen Git Pull und anschließend `chezmoi apply` aus.

Nur das Repository aktualisieren:

```powershell
chezmoi git pull
```

### Datei nicht mehr verwalten

```powershell
chezmoi forget <Pfad>
```

Die Zieldatei bleibt dabei erhalten.

## Git-Workflow

Nach Änderungen:

```powershell
chezmoi diff
chezmoi apply

chezmoi cd

git status
git add .
git commit -m "Update dotfiles"
git push
```

Alternativ direkt über chezmoi:

```powershell
chezmoi git status
chezmoi git add .
chezmoi git commit -- -m "Update dotfiles"
chezmoi git push
```

## Typischer Workflow

### PowerShell-Profil ändern

```powershell
nvim $PROFILE
chezmoi re-add $PROFILE

chezmoi cd
git add .
git commit -m "Update PowerShell profile"
git push
```

### Yazi-Konfiguration ändern

```powershell
nvim "$env:APPDATA\yazi\config\yazi.toml"

chezmoi re-add "$env:APPDATA\yazi\config"

chezmoi cd
git add .
git commit -m "Update Yazi configuration"
git push
```

### Windows-Terminal-Konfiguration ändern

```powershell
$TerminalConfig = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

nvim $TerminalConfig
chezmoi re-add $TerminalConfig

chezmoi cd
git add .
git commit -m "Update Windows Terminal configuration"
git push
```

## Yazi-Pakete

Yazi-Pakete und Themes werden in folgender Datei verwaltet:

```text
AppData\Roaming\yazi\config\package.toml
```

Paket hinzufügen:

```powershell
ya pkg add <Paket>
```

Beispiel:

```powershell
ya pkg add yazi-rs/flavors:catppuccin-mocha
```

Anschließend die Änderung übernehmen:

```powershell
chezmoi re-add "$env:APPDATA\yazi\config\package.toml"
```

Pakete aus `package.toml` installieren:

```powershell
ya pkg install
```

Das chezmoi-Bootstrap-Skript führt diesen Befehl automatisch aus, wenn sich die verwaltete `package.toml` ändert.

## Templates testen

Template rendern:

```powershell
$Template = Join-Path `
    (chezmoi source-path) `
    '.chezmoiscripts\run_once_before_10-install-packages.ps1.tmpl'

Get-Content -LiteralPath $Template -Raw |
    chezmoi execute-template
```

Gerendertes Skript in eine temporäre Datei schreiben:

```powershell
$RenderedScript = Join-Path $env:TEMP 'chezmoi-script-test.ps1'

Get-Content -LiteralPath $Template -Raw |
    chezmoi execute-template |
    Set-Content -LiteralPath $RenderedScript -Encoding utf8
```

Ausführen:

```powershell
& $RenderedScript
```

## `run_once`-Skripte erneut testen

Am besten das Template manuell rendern und ausführen:

```powershell
$Template = Join-Path `
    (chezmoi source-path) `
    '.chezmoiscripts\run_once_before_15-install-firacode-nerd-font.ps1.tmpl'

$RenderedScript = Join-Path $env:TEMP 'test-firacode-install.ps1'

Get-Content -LiteralPath $Template -Raw |
    chezmoi execute-template |
    Set-Content -LiteralPath $RenderedScript -Encoding utf8

& $RenderedScript
```

Alternativ kann der Skriptinhalt geändert werden. Dadurch ändert sich der Hash und chezmoi führt das `run_once_`-Skript beim nächsten Apply erneut aus.

Den gesamten gespeicherten Skriptzustand zurücksetzen:

```powershell
chezmoi state delete-bucket --bucket=scriptState
```

Danach:

```powershell
chezmoi apply -v
```

Achtung: Dadurch können alle `run_once_`- und `run_onchange_`-Skripte erneut ausgeführt werden.

## Diagnose

Installation prüfen:

```powershell
chezmoi doctor
```

Verfügbare Template-Daten anzeigen:

```powershell
chezmoi data
```

Betriebssystem prüfen:

```powershell
chezmoi execute-template '{{ .chezmoi.os }}'
```

Hostnamen prüfen:

```powershell
chezmoi execute-template '{{ .chezmoi.hostname }}'
```

Prüfen, ob der Zielzustand aktuell ist:

```powershell
chezmoi verify
```

## Hinweise

* `%LOCALAPPDATA%\nvim-data` wird nicht verwaltet. Dort liegen Plugins, Treesitter-Parser, Mason-Pakete und andere generierte Daten.
* Für Yazi wird nur `%APPDATA%\yazi\config` verwaltet.
* Windows Terminal muss nach einer Font-Installation vollständig neu gestartet werden.
* Secrets, API-Schlüssel und Passwörter dürfen nicht unverschlüsselt committed werden.
* Vor jedem größeren Apply empfiehlt sich:

```powershell
chezmoi -n -v apply
```

