# Dotfiles

Meine Windows-, Linux- und macOS-Konfigurationen, verwaltet mit [chezmoi](https://www.chezmoi.io/).

## Voraussetzungen

Auf einer frischen Windows-Installation wird benötigt:

* Windows 10 oder Windows 11
* PowerShell
* WinGet
* Git
* chezmoi
* Windows Developer Mode oder Administratorrechte für Symlinks

WinGet ist normalerweise über den Microsoft App Installer vorhanden.

Auf Linux und macOS wird benötigt:

* Git
* chezmoi
* macOS: Homebrew
* Linux: pacman

Die Linux- und macOS-Dateien stammen aus dem vorherigen GNU-Stow-Setup.

## Quick Start

### 1. chezmoi installieren

Windows:

```powershell
winget install --id twpayne.chezmoi --exact
```

macOS mit Homebrew:

```sh
brew install git chezmoi
```

Linux mit pacman:

```sh
sudo pacman -S --needed git chezmoi
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

Nach dem ersten Apply Windows Terminal oder die Shell vollständig schließen und neu starten.

## Verwaltete Konfigurationen

Chezmoi wählt die passenden Dateien über `.chezmoiignore.tmpl` nach Betriebssystem aus.

Typische Windows-Zielpfade:

```text
PowerShell:
Documents\PowerShell\Microsoft.PowerShell_profile.ps1

Windows Terminal:
AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

Neovim:
AppData\Local\nvim

Yazi:
AppData\Roaming\yazi\config
```

Typische Linux- und macOS-Zielpfade:

```text
Zsh:
~/.zshrc

Neovim:
~/.config/nvim

Yazi:
~/.config/yazi

iTerm2:
~/Library/Preferences/com.googlecode.iterm2.plist
```

Die Yazi-Konfiguration ist auf allen Betriebssystemen inhaltlich gleich. Die
kanonischen Dateien liegen unter `dot_config/yazi`. Unter Linux/macOS werden
sie direkt von chezmoi verwaltet. Unter Windows zeigt `%APPDATA%\yazi\config`
per chezmoi-Symlink auf dieselbe `~/.config/yazi` Konfiguration.

```text
dot_config/yazi
AppData/Roaming/yazi/config
```

Die Neovim-Konfiguration ist ebenfalls auf allen Betriebssystemen inhaltlich
gleich. Die kanonischen Dateien liegen unter `dot_config/nvim`. Unter
Linux/macOS werden sie direkt von chezmoi verwaltet. Unter Windows zeigt
`%LOCALAPPDATA%\nvim` per chezmoi-Symlink auf dieselbe `~/.config/nvim`
Konfiguration.

```text
dot_config/nvim
AppData/Local/nvim
```

Die iTerm2-Konfiguration wird nur unter macOS verwaltet. Vor einem Apply ist es
am sichersten, iTerm2 zu schließen, damit macOS die Preferences nicht direkt
wieder überschreibt.

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
├── run_once_before_10-install-packages-darwin.sh.tmpl
├── run_once_before_10-install-packages-linux.sh.tmpl
├── run_once_before_12-install-oh-my-zsh.sh.tmpl
├── run_once_before_15-install-firacode-nerd-font.ps1.tmpl
├── run_once_before_15-install-firacode-nerd-font-darwin.sh.tmpl
├── run_once_before_15-install-firacode-nerd-font-linux.sh.tmpl
├── run_onchange_after_20-install-yazi-packages.ps1.tmpl
└── run_onchange_after_20-install-yazi-packages-unix.sh.tmpl
```

Die Paket-Skripte installieren plattformspezifisch die wichtigsten Werkzeuge:
Shell/Prompt, Neovim, Yazi, ripgrep/fd/fzf/zoxide, jq/eza und Vorschau-Tools
für Yazi. macOS verwendet Homebrew, Linux verwendet pacman. Nicht passende
Skripte werden über `.chezmoiignore.tmpl` ausgeblendet.

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

### Neovim-Konfiguration ändern

Die Neovim-Dateien werden nur unter `dot_config/nvim` gepflegt. Unter
Linux/macOS landen sie direkt in `~/.config/nvim`. Unter Windows legt chezmoi
`%LOCALAPPDATA%\nvim` als Symlink auf `~/.config/nvim` an.

## Yazi-Pakete

Yazi-Pakete und Themes werden in folgender Datei verwaltet:

```text
dot_config\yazi\package.toml
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
chezmoi re-add "$HOME\.config\yazi\package.toml"
```

Unter Linux und macOS:

```sh
chezmoi re-add ~/.config/yazi/package.toml
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

* `%LOCALAPPDATA%\nvim-data` unter Windows und `~/.local/share/nvim` unter Linux/macOS werden nicht verwaltet. Dort liegen Plugins, Treesitter-Parser, Mason-Pakete und andere generierte Daten.
* Für Yazi wird `~/.config/yazi` verwaltet. Unter Windows zeigt `%APPDATA%\yazi\config` per Symlink darauf.
* Windows Terminal muss nach einer Font-Installation vollständig neu gestartet werden.
* Secrets, API-Schlüssel und Passwörter dürfen nicht unverschlüsselt committed werden.
* Vor jedem größeren Apply empfiehlt sich:

```powershell
chezmoi -n -v apply
```
