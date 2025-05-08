#!/bin/bash

# Exit on any error
set -e

echo "📦 Updating all submodules to the latest commit from their remote branches..."

# This pulls the latest commit for each submodule's configured branch (e.g. main)
git submodule update --remote --merge

echo "✅ Submodules updated."
echo "Please run 'git status' to review the changes before committing."
