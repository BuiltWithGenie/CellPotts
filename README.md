## Stock inspector dashboard

Visualization of a Cellular Potts model built on top of the [CellularPotts.jl](https://github.com/RobertGregg/CellularPotts.jl) package.

## Installation

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```

## Usage

Open your browser and navigate to `http://localhost:8000/`
