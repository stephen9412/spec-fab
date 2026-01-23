function upgrade_spec_fab --description "Upgrade spec-fab core to the latest version"
    set -l spec_fab_root "$HOME/.specfab"

    echo "🚀 Checking for spec-fab updates..."

    # 1. Safety Check
    if not test -d "$spec_fab_root/.git"
        echo "❌ Error: spec-fab installation not found at $spec_fab_root"
        return 1
    end

    # 2. Execute Git Pull
    # Use -C to directly specify the git working directory, no need to cd in
    if git -C "$spec_fab_root" pull
        echo ""
        echo "✅ spec-fab core updated successfully."
        echo "🎉 You are now running the latest version."
    else
        echo ""
        echo "❌ Update failed."
        echo "   Please check your network connection or try manually:"
        echo "   cd $spec_fab_root && git pull"
        return 1
    end
end
