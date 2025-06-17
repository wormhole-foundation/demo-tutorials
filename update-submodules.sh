#!/bin/bash

# Exit on any error
set -e

echo "📦 Checking submodule branches and updating..."

# Function to check and update submodules
check_and_update_submodules() {
    local has_issues=0
    
    # Get list of all submodules
    if [ ! -f .gitmodules ]; then
        echo "❌ No .gitmodules file found in current directory"
        exit 1
    fi
    
    # Parse submodules from .gitmodules and store in array
    local submodules=()
    while IFS= read -r line; do
        if [[ $line =~ submodule\..*\.path ]]; then
            local path=$(echo "$line" | cut -d' ' -f2)
            submodules+=("$path")
        fi
    done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path$')
    
    # Process each submodule
    for path in "${submodules[@]}"; do
        if [ -d "$path" ]; then
            echo "🔍 Checking submodule: $path"
            
            # Enter the submodule directory and check current branch
            cd "$path"
            
            # Get current branch name
            current_branch=$(git branch --show-current 2>/dev/null || echo "")
            
            if [ -z "$current_branch" ]; then
                echo "   ⚠️  Repository is in detached HEAD state - please checkout main manually"
                has_issues=1
            elif [ "$current_branch" != "main" ]; then
                echo "   ⚠️  Currently on '$current_branch' - please checkout main manually"
                has_issues=1
            else
                echo "   ✅ On main branch"
                
                # Go back to parent directory to run submodule update
                cd - > /dev/null
                
                echo "   🔄 Updating..."
                if git submodule update --remote --merge "$path"; then
                    echo "   ✅ Updated successfully"
                else
                    echo "   ❌ Failed to update"
                    has_issues=1
                fi
                
                # Go back to submodule to continue loop
                cd "$path"
            fi
            
            # Return to parent directory
            cd - > /dev/null
            echo ""
        fi
    done
    
    return $has_issues
}

# Run the check and update function
if check_and_update_submodules; then
    echo "🎉 All submodules updated successfully!"
    echo "Run 'git status' to review changes before committing."
else
    echo "⚠️  Some submodules need manual attention. Fix them and re-run the script."
    exit 1
fi
