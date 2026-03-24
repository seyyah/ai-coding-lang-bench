# scripts/install_windows.ps1
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "AI Coding Language Benchmark - Windows Ultimate Installer" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. INSTALL ALL LANGUAGES VIA WINGET
Write-Host "`n[1/4] Installing Core Languages and Compilers..." -ForegroundColor Yellow
$wingetPackages = @(
    "Golang.Go",
    "OpenJS.NodeJS",
    "Rustlang.Rustup",
    "RubyInstallerTeam.RubyWithDevkit",
    "EclipseAdoptium.Temurin.21.JDK",
    "StrawberryPerl.StrawberryPerl",
    "Haskell.ghcup",
    "Cisco.ChezScheme",
    "Diskuv.OCaml",
    "DEVCOM.Lua"
)

foreach ($pkg in $wingetPackages) {
    Write-Host ">>> Installing: $pkg"
    winget install --id $pkg --exact --accept-package-agreements --accept-source-agreements
}

# 2. SUB-DEPENDENCIES (LINTERS & TYPES)
Write-Host "`n[2/4] Installing Sub-dependencies (TypeScript, Mypy, Steep)..." -ForegroundColor Yellow
Write-Host ">>> Installing TypeScript..."
npm install -g typescript

Write-Host ">>> Installing Mypy..."
python -m pip install mypy

Write-Host ">>> Installing Steep..."
gem install steep

# 3. HASKELL GHC COMPILER TRIGGER
Write-Host "`n[3/4] Configuring Haskell (GHC) Compiler..." -ForegroundColor Yellow
if (Get-Command ghcup -ErrorAction SilentlyContinue) {
    ghcup install ghc
    ghcup set ghc
} else {
    Write-Host "Warning: ghcup might not be in your PATH yet. Please run 'ghcup install ghc' manually after restarting your terminal." -ForegroundColor Red
}

# 4. PATH CORRECTIONS (FOR MYPY)
Write-Host "`n[4/4] Checking Windows PATH Settings for Mypy..." -ForegroundColor Yellow
$pythonScriptsPath = "$env:LOCALAPPDATA\Programs\Python\Python313\Scripts"
if (Test-Path $pythonScriptsPath) {
    Write-Host "Python Scripts folder found. It is highly recommended to add this to your system PATH: $pythonScriptsPath" -ForegroundColor Green
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "🎉 INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "ATTENTION: You MUST RESTART your computer or terminal window" -ForegroundColor Red
Write-Host "for the newly installed languages to become active in your PATH." -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Green