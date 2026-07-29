$utf8 = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# ------------------------------------------------------------
# Aliase und Funktionen
# ------------------------------------------------------------

# Bereits vorhandene PowerShell Aliase entfernen, damit dies für CoreUtils und eigene Aliase zur Verfügung stehen
$aliasesToRemove = @(
    'cat', 'cp', 'ls', 'mv', 'rm', 'date', 'echo', 'mkdir', 'more', 'pwd', 'rmdir', 'tee', 'uptime',
    'sort', 'sleep', 'tee', 'grep', 'gl', 'gsn'
)

foreach ($alias in $aliasesToRemove) {
    if (Test-Path "Alias:$alias") {
        Remove-Item "Alias:$alias" -Force
    }
}

Set-Alias vi nvim
Set-Alias vim nvim
Set-Alias lg lazygit
Set-Alias gt git-tools
Set-Alias oc opencode

function gst { git status $args }
function npp { &"C:\Program Files\Notepad++\notepad++.exe" @args }
function gl  { git log @args }
#function glo { git log --oneline @args}
function glg { git log --graph --oneline --simplify-by-decoration @args}

function gsn {
	param(
	 [Parameter(Position = 0, ValueFromRemainingArguments)]
	 [ValidateNotNullOrEmpty()]
	 [string[]]$Commit = @('HEAD')
	)

	git --no-pager show --name-status @Commit --
}

function glo {
    param(
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Count = 20,

        [switch]$All,

        [switch]$NoRelativeDate
    )

    $authorMaxLength = 15

    $gitArguments = @(
        '-c'
        'i18n.logOutputEncoding=utf-8'
        'log'
        '--date=short'
        '--pretty=format:%h%x1f%ad%x1f%cr%x1f%an%x1f%s%x1f%D'
    )

    if (-not $All) {
        $gitArguments += "-$Count"
    }

    $commits = @(
        git @gitArguments |
            ForEach-Object {
                $parts = $_ -split "`u{1F}", 6

                [PSCustomObject]@{
                    Hash         = $parts[0]
                    Date         = $parts[1]
                    RelativeDate = $parts[2]
                    Author       = if ($parts[3].Length -gt $authorMaxLength) {
                        $parts[3].Substring(0, $authorMaxLength) + '...'
                    } else {
                        $parts[3]
                    }
                    Subject      = $parts[4]
                    Refs         = $parts[5]
                }
            }
    )

    if ($commits.Count -eq 0) {
        return
    }

    $relativeDateWidth = (
        $commits.RelativeDate |
            ForEach-Object Length |
            Measure-Object -Maximum
    ).Maximum

    $authorWidth = (
        $commits.Author |
            ForEach-Object Length |
            Measure-Object -Maximum
    ).Maximum

    $esc = [char]27

    $yellow  = "$esc[33m"
    $green   = "$esc[32m"
    $cyan    = "$esc[36m"
    $magenta = "$esc[35m"
    $reset   = "$esc[0m"

    $lines = foreach ($commit in $commits) {
        $relativeDate = "($($commit.RelativeDate))".PadRight($relativeDateWidth + 2)
        $author       = $commit.Author.PadRight($authorWidth)

        $line =
            "${yellow}$($commit.Hash)${reset}" +
            "  $($commit.Date)"

        if (-not $NoRelativeDate) {
            $line += " ${green}${relativeDate}${reset}"
        }

        $line +=
            "  " +
            "${cyan}${author}${reset}" +
            ": $($commit.Subject)"

        if ($commit.Refs) {
            $line += "  ${magenta}$($commit.Refs)${reset}"
        }

        $line
    }

    $lines
}

function glof {
    glo -All -NoRelativeDate |
        fzf `
            --ansi `
            --no-sort `
            --preview 'git --no-pager show --format= --name-status {1} --' `
            --preview-window 'right:40%'
}

# Verzeichnis auswählen + Tree-Preview
function zfp {
    $dir = zoxide query -l |
        fzf `
            --preview 'eza --tree --level=2 --icons --all {}' `
            --preview-window 'right:60%' `
            --bind 'alt-j:preview-down,alt-k:preview-up'

    if ($dir) {
        Set-Location -LiteralPath $dir
    }
}

# Git-Repositories auswählen
function zfg {
    $dir = zoxide query -l |
        Where-Object { Test-Path (Join-Path $_ '.git') } |
        fzf `
            --preview 'eza --tree --level=2 --icons --all {}'

    if ($dir) {
        Set-Location -LiteralPath $dir
        git status
    }
}

