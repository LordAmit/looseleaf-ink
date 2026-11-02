# Upstream

Source: https://github.com/kevintngo/looseleaf
Commit: 4bdb647940e2fefb3cebb394f3bad25c766a27d2
Ref given to sync: 4bdb647940e2fefb3cebb394f3bad25c766a27d2
Synced: 2026-11-02

Files taken from `src/lib/ink/`: builder, pen, pens, fills, shapes, geom, rng, noise, paint, types, textures,
textures.generated. Fonts from `public/fonts/`. Licence from `LICENSE`.

Changes made by `scripts/sync.sh`:
- import alias `@/lib/ink/x` rewritten to `./x`
- `textures-paper.generated.ts` replaced by an empty stub (paper tiles unused by strokes)
- nothing else is edited; `src/entry.ts`, `src/ink.css` and `src/banner.txt` are this repo's own

To see every difference: `git diff 4bdb647940e2fefb3cebb394f3bad25c766a27d2 -- src/lib/ink/` in a looseleaf clone against `src/` here.
