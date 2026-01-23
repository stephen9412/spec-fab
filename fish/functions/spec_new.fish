function spec_new --description "Create a new Feature Spec (SpecFab Flow)"
    # ------------------------------------------------------------------
    # 0. Pre-flight Check: Git Environment
    # ------------------------------------------------------------------
    # Check if inside a Git working directory. If not, git rev-parse returns a non-zero value.
    if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        echo "❌ Error: Not a git repository."
        echo "   spec-fab relies on Git branches to manage features."
        echo "💡 Tip: Run 'spec_init' to initialize the environment, or run 'git init' manually."
        return 1
    end

    # ------------------------------------------------------------------
    # 1. Smart Input Handling (Pipe or Arguments)
    # ------------------------------------------------------------------
    set -l feature_desc ""

    # Determine if standard input (stdin) is a terminal
    if not isatty stdin
        # If not a terminal, it means data is coming in from a Pipe
        # (e.g., cat feature.txt | spec_new)
        read -z feature_desc
        echo "📥 Reading feature description from STDIN (Pipe)..."
    else
        # If it is a terminal, it means the user is using arguments
        # (e.g., spec_new "Add login")
        set feature_desc "$argv"
        
        if test -n "$feature_desc"
            echo "📥 Reading feature description from ARGUMENTS..."
        end
    end

    # Error handling: If no input was provided at all
    if test -z "$feature_desc"
        echo "❌ Error: No feature description provided."
        echo "   Usage 1: spec_new \"Add user login\""
        echo "   Usage 2: cat idea.md | spec_new"
        return 1
    end

    set -l constitution_file ".specify/memory/constitution.md"

    # Check if the constitution exists (this is the core of SpecFab; no constitution, no work)
    if not test -f "$constitution_file"
        echo "❌ Constitution not found! Run 'spec_init' first."
        return 1
    end

    # ------------------------------------------------------------------
    # Step 1: Generate Short Name (Slug)
    # ------------------------------------------------------------------
    set -l slug (echo "$feature_desc" | fabric -p generate_feature_slug)
    set slug (string trim $slug)
    
    if test -z "$slug"
        set slug "feature-update"
    end
    
    echo "🏷️  Slug generated: $slug"

    # ------------------------------------------------------------------
    # Step 2: Calculate Next ID
    # ------------------------------------------------------------------
    set -l max_id 0
    if test -d "specs"
        for dir in specs/*
            set -l dir_name (basename "$dir")
            if string match -r '^[0-9]+' "$dir_name" > /dev/null
                set -l current_id (string match -r '^[0-9]+' "$dir_name")
                if test "$current_id" -gt "$max_id"
                    set max_id $current_id
                end
            end
        end
    end
    
    set -l next_id (math $max_id + 1)
    set -l full_name "$next_id-$slug"
    set -l feature_dir "specs/$full_name"
    set -l spec_file "$feature_dir/spec.md"

    echo "🔢 Next Feature ID: $next_id"
    echo "📂 Target Directory: $feature_dir"

    # ------------------------------------------------------------------
    # Step 3: Git Operations & Directory Setup
    # ------------------------------------------------------------------
    mkdir -p "$feature_dir"
    
    if not git show-ref --verify --quiet "refs/heads/$full_name"
        git checkout -b "$full_name"
        echo "🌿 Git branch created: $full_name"
    else
        echo "⚠️  Branch $full_name already exists, switching to it..."
        git checkout "$full_name"
    end

    # ------------------------------------------------------------------
    # Step 4: Generate Spec Content (Drafting)
    # Fabric Pattern: create_spec_draft
    # Input: Constitution + Template + User Description
    # ------------------------------------------------------------------
    echo "🏗️  Drafting Specification (this may take a moment)..."
    
    set -l template_file ".specify/templates/spec-template.md"
    
    # If the template does not exist, give a warning or use default (assuming it must exist as spec_init generates it)
    if not test -f "$template_file"
        echo "❌ Error: Spec template not found at $template_file"
        return 1
    end

    # Inject Template into the Drafter so it knows which fields to fill
    set -l draft_context "
=== CONSTITUTION ===
$(cat $constitution_file)

=== TARGET_TEMPLATE ===
$(cat $template_file)

=== FEATURE_DESCRIPTION ===
$feature_desc
"
    
    # Generate the initial Draft
    set -l temp_draft (echo "$draft_context" | fabric -p create_spec_draft)

    if test -z "$temp_draft"
        echo "❌ Error: AI failed to generate draft."
        return 1
    end

    # ------------------------------------------------------------------
    # Step 5: Validate & Refine (Self-Correction)
    # Fabric Pattern: refine_spec_quality
    # Input: The Draft
    # Goal: Remove implementation details, ensure measurable metrics
    # ------------------------------------------------------------------
    echo "🔍 Refining Spec quality (Checking against constraints)..."
    
    # Use a temporary file to capture the Refine output to prevent emptying the file if Refine fails
    set -l refined_output_file (mktemp)
    
    # Only pass the Draft here; no need to pass the Template again
    echo "$temp_draft" | fabric -p refine_spec_quality > $refined_output_file
    
    if test -s $refined_output_file
        # Refine successful, move to target file
        mv $refined_output_file "$spec_file"
        echo "✅ Spec Refined & Created at: $spec_file"
    else
        # Refine failed (possibly API error), fallback to using the initial draft
        echo "⚠️  Refinement failed (empty output). Saving Draft version instead."
        echo "$temp_draft" > "$spec_file"
        echo "✅ Draft Spec Created at: $spec_file"
    end
end