# Repository auswählen + Git-Branches durchsuchen
function zfb {
    $dir = zoxide query -l |
        Where-Object { Test-Path (Join-Path $_ '.git') } |
        fzf `
            --preview 'eza --tree --level=2 --icons --all {}'

    if (-not $dir) {
        return
    }

    Set-Location -LiteralPath $dir

    $branch = git branch --format='%(refname:short)' |
        fzf `
            --preview 'git log --oneline --graph --decorate -20 {}'

    if ($branch) {
        git switch $branch
    }
}

# Repository auswählen + Commits durchsuchen
function zfc {
    $dir = zoxide query -l |
        Where-Object { Test-Path (Join-Path $_ '.git') } |
        fzf

    if (-not $dir) {
        return
    }

    Set-Location -LiteralPath $dir

    git log --oneline --decorate --all |
        fzf `
            --ansi `
            --preview 'git show --stat --oneline {1}' `
            --preview-window 'right:65%'
}

# ------------------------------------------------------------
# PSReadLine
# ------------------------------------------------------------

Import-Module PSReadLine

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# ------------------------------------------------------------
# posh-git
# ------------------------------------------------------------

Import-Module posh-git

# ------------------------------------------------------------
# PSFzf
# ------------------------------------------------------------

Import-Module PSFzf

# Grundlegende fzf-Darstellung
$env:FZF_DEFAULT_OPTS = @(
    '--height=60%'
    '--layout=reverse'
    '--border'
    '--info=inline'
    '--prompt=❯ '
    '--pointer=▶'
    '--marker=✓'
    '--cycle'
    '--multi'
    '--bind=ctrl-a:select-all'
    '--bind=ctrl-d:deselect-all'
    '--bind=ctrl-u:preview-half-page-up'
    '--bind=ctrl-f:preview-half-page-down'
    '--bind=alt-g:first'
    '--bind=alt-G:last'
) -join ' '

# Falls ripgrep installiert ist, für die Dateisuche verwenden.
# Versteckte Dateien werden berücksichtigt, .git wird ausgeschlossen.
if (Get-Command rg -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    $env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
}

Set-PsFzfOption `
    -PSReadlineChordProvider 'Ctrl+t' `
    -PSReadlineChordReverseHistory 'Ctrl+r' `
    -PSReadlineChordSetLocation 'Alt+c' `
    -TabExpansion `
    -GitKeyBindings `
    -EnableAliasFuzzyEdit `
    -EnableAliasFuzzyHistory `
    -EnableAliasFuzzyKillProcess

# Tab durch fuzzy Tab-Completion ersetzen
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    Invoke-FzfTabCompletion
}


# ------------------------------------------------------------
# Eigene nützliche Tastenkürzel
# ------------------------------------------------------------

# Datei auswählen und im Standardprogramm öffnen
Set-PSReadLineKeyHandler -Chord 'Ctrl+o' -ScriptBlock {
    $file = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue |
        ForEach-Object FullName |
        Invoke-Fzf

    if ($file) {
        Start-Process $file
    }
}

# Prozess auswählen und beenden
Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+k' -ScriptBlock {
    Get-Process |
        ForEach-Object {
            '{0,-8} {1}' -f $_.Id, $_.ProcessName
        } |
        Invoke-Fzf -Multi |
        ForEach-Object {
            $processId = ($_ -split '\s+', 2)[0]

            if ($processId -match '^\d+$') {
                Stop-Process -Id $processId -Confirm
            }
        }
}

# ------------------------------------------------------------
# yazi
# ------------------------------------------------------------

$env:YAZI_FILE_ONE = 'C:\Program Files\Git\usr\bin\file.exe'
function y {
    $tmp = (New-TemporaryFile).FullName
    yazi.exe @args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}


# DO NOT MODIFY -- coreutils -- 60b36fc6-2d59-49df-be51-28dd2f4c3c9a
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# Inlining the template into the profile shaves off ~10ms (25%).
$script:__COREUTILS__ = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@('arch','b2sum','base32','base64','basename','basenc','cat','cksum','comm','cp','csplit','cut','date','df','dirname','du','echo','env','expr','factor','false','find','fmt','fold','grep','head','hostname','join','la','link','ln','ls','md5sum','mkdir','mktemp','mv','nl','nproc','numfmt','od','paste','pathchk','pr','printenv','printf','ptx','pwd','readlink','realpath','rm','rmdir','seq','sha1sum','sha224sum','sha256sum','sha384sum','sha512sum','shuf','sleep','sort','split','stat','sum','tac','tail','tee','test','touch','tr','true','truncate','tsort','unexpand','uniq','unlink','uptime','wc','xargs','yes'),
    [System.StringComparer]::OrdinalIgnoreCase
)

$script:__COREUTILS_FAST_SKIP__ = [regex]::new(
    '\b(?:' + ($script:__COREUTILS__ -join '|') + ')\b',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor `
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

# Casting the scriptblock to Func<Ast,bool> once and reusing it avoids the
# per-FindAll scriptblock-to-delegate wrapping overhead (~1.7x faster).
$script:__COREUTILS_CMD_PREDICATE__ = [System.Func[System.Management.Automation.Language.Ast, bool]] {
    param($n) $n -is [System.Management.Automation.Language.CommandAst]
}

$script:__COREUTILS_ARG_SPECIAL__ = [char[]] @("'", '"', '`', '$')

# Wrap arguments into quotes. By being a function we can properly handle $variables.
# As per MSVCRT, any `\` before `"` must be doubled to escape them.
function global:__coreutils_q {
    param($s)
    '"' + (([string]$s) -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
}

# PowerShell tokenizes `*"a"*` as [BareWord] instead of the expected [DoubleQuoted, BareWord, DoubleQuoted].
# To work around that we use... regex. Group 1 = 'single', 2 = "double", 3 = `escape, 4 = bare run.
$script:__COREUTILS_ARG_RX__ = [regex]::new(
    "'((?:[^']|'')*)'|""((?:[^""``]|""""|``.)*)""|``(.)|([^'""``]+)",
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)
$script:__COREUTILS_ARG_EVAL__ = [System.Text.RegularExpressions.MatchEvaluator] {
    param($m)
    if ($m.Groups[1].Success) {
        # Single-quoted: literal. PS '' -> ', then MSVCRT-quote.
        $body = $m.Groups[1].Value.Replace("''", "'")
        if ($body -match '^(.*?)(\\+)$') {
            return '"' + ($matches[1] -replace '(\\*)"', '$1$1\"') + '"' + $matches[2]
        }
        return '"' + ($body -replace '(\\*)"', '$1$1\"') + '"'
    }
    if ($m.Groups[2].Success) {
        # Double-quoted: collapse PS quote-escapes to raw " / ', let ExpandString
        # resolve `n / `t / $var, then MSVCRT-quote.
        $body = $m.Groups[2].Value.
        Replace('`"', '"').
        Replace("``'", "'").
        Replace('""', '"')
        $body = $ExecutionContext.InvokeCommand.ExpandString($body)
        if ($body -match '^(.*?)(\\+)$') {
            return '"' + ($matches[1] -replace '(\\*)"', '$1$1\"') + '"' + $matches[2]
        }
        return '"' + ($body -replace '(\\*)"', '$1$1\"') + '"'
    }
    if ($m.Groups[3].Success) {
        # Backtick-escaped char outside a string: " -> \"; everything else
        # becomes a one-char quoted region so glob metas stay literal.
        $c = $m.Groups[3].Value
        if ($c -eq '"') {
            return '\"'
        }
        return '"' + $c + '"'
    }
    # Bare run: passed through unquoted so coreutils can glob it; expand $vars.
    return $ExecutionContext.InvokeCommand.ExpandString($m.Groups[4].Value)
}

# 0: not tested, 1: coreutils not installed, 2: coreutils installed.
$script:__COREUTILS_CMD_DIR_TEST__ = 0

# PSConsoleHostReadLine override that rewrites coreutils command names to their
# .cmd equivalents after PSReadLine returns (history keeps the original).
#
# Why .cmd over .exe: PSNativeCommandArgumentPassing = 'Windows' results in a behavior
# where passing bare quotes to CreateProcess() is impossible. This prevents us from
# passing "*" as "*" to coreutils and instead will be given as a bare *.
# This causes it to treat it as a glob pattern. "*.cmd" files however are automatically
# treated as PSNativeCommandArgumentPassing = 'Legacy', which preserves quotes.
# It is the only possible workaround and the only way coreutils can work at all.
function PSConsoleHostReadLine {
    [System.Diagnostics.DebuggerHidden()]
    param()

    $lastRunStatus = $?
    Microsoft.PowerShell.Core\Set-StrictMode -Off
    $line = [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine($host.Runspace, $ExecutionContext, $lastRunStatus)

    # If the line contains no coreutils name, we don't need to parse the AST at all.
    if (-not $script:__COREUTILS_FAST_SKIP__.IsMatch($line)) {
        return $line
    }

    # Roamed/synced profiles can load this snippet on machines where coreutils is not installed.
    # Test for the existence of the command directory once and remember the result.
    if ($script:__COREUTILS_CMD_DIR_TEST__ -eq 0) {
        $script:__COREUTILS_CMD_DIR_TEST__ = 1
        if (Test-Path -LiteralPath 'C:\Program Files\coreutils\cmd\' -PathType Container -ErrorAction Ignore) {
            $script:__COREUTILS_CMD_DIR_TEST__ = 2
        }
    }
    if ($script:__COREUTILS_CMD_DIR_TEST__ -ne 2) {
        return $line
    }

    $ast = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null)
    $commands = $ast.FindAll($script:__COREUTILS_CMD_PREDICATE__, $true)

    # Process right-to-left so earlier offsets stay valid after each splice.
    # In-place reverse beats Sort-Object for the typical 1-command line.
    if ($commands.Count -gt 1) {
        $commands = [System.Collections.Generic.List[object]]::new($commands)
        $commands.Reverse()
    }

    foreach ($cmd in $commands) {
        $name = $cmd.GetCommandName()
        if (!$name) {
            continue
        }

        $baseName = $name
        if ($name.EndsWith('.exe') -or $name.EndsWith('.cmd')) {
            $baseName = $name.Substring(0, $name.Length - 4)
        }
        if (!$script:__COREUTILS__.Contains($baseName)) {
            continue
        }

        # ls/la get colour + listing flags injected; la also rewrites to ls.
        $cmdElement = $cmd.CommandElements[0]
        $start = $cmdElement.Extent.StartOffset
        $end = $cmdElement.Extent.EndOffset
        $replacement = "& 'C:\Program Files\coreutils\cmd\"

        switch ($baseName) {
            'la' { $replacement += "ls.cmd' --color=auto -AFhl" }
            'ls' { $replacement += "ls.cmd' --color=auto" }
            default { $replacement += "$baseName.cmd'" }
        }

        # Walk command elements, merging adjacent ones whose extents touch
        # (e.g. `'a'*` parses as [SingleQuoted, BareWord] but is one shell word).
        # The inverse case `*'a'*` parses as a single BareWord whose text
        # contains the embedded quotes, which is why AST-only analysis
        # isn't enough and we still need to re-tokenize the source span.
        $argsStart = $end
        $argsEnd = $cmd.Extent.EndOffset
        $rewrittenArgs = ''
        $elements = $cmd.CommandElements
        $count = $elements.Count
        $i = 1
        while ($i -lt $count) {
            $first = $elements[$i]
            $wordStart = $first.Extent.StartOffset
            $wordEnd = $first.Extent.EndOffset
            $merged = $false
            while ($i + 1 -lt $count -and $elements[$i + 1].Extent.StartOffset -eq $wordEnd) {
                $i++
                $wordEnd = $elements[$i].Extent.EndOffset
                $merged = $true
            }
            $source = $line.Substring($wordStart, $wordEnd - $wordStart)
            $rewrittenArgs += $line.Substring($argsStart, $wordStart - $argsStart)
            $argsStart = $wordEnd
            # IndexOfAny beats running the regex per arg.
            if ($source.IndexOfAny($script:__COREUTILS_ARG_SPECIAL__) -lt 0) {
                $rewrittenArgs += $source
                $i++
                continue
            }
            # A single un-merged PS expression that needs $var resolution
            # (bare $var, "...$var...", $x.Member, $($expr), etc.).
            # Defer evaluation to runtime so the value reaches coreutils as a literal arg.
            # This matches POSIX behaviour where variable expansions don't result in globbing.
            if (-not $merged -and
                ($first -is [System.Management.Automation.Language.VariableExpressionAst] -or
                $first -is [System.Management.Automation.Language.ExpandableStringExpressionAst] -or
                $first -is [System.Management.Automation.Language.MemberExpressionAst])) {
                $rewrittenArgs += '(__coreutils_q ' + $source + ')'
                $i++
                continue
            }
            # Slow path: re-tokenise and re-emit as MSVCRT-style quoting,
            # then wrap in PS single quotes so PS hands the body verbatim.
            $windowsQuoted = $script:__COREUTILS_ARG_RX__.Replace($source, $script:__COREUTILS_ARG_EVAL__)
            $rewrittenArgs += "'" + $windowsQuoted.Replace("'", "''") + "'"
            $i++
        }
        $rewrittenArgs += $line.Substring($argsStart, $argsEnd - $argsStart)

        $line = $line.Substring(0, $start) + $replacement + $rewrittenArgs + $line.Substring($argsEnd)
    }

    return $line
}
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# DO NOT MODIFY -- coreutils -- 60b36fc6-2d59-49df-be51-28dd2f4c3c9a


# ------------------------------------------------------------
# Eigene Ausnahmen nach dem generierten Coreutils-Block
# ------------------------------------------------------------

$script:__COREUTILS__.Remove('ls') | Out-Null
$script:__COREUTILS__.Remove('la') | Out-Null

$script:__COREUTILS_FAST_SKIP__ = [regex]::new(
    '\b(?:' + ($script:__COREUTILS__ -join '|') + ')\b',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

function global:ls {
    eza --icons=always @args
}

function global:la {
    eza --icons=always --all @args
}

function global:ll {
    eza --icons=always --long @args
}
