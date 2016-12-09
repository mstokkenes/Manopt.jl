#
#      Sn - The manifold of the n-dimensional sphere
#  Point is a Point on the n-dimensional sphere.
#
export S1Point, S1TangentialPoint
export symRem
#
# TODO: It would be nice to have a fixed dimension here Sn here, however
#   they need N+1-dimensional vectors
#
immutable S1Point <: ManifoldPoint
  value::Number
  S1Point(value::Number) = new(value)
end

immutable S1TangentialPoint <: ManifoldTangentialPoint
  value::Number
  base::Nullable{S1Point}
  S1TangentialPoint(value::Number) = new(value,Nullable{S1Point}())
  S1TangentialPoint(value::Number,base::S1Point) = new(value,base)
  S1TangentialPoint(value::Number,base::Nullable{S1Point}) = new(value,base)
end

function addNoise(p::S1Point,σ::Real)::S1Point
  return S1Point(mod(p.value-pi+σ*randn(),2*pi)+pi)
end


function distance(p::S1Point,q::S1Point)::Number
  return abs( symRem(p.value-q.value) )
end

function dot(ξ::S1TangentialPoint, ν::S1TangentialPoint)::Number
  if sameBase(ξ,ν)
    return ξ.value*ν.value
  else
    throw(ErrorException("Can't compute dot product of two tangential vectors belonging to
      different tangential spaces."))
  end
end

function exp(p::S1Point,ξ::S1TangentialPoint,t::Number=1.0)::S1Point
  return S1Point(symRem(p.value+t*ξ.value))
end

function log(p::S1Point,q::S1Point,includeBase=false)::S1TangentialPoint
  if includeBase
    return S1TangentialPoint(symRem(q.value-p.value),p)
  else
    return S1TangentialPoint(symRem(q.value-p.value))
  end
end

function manifoldDimension(p::S1Point)::Integer
  return 1
end

function norm(ξ::S1TangentialPoint)::Number
  return abs(ξ.value)
end

function show(io::IO, m::S1Point)
    print(io, "S1($(m.value))")
end
function show(io::IO, ξ::S1TangentialPoint)
  if !isnull(ξ.base)
    print(io, "S1T_$(ξ.base.value)($(ξ.value))")
  else
    print(io, "S1T($(ξ.value))")
  end
end
#
#
# little Helpers
"""
    symRem(x,y,T=pi)
  symmetric remainder with respect to the interall 2*T
"""
function symRem(x::Number, T::Number=pi)::Number
  return (x+T)%(2*T) - T
end