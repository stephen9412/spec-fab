function spec_brief --description "Generate Project Brief"
    # Usage: cat notes.txt | spec_brief
    
    set -l input_content
    # Read STDIN or file
    if test (count $argv) -gt 0
        set input_content (cat $argv[1])
    else
        read -z input_content
    end

    # 1. Read template content
    set -l template_path ".specify/templates/brief-template.md"
    
    # If the template does not exist in the project, use the default (or hardcode it in a variable)
    if not test -f $template_path
        # For convenience, no fallback is implemented here; assuming 'init' has already created it
        echo "⚠️  Template not found at $template_path. Using default structure." >&2
    end
    set -l template_content (cat $template_path 2>/dev/null)

    echo "👔 Consultant Agent is brainstorming..." >&2

    # 2. Compose Prompt: Send template + notes to Fabric
    # Use string formatting to clearly label both sections
    echo -e "TEMPLATE:\n$template_content\n\nUSER_NOTES:\n$input_content" | fabric -p create_project_brief | tee brief.md

    echo "" >&2
    echo "✅ Project Brief created at 'brief.md'." >&2
end
