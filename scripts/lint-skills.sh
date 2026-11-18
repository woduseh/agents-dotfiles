#!/usr/bin/env bash
set -u

repo_root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
manifest="$repo_root/manifest.psd1"
skills_root="$repo_root/skills"
problems=0

fail() {
    echo "[FAIL] $1"
    problems=$((problems + 1))
}

# Prints the quoted entries of a manifest array, one per line. Handles the one-line and the
# multi-line `Name = @( ... )` forms that manifest.psd1 uses.
manifest_list() {
    awk -v key="$1" '
        !inside && $0 ~ "^[[:space:]]*" key "[[:space:]]*=[[:space:]]*@\\(" { inside = 1 }
        inside {
            line = $0
            sub(/#.*/, "", line)
            while (match(line, /\047[^\047]*\047/)) {
                print substr(line, RSTART + 1, RLENGTH - 2)
                line = substr(line, RSTART + RLENGTH)
            }
            if ($0 ~ /\)/) { exit }
        }
    ' "$manifest"
}

listed() {
    printf '%s\n' "$2" | grep -qxF -- "$1"
}

# Prints the value of a frontmatter key with surrounding whitespace and one pair of quotes removed.
frontmatter_value() {
    printf '%s\n' "$2" | sed -n "s/^$1:[[:space:]]*//p" | head -n 1 \
        | sed -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

if [ ! -f "$manifest" ] || [ ! -d "$skills_root" ]; then
    echo "[FAIL] manifest.psd1 or skills/ not found under $repo_root"
    exit 1
fi

active="$(manifest_list Skills)"
removed="$(manifest_list RemovedSkills)"
valid_name='^[a-z0-9-]{1,64}$'
skill_count=0

for dir in "$skills_root"/*/; do
    [ -d "$dir" ] || continue
    dir="${dir%/}"
    name_dir="$(basename "$dir")"
    skill_count=$((skill_count + 1))
    skill_file="$dir/SKILL.md"
    if [ ! -f "$skill_file" ]; then
        fail "$name_dir: missing SKILL.md"
        continue
    fi

    frontmatter="$(awk '
        { sub(/\r$/, "") }
        NR == 1 { if ($0 != "---") { exit 1 } next }
        $0 == "---" { closed = 1; exit }
        { print }
        END { if (!closed) { exit 1 } }
    ' "$skill_file")" || { fail "$name_dir: no YAML frontmatter"; continue; }

    if printf '%s\n' "$frontmatter" | grep -q '^name:'; then
        name="$(frontmatter_value name "$frontmatter")"
        [ "$name" = "$name_dir" ] || fail "$name_dir: name '$name' does not match directory"
        printf '%s' "$name" | grep -Eq "$valid_name" || fail "$name_dir: name must be 1-64 lowercase letters, digits, or hyphens"
        if printf '%s' "$name" | grep -Eq 'anthropic|claude'; then fail "$name_dir: name contains a reserved word"; fi
    else
        fail "$name_dir: missing name"
    fi

    if printf '%s\n' "$frontmatter" | grep -q '^description:'; then
        description="$(frontmatter_value description "$frontmatter")"
        # Characters, not bytes, whatever the locale: drop UTF-8 continuation bytes and count the rest.
        length="$(printf '%s' "$description" | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d '[:space:]')"
        [ "$length" -gt 0 ] || fail "$name_dir: empty description"
        [ "$length" -le 1024 ] || fail "$name_dir: description longer than 1024 characters"
        if printf '%s' "$description" | grep -Eq '<[^>]+>'; then fail "$name_dir: description contains XML tags"; fi
    else
        fail "$name_dir: missing description"
    fi

    # Same count as the PowerShell lint: the number of newline-separated parts.
    line_count=$(($(tr -cd '\n' < "$skill_file" | wc -c) + 1))
    [ "$line_count" -le 500 ] || fail "$name_dir: SKILL.md has $line_count lines (limit 500)"

    while IFS= read -r file; do
        while IFS= read -r link; do
            [ -n "$link" ] || continue
            [ -f "$(dirname "$file")/$link" ] || fail "$name_dir: broken link '$link' in $(basename "$file")"
        done <<EOF
$(grep -oE '\]\([^)]+\.md\)' "$file" | sed -e 's/^](//' -e 's/)$//')
EOF
    done <<EOF
$(find "$dir" -type f -name '*.md')
EOF

    [ -f "$dir/agents/openai.yaml" ] || fail "$name_dir: missing agents/openai.yaml"

    if ! listed "$name_dir" "$active" && ! listed "$name_dir" "$removed"; then
        fail "$name_dir: not listed in manifest.psd1"
    fi
done

while IFS= read -r skill; do
    [ -n "$skill" ] || continue
    [ -d "$skills_root/$skill" ] || fail "manifest lists '$skill' but skills/$skill does not exist"
done <<EOF
$active
EOF

while IFS= read -r skill; do
    [ -n "$skill" ] || continue
    printf '%s' "$skill" | grep -Eq "$valid_name" || fail "Invalid removed skill name: $skill"
    if listed "$skill" "$active"; then fail "Skill is both installed and removed: $skill"; fi
done <<EOF
$removed
EOF

routing="$repo_root/evals/routing-cases.json"
if [ -f "$routing" ]; then
    routed="$({
        grep -oE '"expect":[[:blank:]]*"[^"]*"' "$routing" | sed -E 's/^"expect"://'
        grep -oE '"exclude":[[:blank:]]*\[[^]]*\]' "$routing" | sed -E 's/^"exclude"://'
    } | grep -oE '"[^"]*"' | tr -d '"' | LC_ALL=C sort -u)"
    while IFS= read -r skill; do
        [ -n "$skill" ] || continue
        listed "$skill" "$active" || fail "evals/routing-cases.json: unknown skill '$skill'"
    done <<EOF
$routed
EOF
else
    fail "evals/routing-cases.json not found"
fi

if [ "$problems" -gt 0 ]; then
    exit 1
fi

echo "[OK] $skill_count skills passed"
