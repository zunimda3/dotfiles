#!/usr/bin/env bash
set -euo pipefail

have() {
  command -v "$1" >/dev/null 2>&1
}

report() {
  local cmd="$1"
  local note="$2"

  if have "$cmd"; then
    printf '[ok]      %-12s %s\n' "$cmd" "$note"
  else
    printf '[missing] %-12s %s\n' "$cmd" "$note"
  fi
}

echo "42 environment check"
echo
echo "Usually already present on 42-style machines:"
if have cc || have clang; then
  printf '[ok]      %-12s %s\n' "cc/clang" "expected for the C curriculum"
else
  printf '[missing] %-12s %s\n' "cc/clang" "required for compilation-heavy work"
fi
report git "commonly present"
report curl "commonly present"
report tar "commonly present"
report unzip "commonly present"
report perl "needed for stow"
report make "commonly present"
if have yacc || have bison; then
  printf '[ok]      %-12s %s\n' "yacc/bison" "parser generator available"
else
  printf '[missing] %-12s %s\n' "yacc/bison" "may matter for source builds"
fi

echo
echo "Often missing or inconsistent on school machines:"
report cmake "needed only for full Neovim source builds"
report pkg-config "needed for many source builds"
report autoconf "needed for git-checkout source builds"
report automake "needed for git-checkout source builds"
report rg "needed for Telescope live grep"
report node "needed for markdown preview and some LSP tooling"
report npm "needed for markdown preview and some LSP tooling"
report python3 "needed for some Mason-managed tools"
report lazygit "optional, only for the <leader>lg mapping"

echo
echo "Recommendation:"
echo "- If the first block is mostly present, use ./bootstrap-portable-tools.sh"
echo "- If cmake/autotools/pkg-config are also present, ./bootstrap-source-tools.sh is fine"
echo "- If too much is missing, use a user-space fallback such as 42Homebrew"
