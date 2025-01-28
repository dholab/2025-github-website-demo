# Setting up this project


- [Setting up Quarto](#setting-up-quarto)
  - [Project-level configuration](#project-level-configuration)
  - [File-level controls](#file-level-controls)
- [Setting up python](#setting-up-python)
  - [Previewing our project](#previewing-our-project)
- [Setting up Git](#setting-up-git)
- [Setting up GitHub Actions](#setting-up-github-actions)
- [Parting words: iterating on this project](#parting-words-iterating-on-this-project)

## Setting up Quarto

First, we make sure [Quarto is installed](https://quarto.org/docs/get-started/), and then use it to create a project in the current working directory with `quarto project create`. This command is interactive and will guide you through creating the kind of project you want. In this case, the key point is that we want a website project to be created in the current working directory.

This will create a few files for use: the `_quarto.yml` file for whole-project configuration, the `index.qmd` file that will serve as the homepage and entrypoint for the website, and an `about.qmd` that will serve as an “About” page in a separate “tab” on the website. We also get a `styles.css` file, which provides some aesthetic tweaks to what would otherwise be raw, boring HTML.

> [!NOTE]
>
> ### HTML?
>
> The power of Quarto is that it allows you to write simple Markdown and then render it into very long list of other formats, e.g., PowerPoint, PDF, etc. Because we’re using it to make a website, Quarto will be rendering our markdown into HTML, which can then be viewed in the browser.

Before we proceed, let’s tweak our Quarto configuration a bit. We’ll do these tweaks at two levels: the whole-project level in `_quarto.yml`, and in what’s referred to as the frontmatter in each `.qmd` file.

### Project-level configuration

First, open the `_quarto.yml` in your favorite editor (VSCode, Positron, and RStudio have the best support for Quarto, though you can use any editor you can set to recognize `.qmd` files as Markdown). Start by modifying the top block with an additional setting: `output-dir: docs`.

<div class="code-with-filename">

**\_quarto.yml**

``` yaml
project:
  type: website
  output-dir: docs
```

</div>

Note that the YAML language is very sensitive about indentation, similar to Python. Make sure your editor has good auto-indentation support when modifying these files.

Next, we’ll modify the website block, which controls navigation and other website behaviors. In this case, I’m going to add a page by putting this `qmd` file in the list:

<div class="code-with-filename">

**\_quarto.yml**

``` yaml
website:
  title: "Creating Github-hosted Dashboards"
  navbar:
    left:
      - href: index.qmd
        text: Home
      - about.qmd
      - setup.qmd
```

</div>

We won’t touch the format section, but just note that that’s where we specify the theme we want applied to our HTML. Supported themes are really just named styles in the `styles.css` that was generated when we created the project. Finally, we’re going to add a section at the bottom that tells Quarto not to rerun code unless it has been updated:

<div class="code-with-filename">

**\_quarto.yml**

``` yaml
execute:
  freeze: auto
```

</div>

As the look and feel of our project comes together, we can expect to return to the `_quarto.yml`, but for now, that’s all we’ll need. There are a huge number of controls we can tweak, so I recommend keeping the [Quarto docs](https://quarto.org/docs/reference/) handy.

### File-level controls

Each `.qmd` has its own YAML-based configuration, which you’ll see in `index.qmd`. To demo some of the controls we can use, I modified my `index.qmd` frontmatter to the following:

<div class="code-with-filename">

**index.qmd**

``` yaml
---
title: "Creating Github-hosted Dashboards"
format:
    html:
        embed-resources: true
        keep-ipynb: false
author: 
    - name: Nick Minor
      orcid: 0000-0003-2929-8229
      email: nrminor@wisc.edu
      affiliation:
        - University of Wisconsin - Madison
        - Wisconsin National Primate Research Center
editor: source
jupyter: python3
---
```

</div>

We don’t actually need most of this–the key parts are telling it that we want to use the jupyter engine with Python, that we don’t need to keep the intermediate Jupyter representation after rendering, and that we don’t want our HTML to depend on external files. Instead, we want everything embedded into the HTML, which results in a larger HTML but also a simpler, more foolproof project structure.

Like with `_quarto.yml`, there are dozens of controls you can use here; if you need something, check the [docs](https://quarto.org/docs/reference/) for how to get it. Chances are, there’s a setting for it.

## Setting up python

That’s all we need to get Quarto working, but we still need to set up Python so that Quarto can run Python code. To do that, I’m going to use the inimitable [`uv`](https://docs.astral.sh/uv/) package manager. The best thing about `uv` is that it’s fast, *really* fast.

The second best thing is that it can, like Quarto itself, be configured with a single, declarative configuration file called `pyproject.toml`. This file is in the TOML language instead of YAML, but don’t worry; it should be similarly readable and relatively obvious in what it’s specifying. The `uv` team has gone to great lengths to make sure this file is compliant with Python-ecosystem standards, which gets rid of headaches you get with some other Python managers like [Poetry](https://python-poetry.org/). `uv` has tons of killer features and is one of the best things to happen to Python in a long time.

> [!NOTE]
>
> ### On `uv`
>
> Can you tell I love `uv`?

To get started, make sure you have [`uv` installed](https://docs.astral.sh/uv/getting-started/installation/), and then run `uv init --name quarto_dashboards --lib .`. This will create a project called `quarto-dashboards` in the current working directory that is a library rather than an executable. If and when our code gets too big to be viewed in our website, we can put it in our python library and import it in our Quarto python. Cool!

This will also generate a Python virtual environment and the aforementioned `pyproject.toml` for us. Now, let’s put some stuff in it! Our website will need a few things: the Jupyter engine, a Python kernel, and the labkey Python API, all of which are available on the [Python Package Index (PyPI)](https://pypi.org/) and are thus installable with `uv`. Just run `uv add jupyter ipykernel labkey` and then observe the following change in `pyproject.toml`:

<div class="code-with-filename">

**pyproject.toml**

``` toml
dependencies = [
    "ipykernel>=6.29.5",
    "jupyter>=1.1.1",
    "labkey>=3.3.0",
]
```

</div>

As you can see, we now have our dependencies locked with precise versions, which means our environment will be reproducible.

To get into our virtual environment, run `source .venv/bin/activate`. You will now have access to your dependencies.

> [!TIP]
>
> ### Pro-tip on shell aliases
>
> One of the ways `uv` is standards compliant is by using `source .venv/bin/activate`, which is used by many other Python environment managers. That said, it’s kind of verbose and ugly, a lot to type.
>
> Because I move in and out of Python environments a lot, I’ve placed a few aliases (shorthands) for this in the `.zshrc` file in my home directory, which is run every time I launch a new terminal window or tab:
>
> <div class="code-with-filename">
>
> **~/.zshrc**
>
> ``` zsh
> alias uvv='uv sync --all-extras && source .venv/bin/activate'
> alias uvs='uv sync --all-extras'
> alias a='source .venv/bin/activate'
> alias d='deactivate'
> ```
>
> </div>
>
> If you use `bash` and not `zsh`, placing these aliases in your `.bashrc` will work too.
>
> With that, you’ll be able to run `uvv` to sync and activate a virtual environment–three keystrokes instead of 50. So power, very efficiency.

### Previewing our project

With that, we have what we need to start working on our website. In a new terminal window, tab, or split, activate your virtual environment, and then run `quarto preview`. If we did everything above correctly, this will open a new browser window or tab with our rendered in-progress website for us. Every time we save changes to our `.qmd` file, the Quarto preview will see this and re-render our website. Amazing!

## Setting up Git

You may be tempted to get writing, but first, do your future self a favor and get your version control organized. The key to this will be your `.gitignore`. `.gitignore` files tell git (you guessed it) what to ignore. This is helpful, but these files can quickly become a Sisyphean task; the bigger your project gets, the more you have to add line after line after line of new things you have to ignore. This makes it easy to accidentally commit files you didn’t mean to.

Instead, we’re going to invert the logic of our `.gitignore` file: we’re going to use it to say ignore *everything* by default, and then only add a line for each *exception* to that rule. This means we’ll only ever be able to stage and commit files and directories that we’ve explicitly allowed in our `.gitignore`. Inverting your logic means more work up front, of course, but your future self will thank you.

This method results in a `.gitignore` that looks like this at the time of this writing:

<div class="code-with-filename">

**.gitignore**

``` txt
*

# project root exceptions
!.gitignore
!justfile
!_quarto.yml
!about.qmd
!index.qmd
!setup.qmd
!styles.css
!pyproject.toml
!uv.lock
!README.md
!LICENSE
!.python-version

# python library code
!/src
!/src/quarto_dashboards
!/src/**/*.py

# github workflows
!/.github
!/.github/workflows
!/.github/workflows/*.yml
!/.github/workflows/*.yaml
```

</div>

You’ll see ignoring everything is as simple as starting the file with `*`, the glob wildcard for anything. Then, for each directory and file we want to allow, we prepend the path with a bang `!`, which is the not operator.

We only allow Quarto project files, `uv` project files, python scripts from our library, and GitHub workflows we’ll eventually write. With this setup, we’ll never accidentally push Jupyter notebooks, JavaScript files Quarto generates, etc.

Now, just run `git init` in your terminal and have at it.

## Setting up GitHub Actions

Rather than rendering our website itself, we’re going to use GitHub to do that for us. To do so, we’re going to return to YAML and put together some workflows. The overall architecture here will be:

1.  Leave our current project setup in a main git branch.
2.  Use a new branch called `gh-pages` to actually render the website files.
3.  Use GitHub pages to host the files output into the `docs` directory in our `gh-pages` branch.
4.  Make sure GitHub re-renders our website whenever changes are pushed to the `main` branch.

Conveniently, the Quarto developers anticipated this use case and wrote [a very helpful tutorial for it](https://quarto.org/docs/publishing/github-pages.html#publish-action), which I’ll partially reproduce here.

The first thing we need to do is set up a “remote”, which is to say a repository on GiHub that we can sync with this project. To do so, I went to the [`dholab` GitHub org](https://github.com/dholab), hit the green new button, and made a repo called “2025-github-website-demo”. I then staged all the files allowed in `.gitignore`, committed them, and then ran the following to set that repo as our remote

``` bash
git branch -M main
git remote add origin https://github.com/dholab/2025-github-website-demo.git
git push -u origin main
```

With that, the rest is extremely simple: run `quarto publish gh-pages`, which will create the `gh-pages` branch and plug it into a `.github.io` site, and then paste the following Github workflow into the main branch:

<div class="code-with-filename">

**.github/workflows/publish.yml**

``` yaml
on:
  workflow_dispatch:
  push:
    branches: [main]

name: Quarto Publish

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Set up Quarto
        uses: quarto-dev/quarto-actions/setup@v2

      - name: Install uv
        uses: astral-sh/setup-uv@v5

      - name: "Set up Python"
        uses: actions/setup-python@v5
        with:
          python-version-file: ".python-version"
        
      - name: Install the project
        run: uv sync --all-extras --dev

      - name: Render and Publish from local venv
        run: |
          source .venv/bin/activate
          git config --global user.name 'GitHub Actions Bot'
          git config --global user.email 'actions@github.com'
          quarto publish gh-pages --no-browser
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Define a cache dependency glob
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true
          cache-dependency-glob: "uv.lock"
```

</div>

This workflow, adapted from the above Quarto tutorial plus [the `uv` docs](https://docs.astral.sh/uv/guides/integration/github/#using-uv-in-github-actions), essentially replicates what we’ve done above, except with the benefit of a previously created `uv` environment (that’s what `uv.lock` records).

## Parting words: iterating on this project

With everything set up, I recommend the following workflow for iterating on this project:

1.  Whenever you starting making changes, make sure you have `quarto preview` running within the python environment. That way, you can keep an eye on the rendered project as you update you `.qmd` and Python code.
2.  If you have [just](https://just.systems/) installed, run `just readme` whenever you update `setup.qmd`. This keeps the repo readme up to date.
3.  Be sure to use `uv add` to record any dependencies throughout your Python or `.qmd` files. Likewise for allowing new files to be git-tracked by adding explicit exceptions to `.gitignore`.
4.  For adding Python, start with putting code into blocks in your `.qmd` files. When that code starts to get a bit large, e.g. \>20 lines, consider placing it in our library and importing it as a function instead.
