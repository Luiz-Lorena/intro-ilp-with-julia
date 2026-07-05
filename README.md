# "Introduction to Integer Programming and Applications with Julia"

This repository contains the Jupyter notebooks accompanying the book [*Introduction to Integer Programming and Applications with Julia*](https://github.com/Luiz-Lorena/intro-ilp-with-julia/blob/main/docs/intro-ilp-julia.pdf).

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21166419.svg)](https://doi.org/10.5281/zenodo.21166419)

## How to cite the book

This repository is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) license.

You may:
- Share
- Adapt
- Use commercially

Provided you properly credit the authors. If you use this book, please cite it as follows.

```bibtex
  @book{LorenaEtAl2026,
    title = {
      Introduction to Integer Programming and Applications with Julia
    },
    author = {
      Lorena, Luiz Antonio Nogueira and
      Lorena, Luiz Henrique Nogueira and
      Chaves, Ant{\\^o}nio Augusto
    },
    year = {2026},
    doi = {https://doi.org/10.5281/zenodo.21166419},
    url = {https://github.com/Luiz-Lorena/intro-ilp-with-julia}
  }
```

## Getting Started & Installing Packages

Because this repository includes `Project.toml` and `Manifest.toml` files, you can exactly replicate the environment used to write these notebooks. Follow these steps to set up and run the code:

### 1. Clone the Repository

```bash
git clone https://github.com/Luiz-Lorena/intro-ilp-with-julia-notebooks.git
cd intro-ilp-with-julia-notebooks
```

### 2. Instantiate the environment

Open Julia in your terminal within the project root folder and run the following commands to download and install all the required packages:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

### 3. Run the Notebooks 

If you want to use Jupyter, import IJulia and launch it:

```julia
using IJulia
notebook()
```

If you want to use Visual Studio Code, install the [Julia extension](https://code.visualstudio.com/docs/languages/julia).

## Chapter Examples

Each notebook follows the corresponding chapter and reproduces the examples presented in the text. Whether you are reading the book sequentially or looking for a specific topic, the table below provides quick access to the relevant notebook.

| Notebook         | Description                       |
| ---------------- | --------------------------------- |
| [chapter1.ipynb](examples/chapter1/chapter1.ipynb) | Introduction to Integer Programming  |
| [chapter2.ipynb](examples/chapter2/chapter2.ipynb) | Knapsack Problems     |
| [chapter3.ipynb](examples/chapter3/chapter3.ipynb) | Location Problems  |
| [chapter4.ipynb](examples/chapter4/chapter4.ipynb) | Traveling Salesman Problem |
| [chapter5.ipynb](examples/chapter5/chapter5.ipynb) | Graph Problems |
| [chapter6.ipynb](examples/chapter6/chapter6.ipynb) | Column Generation |
| [chapter7.ipynb](examples/chapter7/chapter7.ipynb) | Lagrangian Relaxation |
| [appendixA.ipynb](examples/appendixA/appendixA.ipynb) | Julia Introduction |

## Chapter Exercises

The exercises are included to help readers explore the concepts further.

| Notebook         | Description                       |
| ---------------- | --------------------------------- |
| [chapter1.ipynb](exercises/chapter1/chapter1.ipynb) | Introduction to Integer Programming  |
| [chapter2.ipynb](exercises/chapter2/chapter2.ipynb) | Knapsack Problems     |
| [chapter3.ipynb](exercises/chapter3/chapter3.ipynb) | Location Problems  |
| [chapter4.ipynb](exercises/chapter4/chapter4.ipynb) | Traveling Salesman Problem |
| [chapter5.ipynb](exercises/chapter5/chapter5.ipynb) | Graph Problems |
| [chapter6.ipynb](exercises/chapter6/chapter6.ipynb) | Column Generation |
| [chapter7.ipynb](exercises/chapter7/chapter7.ipynb) | Lagrangian Relaxation |
| [chapter8.ipynb](exercises/chapter8/chapter8.ipynb) | Branch-and-Bound |
