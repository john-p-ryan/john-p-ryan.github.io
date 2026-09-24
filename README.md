# john-p-ryan.github.io

Source for my personal website, live at [john-p-ryan.github.io](https://john-p-ryan.github.io).

The site is built with [Quarto](https://quarto.org) and served from the `docs/` folder via GitHub Pages.

## Layout

- `docs/_quarto.yml` — site config (navbar, footer, theme)
- `docs/custom.scss` — theme overrides on top of Bootswatch *cosmo* (fonts, colors, sidebar, paper/course entries)
- `docs/_profile.qmd` — sidebar profile card, included on every top-level page
- `docs/index.qmd`, `docs/research.qmd`, `docs/teaching.qmd` — the pages
- `docs/posts/` — news posts (shared settings in `posts/_metadata.yml`)
- `docs/files/` — CV, headshot, and course materials

## Building

```sh
cd docs
quarto render     # writes HTML in place (output-dir is ".")
quarto preview    # live preview while editing
```

Commit the rendered HTML alongside the source so GitHub Pages picks it up.

The `alt/` folder holds the previous Rmarkdown version of the site and is not built.
