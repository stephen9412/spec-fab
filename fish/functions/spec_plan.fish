function spec_plan --description "Generate Technical Plan with Conflict markers (SpecFab Flow)"
    # 1. Automatically detect Git branch and environment
    set -l current_branch (git branch --show-current)
    
    # Validation: If not on a feature branch
    if test -z "$current_branch"
        echo "❌ Error: Not in a git repository."
        return 1
    end

    # Define paths: Assumes spec is located at specs/<branch-name>/spec.md
    set -l feature_dir "specs/$current_branch"
    set -l spec_file "$feature_dir/spec.md"
    set -l research_file "$feature_dir/research.md"
    set -l plan_file "$feature_dir/plan.md"
    
    # 2. Check if necessary files exist
    if not test -f "$spec_file"
        echo "❌ Error: Spec file not found at $spec_file"
        echo "   Are you on the correct feature branch? ($current_branch)"
        return 1
    end

    set -l constitution_file ".specify/memory/constitution.md"
    if not test -f "$constitution_file"
        echo "❌ Error: Constitution not found at $template_file"
        echo "   Run 'spec_constitution' to generate it."
        return 1
    end

    set -l template_file ".specify/templates/plan-template.md"
    if not test -f "$template_file"
        echo "❌ Error: Plan template not found at $template_file"
        echo "   Run 'spec_init' to generate it."
        return 1
    end

    set -l plan_index ".specify/memory/plan-index.md"
    # If Plan Index (Technical Memory) exists, read it in
    set -l plan_index_content ""
    if test -f "$plan_index"
        set plan_index_content "$(cat $plan_index)"
    end

    echo "🚀 Generating Technical Plan for feature: $current_branch"
    
    # 1. Prepare Context
    set -l context "
=== CONSTITUTION (Constraints) ===
$(cat $constitution_file)

=== PLAN_INDEX (Architecture Standards & Tech Stack) ===
$plan_index_content

=== PLAN_TEMPLATE (Fill this) ===
$(cat $template_file)

=== FEATURE_SPEC (Requirements) ===
$(cat $spec_file)
"

    # 2. If research has been done, add Research to Context
    if test -f "$research_file"
        echo "   🕵️  Including Research Report..."
        set context "$context

=== RESEARCH_REPORT (Context) ===
$(cat $research_file)
"
    end

    echo "🧠 Architecting the solution (Generating Conflicts if uncertain)..."

    # 5. Call Fabric (create_tech_plan)
    # Use --strategy tot to force AI branching thought, which best triggers "Conflict Options"
    set -l temp_plan (mktemp)
    
    echo "$context" | fabric -p create_tech_plan --strategy tot > $temp_plan

    # Check if temp file is empty (error handling)
    if not test -s $temp_plan
        echo "❌ Error: AI failed to generate plan (Empty output)."
        rm $temp_plan
        return 1
    end

    # 6. Move file
    mv $temp_plan "$plan_file"

    echo "✅ Technical Plan created at: $plan_file"

    # 7. Detect if conflict markers exist and notify user
    if grep -q "<<<<<<<" "$plan_file"
        echo "⚠️  CONFLICTS DETECTED! The Architect presented options."
        echo "   Please open the file and resolve the merge conflicts."
    end
end
