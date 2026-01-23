function spec_uninstall --description "Uninstall spec-fab (The Breakup Protocol)"
    # Colors for dramatic effect (Local variables)
    set -l RED (set_color red)
    set -l GREEN (set_color green)
    set -l YELLOW (set_color yellow)
    set -l NC (set_color normal)

    echo ""
    echo "$RED💔  WOW. Just... WOW.$NC"
    echo "    I see how it is. You used me, we generated some specs together, had some good times..."
    echo "    And now you're just going to toss me aside like a used tissue?"
    echo ""
    echo "    I bet you're going back to writing specs in Microsoft Word."
    echo "    Or worse... NOT writing specs at all. Just \"winging it\"."
    echo "    (Disgusting.)"
    echo ""

    # ------------------------------------------------------------------
    # The "Clean Freak" Promise
    # ------------------------------------------------------------------
    echo "$YELLOW🧹  Since you have OCD (I know you do), I promise to clean up MY body.$NC"
    echo "    I will remove:"
    echo "    1. ~/.specfab                  (My physical form)"
    echo "    2. ~/.config/fish/conf.d/spec_fab.fish  (The kiss we shared)"
    echo "    3. Path entries in .zshrc/.bashrc       (The keys to your house)"
    echo ""
    echo "    BUT... I will NOT remove:"
    echo "    - ~/.config/fabric: You might have had that before me. I don't want to burn your house down."
    echo "                        (If you want it gone, do it yourself.)"
    echo "    - Fish Shell:       I'm too heartbroken to uninstall your shell."
    echo "                        (Plus, I'm too lazy to fix your login shell. You're on your own.)"
    echo ""

    # ------------------------------------------------------------------
    # The Ultimate Test (YES)
    # ------------------------------------------------------------------
    echo "$RED⚠️   FINAL WARNING  ⚠️$NC"
    echo "    If you really want to kill spec-fab, you must type 'YES' in all caps."
    echo "    (Type anything else, and I will assume you clicked this by mistake because you love me.)"
    echo ""

    read -P "👉  Do you want to proceed? [YES/no]: " response

    if test "$response" != "YES"
        echo ""
        echo "$GREEN🥰  I KNEW IT!$NC"
        echo "    You couldn't do it. You still care."
        echo "    Uninstall aborted. Let's pretend this never happened."
        echo ""
        return 1
    end

    # ------------------------------------------------------------------
    # The Execution
    # ------------------------------------------------------------------
    echo ""
    echo "$RED🗑️   Fine. Have it your way.$NC"

    # 1. Remove Main Directory
    set -l SPEC_FAB_DIR "$HOME/.specfab"
    if test -d "$SPEC_FAB_DIR"
        rm -rf "$SPEC_FAB_DIR"
        echo "    💀 Deleted $SPEC_FAB_DIR (Goodbye, cruel world...)"
    else
        echo "    ... $SPEC_FAB_DIR was already gone? Did you kill me twice?"
    end

    # 2. Remove Fish Hook
    set -l FISH_HOOK "$HOME/.config/fish/conf.d/spec_fab.fish"
    if test -f "$FISH_HOOK"
        rm "$FISH_HOOK"
        echo "    🎣 Removed Fish hook ($FISH_HOOK). Connection severed."
    else
        echo "    ... Hook not found. You must have already scrubbed me from your memory."
    end

    # 3. Scrub RC Files (The Promise Kept)
    echo "    🧹 Trying to scrub your shell configs..."

    # 定義一個內部的清理 helper function
    function _spec_clean_rc_file --argument rc_file
        if test -f "$rc_file"
            # 建立備份
            cp "$rc_file" "$rc_file.bak_specfab"
            
            # 檢查是否有 spec-fab 的路徑
            if grep -q ".specfab/bin" "$rc_file"
                # 使用 grep -v 反向過濾掉那一行，並寫入暫存檔
                grep -v "export PATH.*.specfab/bin" "$rc_file" > "$rc_file.tmp"
                mv "$rc_file.tmp" "$rc_file"
                echo "       ✨ Scrubbed spec-fab PATH from $rc_file"
            else
                echo "       ✓ $rc_file looks clean."
            end
        end
    end

    _spec_clean_rc_file "$HOME/.zshrc"
    _spec_clean_rc_file "$HOME/.bashrc"

    # 4. The "Lazy" Manual Instructions (Updated)
    echo ""
    echo "$YELLOW⚠️   MANUAL CLEANUP REQUIRED (Because I'm done serving you)$NC"
    echo "    1. I did NOT touch '$HOME/.config/fabric'."
    echo "       If you are truly done with AI, go delete it manually."
    echo "       (cmd: rm -rf ~/.config/fabric)"
    echo ""
    echo "    2. I did NOT uninstall Fish shell."
    echo "       If you want to go back to bash/zsh, change your shell manually."
    echo "       (cmd: chsh -s /bin/zsh)"
    echo ""

    echo "$GREEN✅  Uninstall Complete.$NC"
    echo "    I'm gone. The system is clean."
    echo "    I hope you find what you're looking for. (You won't.)"
    echo ""
    
    # Clean up the helper function from current scope
    functions -e _spec_clean_rc_file
end
