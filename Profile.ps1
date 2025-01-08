$env:EDITOR = "C:\Users\1453c\AppData\Local\Programs\Microsoft VS Code Insiders\bin\code-insiders"
try {
    Import-Module -Name Posh-SSH
}
catch {
    Uninstall-Module -Name Posh-SSH -Force

    Install-Module -Name Posh-SSH -RequiredVersion 3.2.4 -Force -AllowClobber
    Import-Module -Name Posh-SSH
}


try {
    Import-Module -Name posh-git
}
catch {
    Uninstall-Module -Name posh-git -Force

    Install-Module -Name posh-git -RequiredVersion 1.1.0 -Force -AllowClobber
    Import-Module -Name posh-git
}

Import-Module -Name Terminal-Icons
Import-Module -Name FindLargeFiles
Import-Module git-aliases -DisableNameChecking

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\iterm2.omp.json" | Invoke-Expression
