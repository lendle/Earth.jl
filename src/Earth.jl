module Earth

const libearth = joinpath(Pkg.dir("Earth"), "deps", "libearth.so")

type EarthFit
  UsedCols::Vector{Int32}
  Dirs::Matrix{Int32}
  Cuts::Matrix{Float64}
  Betas::Matrix{Float64}
  nPreds::Int
  nResp::Int
  nTerms::Int
  nMaxTerms::Int
  BestGcv::Float64
end

function earth(x::Matrix{Float64}, y::Vector{Float64};
         WeightsArg = ones(size(x, 1)),
         nMaxDegree = 1,
         nMaxTerms = 21,
         Penalty = (nMaxDegree > 1)? 3.0: 2.0,
         Thresh = 0.001,
         nMinSpan = 0,
         Prune = true,
         nFastK = 20,
         FastBeta = 0.0,
         NewVarPenalty = 0.0,
         LinPreds=zeros(Int, size(x, 2)),
         UseBetaCache = false,
         Trace = 3.0
         )



  nCases = size(x, 1)
  nResp = size(y, 2)
  nPreds = size(x, 2)
  sPredNames = C_NULL

  pBestGcv = [0.0]
  pnTerms = [int32(-1)]
  BestSet = Array(Cint, nMaxTerms)
  bx = Array(Float64, nCases, nMaxTerms)
  Dirs = Array(Cint, nMaxTerms, nPreds)
  Cuts = Array(Float64, nMaxTerms, nPreds)
  Residuals = Array(Float64, nCases, nResp)
  Betas = Array(Float64, nMaxTerms, nResp)

  ccall((:Earth, libearth), Ptr{Void},
  (Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble},
   Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Cint, Cint, Cint, Cdouble, Cdouble, Cint, Bool,
   Cint, Cdouble, Cdouble, Ptr{Cint}, Cint, Cdouble, Ptr{Ptr{Cchar}}),
  pBestGcv, pnTerms, BestSet, bx, Dirs, Cuts, Residuals, Betas,
  x, y, WeightsArg, nCases, nResp, nPreds, nMaxDegree, nMaxTerms, Penalty, Thresh, nMinSpan, Prune,
  nFastK, FastBeta, NewVarPenalty, LinPreds, UseBetaCache, Trace, sPredNames)

  EarthFit(BestSet, Dirs, Cuts, Betas, nPreds, nResp, pnTerms[1], nMaxTerms, pBestGcv[1])

end

function predict(ef::EarthFit, x)
  yhat = [NaN]

  ccall((:PredictEarth, libearth), Ptr{Void},
        (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Cint, Cint),
        yhat, x, ef.UsedCols, ef.Dirs, ef.Cuts, ef.Betas, ef.nPreds, ef.nResp, ef.nTerms, ef.nMaxTerms)
  yhat[1]
end


end # module
