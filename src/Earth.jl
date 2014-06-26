module Earth

using BinDeps
@BinDeps.load_dependencies

export earth, predict, EarthFit

type EarthFit
  UsedCols::Vector{Int32}
  Dirs::Matrix{Int32}
  Cuts::Matrix{Float64}
  Betas::Matrix{Float64}
  nPreds::Int32
  nResp::Int32
  nTerms::Int32
  nMaxTerms::Int32
  BestGcv::Float64
end

function earth(x::VecOrMat{Float64}, y::VecOrMat{Float64};
         WeightsArg = ones(size(x, 1)),
         nMaxDegree = 1,
         nMaxTerms = min(200, max(20, 2 * size(x, 2))) + 1,
         Penalty = (nMaxDegree > 1)? 3.0: 2.0,
         Thresh = 0.001,
         nMinSpan = 0,
         Prune = true,
         nFastK = 20,
         FastBeta = 0.0,
         NewVarPenalty = 0.0,
         LinPreds=zeros(Int32, size(x, 2)),
         UseBetaCache = false,
         Trace = 0.0
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

function predict_one_obs!(ef, onex, oney)
  ccall((:PredictEarth, libearth), Ptr{Void},
        (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Cint, Cint),
        oney, onex, ef.UsedCols, ef.Dirs, ef.Cuts, ef.Betas, ef.nPreds, ef.nResp, ef.nTerms, ef.nMaxTerms)
end

function predict(ef::EarthFit, x::VecOrMat)

  yhat = Array(Float64, size(x, 1), ef.nResp)

  onex = Array(Float64, size(x, 2))
  oney = Array(Float64, ef.nResp)

  for i in 1:size(x,1)
    onex[:] = x[i,:]
    predict_one_obs!(ef, onex, oney)
    yhat[i, :] = oney
  end

  yhat
end


function Base.print(io::IO, ef::EarthFit)
  flush_cstdio()
  originalSTDOUT = STDOUT
  (outRead, outWrite) = redirect_stdout()
  ccall((:FormatEarth, libearth), Ptr{Void},
    (Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Cint, Cint, Cint, Cdouble),
    ef.UsedCols, ef.Dirs, ef.Cuts, ef.Betas, ef.nPreds, ef.nResp, ef.nTerms, ef.nMaxTerms, 3, 0.0)
   flush_cstdio()
  str = readavailable(outRead)
  redirect_stdout(originalSTDOUT)
  print(io, str)
end


end # module
