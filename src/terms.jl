type Term
  preds::Vector{Int}
  dirs::Vector{Int}
  cuts::Vector{Float64}
end

Term() = Term(Int[], Int[], Float64[])

function Base.show(io::IO, t::Term)
  if length(t.dirs) == 0
    print(io, "(Intercept)")
  else
    for (i, d) in enumerate(t.dirs)
      if i > 1
        print(io, "×")
      end
      if d == 2
        print(io, "x$(t.preds[i])")
      elseif d==-1
        print(io, "max(0, ", @sprintf("%.3f", t.cuts[i]), " - x$(t.preds[i]))")
      elseif d==1
        print(io, "max(0, x$(t.preds[i]) - ", @sprintf("%.3f", t.cuts[i]), ")")
      end
    end
  end
end

function getterms(ef::EarthFit)
  terms = [Term()]
  for iTerm in 2:ef.nTerms
    if ef.UsedCols[iTerm] == 1
      idx = findn(ef.Dirs[iTerm, :])[2]
      push!(terms, Term(idx,
                        vec(ef.Dirs[iTerm, idx]),
                        vec(ef.Cuts[iTerm, idx])))
    end
  end
  terms
end

function calcterm(t::Term, x)
  b=ones(size(x,1))
  for i in 1:length(t.preds)
    if t.dirs[i] == 2
      b .*= x[:, t.preds[i]]
    elseif t.dirs[i] == -1
      b .*= max(0.0, t.cuts[i] .- x[:, t.preds[i]])
    elseif t.dirs[i] == 1
      b .*= max(0.0, x[:, t.preds[i]] .- t.cuts[i])
    end
  end
  b
end


function modelmatrix(terms::Vector{Term}, x)
  mm = ones(size(x, 1), length(terms))

  for i in 2:length(terms)
    mm[:, i] = calcterm(terms[i], x)
  end
  mm
end


