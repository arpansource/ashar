#!/bin/bash

# Colors for better UX
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory
DOCS_DIR="$HOME/docs"

# Create directories if they don't exist
mkdir -p "$DOCS_DIR"/{bugs,features,improvements}

# Clear screen for cleaner experience
clear

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}   Documentation Helper${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Ask for name first
echo -e "${GREEN}What do you want to call this doc?${NC}"
echo -e "${YELLOW}(e.g., wifi-disconnect, docker-setup, api-auth)${NC}"
read -p "Name: " doc_name

# Sanitize name (replace spaces with hyphens, lowercase)
doc_name=$(echo "$doc_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

if [ -z "$doc_name" ]; then
    echo -e "${YELLOW}Name cannot be empty. Exiting.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Select documentation type:${NC}"
echo "1) Bug/Fix"
echo "2) Feature/Setup"
echo "3) Improvement/Optimization"
read -p "Choice [1-3]: " doc_type

case $doc_type in
    1)
        doc_type_name="bug"
        doc_dir="$DOCS_DIR/bugs"
        ;;
    2)
        doc_type_name="feature"
        doc_dir="$DOCS_DIR/features"
        ;;
    3)
        doc_type_name="improvement"
        doc_dir="$DOCS_DIR/improvements"
        ;;
    *)
        echo -e "${YELLOW}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

# Generate filename with date
date_str=$(date +%Y-%m-%d)
filename="${date_str}-${doc_name}.md"
filepath="${doc_dir}/${filename}"

# Check if file exists
if [ -f "$filepath" ]; then
    echo -e "${YELLOW}File already exists: $filepath${NC}"
    read -p "Overwrite? [y/N]: " overwrite
    if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
        echo "Exiting."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Answer the following questions (press Enter for empty answers):${NC}"
echo ""

# Function to ask questions
ask_question() {
    local question=$1
    local var_name=$2
    echo -e "${GREEN}$question${NC}"

    # Check if this should be a multiline input
    if [[ $question == *"code"* ]] || [[ $question == *"logs"* ]] || [[ $question == *"output"* ]]; then
        echo -e "${YELLOW}(Type your answer, press Ctrl+D when done)${NC}"
        local answer=$(cat)
    else
        read -p "> " answer
    fi

    eval "$var_name=\"$answer\""
}

# Questions based on type
if [ "$doc_type_name" = "bug" ]; then
    ask_question "What broke or what was the problem?" "problem"
    ask_question "What error messages or symptoms did you see?" "symptoms"
    ask_question "What did you try that DIDN'T work?" "failed_attempts"
    ask_question "What actually FIXED it?" "solution"
    ask_question "How do you verify it's fixed? (commands/checks)" "verification"
    ask_question "Any related docs or links?" "related"

    # Generate bug fix markdown
    cat > "$filepath" << EOF
# $doc_name

**Date:** $date_str
**Type:** Bug Fix
**Status:** Resolved

## Problem

$problem

## Symptoms / Error Messages

\`\`\`
$symptoms
\`\`\`

## What Didn't Work ❌

$failed_attempts

## Solution ✅

$solution

## Verification

\`\`\`bash
$verification
\`\`\`

## Related Documentation

$related

---

**Tags:** bug, fix, $(echo $doc_name | tr '-' ' ')
EOF

elif [ "$doc_type_name" = "feature" ]; then
    ask_question "What are you setting up or building?" "feature_name"
    ask_question "Why are you doing this? (use case/goal)" "purpose"
    ask_question "What are the installation/setup steps?" "setup_steps"
    ask_question "What's the configuration? (paste config files/code)" "configuration"
    ask_question "How do you use/test it?" "usage"
    ask_question "Any gotchas or important notes?" "notes"

    # Generate feature/setup markdown
    cat > "$filepath" << EOF
# $doc_name

**Date:** $date_str
**Type:** Feature/Setup

## Overview

$feature_name

## Purpose

$purpose

## Installation / Setup

$setup_steps

## Configuration

\`\`\`
$configuration
\`\`\`

## Usage

$usage

## Important Notes

$notes

---

**Tags:** feature, setup, $(echo $doc_name | tr '-' ' ')
EOF

elif [ "$doc_type_name" = "improvement" ]; then
    ask_question "What did you improve/optimize?" "what_improved"
    ask_question "What was the problem with the old way?" "old_problem"
    ask_question "What's the new approach?" "new_approach"
    ask_question "What are the benefits? (performance, clarity, etc.)" "benefits"
    ask_question "Before/After comparison (metrics, code, etc.)" "comparison"
    ask_question "Any trade-offs or considerations?" "tradeoffs"

    # Generate improvement markdown
    cat > "$filepath" << EOF
# $doc_name

**Date:** $date_str
**Type:** Improvement/Optimization

## What Was Improved

$what_improved

## Old Problem

$old_problem

## New Approach

$new_approach

## Benefits

$benefits

## Before vs After

$comparison

## Trade-offs / Considerations

$tradeoffs

---

**Tags:** improvement, optimization, $(echo $doc_name | tr '-' ' ')
EOF

fi

echo ""
echo -e "${GREEN}✅ Documentation saved!${NC}"
echo -e "${BLUE}File: $filepath${NC}"
echo ""
echo -e "${YELLOW}Quick actions:${NC}"
echo "  View:   cat $filepath"
echo "  Edit:   \$EDITOR $filepath"
echo "  Search: grep -r 'keyword' $DOCS_DIR"
echo ""
