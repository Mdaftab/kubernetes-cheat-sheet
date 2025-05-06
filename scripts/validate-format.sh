#!/bin/bash
# Script to validate troubleshooting guide format consistency

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "Validating format consistency across troubleshooting guides..."

# Get all markdown files excluding templates and README files
FILES=$(find ../troubleshooting -type f -name "*.md" | grep -v "README.md")

# Validation counters
VALID_FILES=0
INVALID_FILES=0

for file in $FILES; do
  ISSUES=0
  
  echo -e "\nChecking ${YELLOW}$file${NC}"
  
  # Check for required sections
  if ! grep -q "^# " "$file"; then
    echo -e "${RED}ERROR${NC}: Missing title (should start with '# ')"
    ISSUES=$((ISSUES+1))
  fi
  
  if ! grep -q "^## Overview" "$file"; then
    echo -e "${YELLOW}WARNING${NC}: Missing 'Overview' section"
    ISSUES=$((ISSUES+1))
  fi
  
  if ! grep -q "^## Quick Command Reference" "$file"; then
    echo -e "${RED}ERROR${NC}: Missing 'Quick Command Reference' section"
    ISSUES=$((ISSUES+1))
  fi
  
  # Check for command block
  if ! grep -q '```bash' "$file"; then
    echo -e "${RED}ERROR${NC}: Missing bash code blocks (should be wrapped in \`\`\`bash ... \`\`\`)"
    ISSUES=$((ISSUES+1))
  fi
  
  # Check for placeholder style consistency
  if grep -q '<[a-zA-Z_-]*[[:space:]][a-zA-Z_-]*>' "$file"; then
    echo -e "${YELLOW}WARNING${NC}: Placeholder with space found. Use kebab-case format <resource-name>"
    ISSUES=$((ISSUES+1))
  fi
  
  # Check for reminder to replace placeholders
  if ! grep -q -E "Remember to replace|Replace .* with actual values" "$file"; then
    echo -e "${YELLOW}WARNING${NC}: Missing reminder to replace placeholders"
    ISSUES=$((ISSUES+1))
  fi
  
  # Report file status
  if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓ File format is valid${NC}"
    VALID_FILES=$((VALID_FILES+1))
  else
    echo -e "${RED}✗ File has $ISSUES formatting issues${NC}"
    INVALID_FILES=$((INVALID_FILES+1))
  fi
done

# Print summary
echo -e "\n${YELLOW}==== Format Validation Summary ====${NC}"
echo -e "${GREEN}Valid files: $VALID_FILES${NC}"
echo -e "${RED}Files with issues: $INVALID_FILES${NC}"

if [ $INVALID_FILES -gt 0 ]; then
  echo -e "\nPlease fix the issues above to maintain consistent formatting."
  exit 1
else
  echo -e "\nAll files follow the required format. ✓"
  exit 0
fi