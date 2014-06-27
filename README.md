# Earth

[![Build Status](https://travis-ci.org/lendle/Earth.jl.svg?branch=master)](https://travis-ci.org/lendle/Earth.jl)

This is a wrapper for the stand-alone version of R's [earth](
http://cran.r-project.org/web/packages/earth/) package.

## Installing

```
Pkg.clone("git@github.com:lendle/Earth.jl.git")
Pkg.build("Earth")
```

## Usage

[Ijulia notebook example](http://nbviewer.ipython.org/gist/lendle/68b746f2b08583c7dc38)

### `earth` function

Returns an object of type `EarthFit`

**Arguments**

* `x::VecOrMat{Float64}` - Vector or matrix of predictors. `size(x, 1)` is number of observations. `size(x, 2)` is number of predictors.
* `y::VecOrMat{Float64}` - Vector or matrix of outcomes. `size(y, 1)` is number of observations. `size(y, 2)` is number of outcomes.
* `WeightsArg = ones(size(x, 1))` - Vector of observation weights. Comments in the C code indicate that this may not do anything.
* `nMaxDegree = 1` - Maximum degree of interactions.
* `nMaxTerms = min(200, max(20, 2 * size(x, 2))) + 1` - Maximum number of model terms before pruning.
* `Penalty = (nMaxDegree > 1)? 3.0: 2.0` - Generalized Cross Validation (GCV) penalty per knot.
* `Thresh = 0.001` - Forward stepping threshold.
* `nMinSpan = 0` - Minimum distance between knots.
* `Prune = true` - Perform backwards pass?
* `nFastK = 20` - Maximum number of parent terms considered at each step of the forward pass.
* `FastBeta = 0.0` - Fast MARS aging coefficient, as described in the Fast MARS paper section 3.1.
* `NewVarPenalty = 0.0` - Penalty for adding a new variable in the forward pass.
* `LinPreds=zeros(Int32, size(x, 2))` - Index vector specifying which predictors should enter linearly, as in linear regression.  This does not say that a predictor _must_ enter the model; only that if it enters, it enters linearly.
* `UseBetaCache = false` - Using the “beta cache” takes more memory but is faster (by 20% and often much more for large models).
* `Trace = 0.0` - Set to higher values (up to 5.0?) for increasingly verbose output. Set to special value `1.5` for information about memory allocations.


See the [documentation](http://cran.r-project.org/web/packages/earth/earth.pdf) and [vignette](http://cran.r-project.org/web/packages/earth/vignettes/earth-notes.pdf) from the R package for details on the optional arguments, which may have slightly different names.

### `predict` function

Returns a matrix of predicted outcomes with one row per observation and one column per outcome variable.

**Arguments**

* `ef::EarthFit` - fitted earth object.
* `x::VecOrMat{Float64}` - Vector or matrix of (possibly new) predictors.

<!-- ### `print` function

`Base.print` is defined for `EarthFit` objects, which prints the coefficient and basis functions.
I'm just capturing the output of standalone-earth's `FormatEarth` function, and I may not be doing it in a safe way, so this may not always work. -->

### `modelmatrix` function

Given a vector or matrix of (possibly new) predictors, returns a matrix of MARS terms with a constant term in the first column.

**Arguments**

* `ef::EarthFit` - fitted earth object.
* `x::VecOrMat{Float64}` - Vector or matrix of (possibly new) predictors.
