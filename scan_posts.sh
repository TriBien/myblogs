#!/bin/bash

CONTENTS_DIR="contents"
OUTPUT_FILE="posts.js"

echo "Scanning posts..."

generate_post_json() {
  local file=$1
  local category=$(basename "$(dirname "$file")")
  local title=$(basename "$file" .html)
  local url="$file"
  local date=$(date +%Y-%m-%d -r "$file" 2>/dev/null || date +%Y-%m-%d)
  local excerpt=$(sed -n 's/.*<p[^>]*>\([^<]*\).*/\1/p; s/.*<p>\([^<]*\).*/\1/p' "$file" 2>/dev/null | head -1 | head -c 150)
  
  printf '{ category: "%s", title: "%s", url: "%s", date: "%s", excerpt: "%s" }' \
    "$category" "$title" "$url" "$date" "$excerpt"
}

echo "window.POSTS = [" > "$OUTPUT_FILE"

first=true
find "$CONTENTS_DIR" -name "*.html" | sort | while read -r file; do
  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> "$OUTPUT_FILE"
  fi
  generate_post_json "$file" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "];" >> "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE with $(grep -c '{ category' "$OUTPUT_FILE") posts"

cat > README.md << 'EOF'
# First Principles

Technical blog exploring software through first principles — not trending, but true.

## The Mindset

> "Question everything. Build from first principles."

We believe that deep understanding comes from breaking things down to fundamentals, not copying patterns without comprehension.

## Categories

EOF

for cat in contents/*/; do
  cat_name=$(basename "$cat")
  echo "" >> README.md
  echo "### $cat_name" >> README.md
  echo "" >> README.md
  for post in "$cat"*.html; do
    if [ -f "$post" ]; then
      title=$(basename "$post" .html)
      echo "- [$title]($post)" >> README.md
    fi
  done
done

echo "" >> README.md
echo "---" >> README.md

echo "Generated README.md"
echo "Done!"