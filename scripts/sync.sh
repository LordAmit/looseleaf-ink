#!/bin/sh
# Extract Looseleaf's ink core into src/, record the upstream commit, and build dist/.
# Usage: scripts/sync.sh [ref]   (a looseleaf branch, tag, or commit; default main)
set -eu
REF="${1:-main}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git init -q "$TMP"
git -C "$TMP" remote add origin https://github.com/kevintngo/looseleaf.git
git -C "$TMP" fetch -q --depth 1 origin "$REF"
git -C "$TMP" checkout -q FETCH_HEAD
HASH="$(git -C "$TMP" rev-parse HEAD)"
UP="$TMP/src/lib/ink"

# 1. The core: everything the pens, fills and shapes need. No React, no art, no recipes.
for f in builder pen pens fills shapes geom rng noise paint types textures textures.generated; do
  cp "$UP/$f.ts" "$ROOT/src/$f.ts"
done

# 2. Import paths: '@/lib/ink/x' becomes './x'.
for f in "$ROOT"/src/*.ts; do
  case "$f" in *entry.ts) continue;; esac
  sed -i.bak -E "s#from '@/lib/ink/([a-z.-]+)'#from './\1'#g; s#from \"@/lib/ink/([a-z.-]+)\"#from './\1'#g" "$f" && rm -f "$f.bak"
done

# 3. Paper texture tiles (180 KB of data URIs) are not used by strokes; stub them out.
cat > "$ROOT/src/textures-paper.generated.ts" <<'STUB'
// Stub written by scripts/sync.sh: the paper tiles are not needed for strokes and fills.
export const PAPER_TILES = {} as any, PAPER_RELIEF = {} as any, PAPER_SLIP = {} as any, PAPER_FIBRE = {} as any, PAPER_CLOUD = {} as any, PAPER_LINEN = {} as any, PAPER_KRAFT = {} as any
export type PaperTile = any
export type PaperTileName = string
STUB

# 4. Fonts and licence.
mkdir -p "$ROOT/dist/fonts"
cp "$TMP/public/fonts/KevinSans-Regular.woff2" "$TMP/public/fonts/KevinSans-Bold.woff2" "$ROOT/dist/fonts/"
cp "$TMP/LICENSE" "$ROOT/LICENSE-looseleaf"

# 5. Record where this came from.
cat > "$ROOT/UPSTREAM.md" <<MD
# Upstream

Source: https://github.com/kevintngo/looseleaf
Commit: $HASH
Ref given to sync: $REF
Synced: $(date -u +%Y-%m-%d)

Files taken from \`src/lib/ink/\`: builder, pen, pens, fills, shapes, geom, rng, noise, paint, types, textures,
textures.generated. Fonts from \`public/fonts/\`. Licence from \`LICENSE\`.

Changes made by \`scripts/sync.sh\`:
- import alias \`@/lib/ink/x\` rewritten to \`./x\`
- \`textures-paper.generated.ts\` replaced by an empty stub (paper tiles unused by strokes)
- nothing else is edited; \`src/entry.ts\`, \`src/ink.css\` and \`src/banner.txt\` are this repo's own

To see every difference: \`git diff $HASH -- src/lib/ink/\` in a looseleaf clone against \`src/\` here.
MD

echo "synced looseleaf@$HASH"
cd "$ROOT" && npm run --silent build
