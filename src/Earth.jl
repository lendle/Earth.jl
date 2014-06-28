module Earth

using BinDeps
@BinDeps.load_dependencies

export earth, predict, EarthFit, modelmatrix

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


# function Base.print(io::IO, ef::EarthFit)
#   flush_cstdio()
#   originalSTDOUT = STDOUT
#   (outRead, outWrite) = redirect_stdout()
#   ccall((:FormatEarth, libearth), Ptr{Void},
#     (Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Cint, Cint, Cint, Cdouble),
#     ef.UsedCols, ef.Dirs, ef.Cuts, ef.Betas, ef.nPreds, ef.nResp, ef.nTerms, ef.nMaxTerms, 3, 0.0)
#   flush_cstdio()

#   str = readavailable(outRead)
#   redirect_stdout(originalSTDOUT)
#   print(io, str)
# end

function Base.show(io::IO, ef::EarthFit)
  print(io, "EarthFit\nNumber of predictors: $(ef.nPreds)\nNumber of outcomes: $(ef.nResp)")
  print(io, "\nNumber of terms: $(ef.nTerms)\nMax terms: $(ef.nMaxTerms)\nBest GCV: $(ef.BestGcv)")
end

function modelmatrix(ef::EarthFit, x)
  mm = ones(Float64, size(x, 1), sum(ef.UsedCols[1:ef.nTerms]))
  iTerm1 = 1
  for iTerm in 2:ef.nTerms
    if ef.UsedCols[iTerm] == 1
      iTerm1 += 1
      for iPred in 1:ef.nPreds
        dir = ef.Dirs[iTerm, iPred]
        if dir == int32(-1)
          mm[:, iTerm1] .*= max(0.0, ef.Cuts[iTerm, iPred] .- x[:, iPred])
        elseif dir == int32(1)
          mm[:, iTerm1] .*= max(0.0, x[:, iPred] .- ef.Cuts[iTerm, iPred])
        elseif dir == int32(2)
          mm[:, iTerm1] .*= x[:, iPred]
        end
      end
    end
  end
  mm
end

end # module
