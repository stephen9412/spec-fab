function spec_constitution --description "Update constitution based on stdin (file) or args (text)"
    # 1. Set target file and date
    set -l target_file ".specify/memory/constitution.md"
    set -l current_date (date +%Y-%m-%d)
    
    # 2. Check if the target file exists
    if not test -f "$target_file"
        echo "❌ Error: $target_file not found. Please run 'spec_init' first."
        return 1
    end

    # 3. Smart Input Handling
    set -l user_intent ""

    # Determine if standard input (stdin) is a terminal
    if not isatty stdin
        # If not a terminal, it means data is flowing in from a Pipe (e.g., cat PRD.md | upgrade_constitution)
        # Read all stdin content into a variable
        read -z user_intent
        echo "📥 Reading intent from STDIN (Pipe)..."
    else
        # If it is a terminal, it means the user is using arguments (e.g., upgrade_constitution "Fix typo")
        set user_intent "$argv"
        
        if test -n "$user_intent"
            echo "📥 Reading intent from ARGUMENTS..."
        end
    end

    # 4. Fallback: If still empty, provide a default value
    if test -z "$user_intent"
        echo "⚠️  No input provided. Using defaults."
        set user_intent "Update based on modern engineering standards defaults."
    end

    # 5. Read existing constitution content
    set -l origin_content (cat "$target_file")

    # 6. Compose Prompt Input
    # Structure: Date -> Status Quo -> User Intent (could be a PRD or a statement)
    set -l combined_input "CURRENT_DATE: $current_date

---
ORIGINAL_CONSTITUTION_CONTENT:
$origin_content

---
USER_UPDATE_INTENT (PRD/README/INSTRUCTIONS):
$user_intent
"

    echo "🤖 Fabric is analyzing and upgrading the constitution..."
    echo "-----------------------------------------------------"

    # Create a unique temporary file
    set -l temp_file (mktemp)

    # Execute Fabric and write the result to the temporary file
    # We capture fabric's output to the temp file while keeping stderr to display errors
    echo "$combined_input" | fabric -p upgrade_constitution > $temp_file

    # Check the exit status code of the previous command (fabric)
    set -l fabric_status $status

    if test $fabric_status -ne 0
        echo ""
        echo "❌ FABRIC ERROR: Process failed with status $fabric_status."
        echo "🛡️  Safe Guard: Original constitution preserved at $target_file"
        rm -f $temp_file
        return 1
    end

    # Double check: Confirm the temporary file is not empty (avoid empty files due to API errors)
    if not test -s $temp_file
        echo ""
        echo "❌ ERROR: Generated content is empty (Network error?)."
        echo "🛡️  Safe Guard: Original constitution preserved at $target_file"
        rm -f $temp_file
        return 1
    end

    # If everything is normal, print the temp file content for the user (to satisfy the need to see output)
    cat $temp_file
    
    # Formally overwrite the file
    mv $temp_file $target_file
    
    echo ""
    echo "-----------------------------------------------------"
    echo "✅ Constitution upgraded and SAFELY saved to: $target_file"
end
