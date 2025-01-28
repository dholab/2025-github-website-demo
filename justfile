@default:
    just --list

alias readme := make-readme

# Render the main quarto document `index.qmd`
render:
    quarto render index.qmd

make-readme:
    @quarto render setup.qmd --to gfm
    @mv docs/setup.md ./README.md
    @rm -rf docs
