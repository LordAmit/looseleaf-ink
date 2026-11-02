# looseleaf-ink

**Unofficial, standalone extraction of the ink core from [Looseleaf](https://github.com/kevintngo/looseleaf) by Kevin Ngo.**
Looseleaf is a React component library where every surface looks drawn with a pen. This repo takes only its drawing
engine, the pens, fills and shapes that turn geometry into hand-drawn SVG, and bundles it as one script with no React,
no components, and no bundled art. Everything in `src/` except `entry.ts`, `ink.css` and `banner.txt` is Looseleaf's
code, unchanged apart from import paths. `UPSTREAM.md` names the exact commit it was taken from and how to diff against it.

MIT License, same as Looseleaf. See `LICENSE` and `LICENSE-looseleaf`.

## Getting started

There is no npm package yet. Copy the built files into your project.

1. Get the files. Either clone this repo, or download `dist/` from it. You need `dist/ink.js` (or `dist/ink.esm.js`),
   `dist/ink.css`, and `dist/fonts/` if you want Kevin Sans. Copy them to, say, `vendor/` in your site.

2. Load them in your page:

   ```html
   <link rel="stylesheet" href="vendor/ink.css">
   <script src="vendor/ink.js"></script>
   ```

   `ink.css` defines the colour tokens (`--ll-ink`, `--ll-card`, and so on) and the Kevin Sans font faces. `ink.js`
   puts a global named `Ink` on the page. For modules, `import * as Ink from './vendor/ink.esm.js'` instead.

3. Inject the grain masks once, after the body exists. Strokes reference them for their pencil and felt texture:

   ```js
   document.body.insertAdjacentHTML('beforeend',
     `<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>${Ink.svgMaskDefs({kinds: Ink.GRAINS})}</defs></svg>`);
   ```

4. Draw behind an element. Give the element `position: relative`, put an absolutely positioned `<svg>` inside it at
   `z-index: -1`, and redraw whenever the element's size or state changes:

   ```js
   function inkify(el, draw, pad = 8) {
     const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
     svg.style.cssText = `position:absolute;inset:-${pad}px;width:calc(100% + ${2*pad}px);height:calc(100% + ${2*pad}px);z-index:-1;pointer-events:none;overflow:visible`;
     svg.setAttribute('aria-hidden', 'true');
     el.prepend(svg);
     const redraw = () => {
       const w = el.offsetWidth, h = el.offsetHeight; if (!w || !h) return;
       const ink = new Ink.Ink('seed-' + el.id, {tier: 'hi'});
       ink.layer('rest', () => draw(ink, w, h, el));
       const r = ink.toSvg({w, h, pad});
       svg.setAttribute('viewBox', Ink.inkViewBox(r));
       svg.innerHTML = r.svg;
     };
     new ResizeObserver(redraw).observe(el);
     new MutationObserver(redraw).observe(el, {attributes: true, attributeFilter: ['class']});
     redraw();
   }

   inkify(document.querySelector('.card'), (ink, w, h) => {
     const body = Ink.roundRectPoly(1, 1, w - 2, h - 2, 3);
     Ink.bandFill(ink, body, 'card', {alpha: .95});
     Ink.box(ink, 0, 0, w, h, {pen: 'ink', corner: 3});
   });
   ```

   The element needs `position: relative; isolation: isolate` so the SVG sits behind its own content and not behind
   the page.

5. See it working: `npm run example` and open http://localhost:8731/example/. The example page has recipes for a card,
   a message slip, a button, an input, and an arrow between two elements.

## What it does

You give it a width, a height and a seed. It gives you SVG that looks like a felt pen, a pencil, a marker or a
highlighter on paper. It knows nothing about HTML. You put the SVG behind whatever element you like.

```html
<link rel="stylesheet" href="dist/ink.css">
<script src="dist/ink.js"></script>
<script>
  // once: the grain masks the strokes reference
  document.body.insertAdjacentHTML('beforeend',
    `<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>${Ink.svgMaskDefs({kinds: Ink.GRAINS})}</defs></svg>`);

  // a card: pencil fill, soft wash, felt-pen outline
  const w = 320, h = 140, ink = new Ink.Ink('my-card', {tier: 'hi'});
  const body = Ink.roundRectPoly(1, 1, w - 2, h - 2, 3);
  ink.layer('rest', () => {
    Ink.bandFill(ink, body, 'card', {alpha: .95});
    Ink.wash(ink, body, 'paper-shade', {alpha: .3, inset: 6});
    Ink.box(ink, 0, 0, w, h, {pen: 'ink', corner: 3});
  });
  const r = ink.toSvg({w, h, pad: 8});
  svgElement.setAttribute('viewBox', Ink.inkViewBox(r));
  svgElement.innerHTML = r.svg;
</script>
```

Same seed, same drawing, every time. Redraw when the element resizes or changes state; a `ResizeObserver` and a
`MutationObserver` are enough. `example/index.html` shows a card, a message slip, a button, an input and an arrow.

## What is in the bundle

| export | purpose |
|---|---|
| `Ink` | the builder: `layer`, `stroke`, `poly`, `toSvg` |
| `box`, `dashedBox`, `loop`, `cloud`, `arrow`, `line`, `underline`, `strike`, `squiggle`, `bracket`, `check`, `cross`, `asterisk`, `star`, `spiral`, `burst`, `scribble`, `tally`, `focusRing` | shapes drawn with a pen |
| `bandFill`, `solidFill`, `wash`, `hatch`, `highlight`, `stipple`, `edgeBand`, `sweepFill`, `blobFill` | fills with pencil, marker or highlighter texture |
| `roundRectPoly`, `densifyClosed`, `offsetPoly` | geometry helpers |
| `pen`, `PENS` | pen specs: `ink`, `pencil`, `redfelt`, `blue`, `orange`, `hi`, and `.fine` / `.brush` variants |
| `svgMaskDefs`, `GRAINS` | the grain masks to inject once |
| `paint`, `PAINT_KEYS` | colour token names; values come from `ink.css` as `--ll-*` variables |

Colours are CSS variables, so a page restyles the ink by overriding `--ll-ink`, `--ll-card`, `--ll-red` and so on.

Sizes: `dist/ink.js` 145 KB, 92 KB gzipped. `dist/ink.esm.js` for `import`. Kevin Sans, the hand font, is 92 KB for
both weights and optional.

## What is not here

Looseleaf's React components, hooks and state layers. Its stickers, icons, doodles, mascot and charts. Its paper
texture tiles. If you want any of that, use Looseleaf itself.

## Updating from upstream

```sh
scripts/sync.sh            # latest main
scripts/sync.sh v1.2.0     # a tag or commit
```

The script clones Looseleaf at that ref, copies the core files, rewrites import paths, stubs the paper tiles, copies the
fonts and licence, writes `UPSTREAM.md` with the commit hash, and runs the build.

## Build

```sh
npm install
npm run build      # dist/ink.js, dist/ink.esm.js, dist/ink.css
npm run example    # http://localhost:8731/example/
```

## Credits

The drawing engine, the pens, the fills, the shapes and Kevin Sans are the work of Kevin Ngo and the Looseleaf
contributors. This repo only packages them.
