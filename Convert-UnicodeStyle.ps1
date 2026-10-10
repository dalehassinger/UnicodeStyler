<#
.SYNOPSIS
    Local clone of YayText "Bold / Italic" — converts plain text into Unicode
    Mathematical Alphanumeric characters that keep their style when pasted anywhere.

.EXAMPLE
    ./Convert-UnicodeStyle.ps1 "VCF 9.1 is here"
    Shows the text in all 10 styles.

.EXAMPLE
    ./Convert-UnicodeStyle.ps1 "VCF 9.1 is here" -Style SansBold -Copy
    Converts to bold sans and copies the result to the clipboard.

.NOTES
    Works in Windows PowerShell 5.1 and PowerShell 7+ (Windows/macOS/Linux).
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Text,

    [ValidateSet('All', 'Bold', 'Italic', 'BoldItalic', 'SansBold', 'SansItalic', 'SansBoldItalic',
                 'AltBold', 'AltItalic', 'BoldAltItalic', 'ItalicSwitchSerif')]
    [string]$Style = 'All',

    [switch]$Copy
)

# Starting code points for A, a and 0 in each base style.
# Exceptions: characters Unicode placed elsewhere (italic small h lives at U+210E).
$BaseStyles = @{
    Bold           = @{ Upper = 0x1D400; Lower = 0x1D41A; Digit = 0x1D7CE }
    Italic         = @{ Upper = 0x1D434; Lower = 0x1D44E; Exceptions = @{ 0x68 = 0x210E } }
    BoldItalic     = @{ Upper = 0x1D468; Lower = 0x1D482 }
    SansBold       = @{ Upper = 0x1D5D4; Lower = 0x1D5EE; Digit = 0x1D7EC }
    SansItalic     = @{ Upper = 0x1D608; Lower = 0x1D622 }
    SansBoldItalic = @{ Upper = 0x1D63C; Lower = 0x1D656 }
}

# Output styles (labels match the YayText page). Each is a list of base styles
# cycled letter by letter; 'Plain' leaves the letter unchanged.
$OutputStyles = [ordered]@{
    Bold              = @{ Label = 'Bold (serif)';               Cycle = @('Bold') }
    Italic            = @{ Label = 'Italic (serif)';             Cycle = @('Italic') }
    BoldItalic        = @{ Label = 'Bold / italic (serif)';      Cycle = @('BoldItalic') }
    SansBold          = @{ Label = 'Bold (sans)';                Cycle = @('SansBold') }
    SansItalic        = @{ Label = 'Italic (sans)';              Cycle = @('SansItalic') }
    SansBoldItalic    = @{ Label = 'Bold / italic (sans)';       Cycle = @('SansBoldItalic') }
    AltBold           = @{ Label = 'Alternating Bold';           Cycle = @('Bold', 'Plain') }
    AltItalic         = @{ Label = 'Alternating Italic';         Cycle = @('Italic', 'Plain') }
    BoldAltItalic     = @{ Label = 'Bold w/ Alternating Italic'; Cycle = @('Bold', 'BoldItalic') }
    ItalicSwitchSerif = @{ Label = 'Italic Switch Serifs';       Cycle = @('Italic', 'SansItalic') }
}

function Convert-Char {
    param([char]$Char, [string]$BaseStyle)

    if ($BaseStyle -eq 'Plain') { return [string]$Char }
    $map  = $BaseStyles[$BaseStyle]
    $code = [int]$Char

    if ($map.Exceptions -and $map.Exceptions.ContainsKey($code)) {
        return [char]::ConvertFromUtf32($map.Exceptions[$code])
    }
    if ($code -ge 65 -and $code -le 90)  { return [char]::ConvertFromUtf32($map.Upper + $code - 65) }
    if ($code -ge 97 -and $code -le 122) { return [char]::ConvertFromUtf32($map.Lower + $code - 97) }
    if ($code -ge 48 -and $code -le 57 -and $map.Digit) {
        return [char]::ConvertFromUtf32($map.Digit + $code - 48)
    }
    return [string]$Char   # punctuation, spaces, emoji etc. pass through
}

function Convert-Text {
    param([string]$InputText, [string[]]$Cycle)

    $sb = [System.Text.StringBuilder]::new()
    $i  = 0   # counts letters/digits only, so spaces don't break the alternation
    foreach ($c in $InputText.ToCharArray()) {
        if ($c -match '[A-Za-z0-9]') {
            [void]$sb.Append((Convert-Char -Char $c -BaseStyle $Cycle[$i % $Cycle.Count]))
            $i++
        }
        else {
            [void]$sb.Append($c)
        }
    }
    $sb.ToString()
}

if ([string]::IsNullOrEmpty($Text)) { $Text = Read-Host 'Your text' }

if ($Style -eq 'All') {
    foreach ($key in $OutputStyles.Keys) {
        [pscustomobject]@{
            Style  = $key
            Label  = $OutputStyles[$key].Label
            Result = Convert-Text -InputText $Text -Cycle $OutputStyles[$key].Cycle
        }
    }
    if ($Copy) { Write-Warning 'Use -Style with -Copy to choose which result goes to the clipboard.' }
}
else {
    $result = Convert-Text -InputText $Text -Cycle $OutputStyles[$Style].Cycle
    if ($Copy) {
        Set-Clipboard -Value $result
        Write-Host "Copied to clipboard: $result" -ForegroundColor Green
    }
    else {
        $result
    }
}
