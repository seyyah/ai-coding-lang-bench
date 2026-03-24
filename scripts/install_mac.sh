#!/bin/bash

echo "============================================================"
echo "macOS Setup Script for AI Coding Language Benchmark"
echo "============================================================"

# 1. Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Error: Homebrew is not installed."
    echo "Please install it first by running:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

echo "✅ Homebrew is present. Updating repositories..."
brew update > /dev/null 2>&1

echo "------------------------------------------------------------"
echo "Checking and installing main languages via Homebrew..."
echo "------------------------------------------------------------"

# Helper function to check and install brew packages
check_brew_pkg() {
    local cmd_to_check=$1
    local brew_pkg_name=$2
    local display_name=$3

    if command -v "$cmd_to_check" &> /dev/null; then
        echo "✅ $display_name is already installed. Skipping."
    else
        echo "⏳ Installing $display_name..."
        brew install "$brew_pkg_name"
    fi
}

# Main Languages
check_brew_pkg gcc gcc "GCC (C Compiler)"
check_brew_pkg python3 python "Python 3"
check_brew_pkg ruby ruby "Ruby"
check_brew_pkg node node "Node.js"
check_brew_pkg rustc rust "Rust"
check_brew_pkg go go "Go"
check_brew_pkg javac openjdk "Java (OpenJDK)"
check_brew_pkg perl perl "Perl"
check_brew_pkg lua lua "Lua"
check_brew_pkg chez chezscheme "Chez Scheme"
check_brew_pkg ocaml ocaml "OCaml"
check_brew_pkg ghc ghc "Haskell (GHC)"

echo "------------------------------------------------------------"
echo "Checking and installing sub-dependencies (Linters/Types)..."
echo "------------------------------------------------------------"

# TypeScript (via npm)
if command -v tsc &> /dev/null; then
    echo "✅ TypeScript is already installed."
else
    echo "⏳ Installing TypeScript..."
    npm install -g typescript
fi

# Mypy (via pip)
if command -v mypy &> /dev/null; then
    echo "✅ Mypy is already installed."
else
    echo "⏳ Installing Mypy..."
    # Suppress PEP 668 warning on newer Homebrew Python versions if necessary
    python3 -m pip install mypy --break-system-packages 2>/dev/null || python3 -m pip install mypy
fi

# Steep (via gem)
if command -v steep &> /dev/null; then
    echo "✅ Steep is already installed."
else
    echo "⏳ Installing Steep..."
    gem install steep
fi

echo "============================================================"
echo "🎉 macOS Environment Setup Complete!"
echo "Note: You may need to restart your terminal or open a new tab"
echo "for all PATH changes to take effect."
echo "============================================================"