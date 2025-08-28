Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

$env:UV_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple"
$env:UV_PYTHON_INSTALL_MIRROR = "https://pypi.tuna.tsinghua.edu.cn/simple"

$env:EDITOR = "nvim"

Invoke-Expression (& { (zoxide init powershell | Out-String) })

function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}
