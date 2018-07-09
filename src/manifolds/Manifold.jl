#
#      Manifold -- a manifold defined via its data types:
#  * A point on the manifold, MPoint
#  * A point in an tangential space TVector
#
# Manopt.jl, R. Bergmann, 2018-06-26
import Base.LinAlg: norm, dot
import Base: exp, log, +, -, *, /, ==, show
# introcude new types
export Manifold, MPoint, TVector, MPointE, TVectorE
# introduce new functions
export distance, exp, log, norm, dot, manifoldDimension
export geodesic, midPoint, addNoise
export +, -, *, /, ==, show
export getValue, getBase, checkBase
# introcude new algorithms
doc"""
An abstract manifold $\mathcal M$ to keep global information on a specific manifold
"""
abstract type Manifold end

doc"""
An abstract point $x$ on a manifold $\mathcal M$.
"""
abstract type MPoint end

doc"""
A point on a tangent plane $T_x\mathcal M$ at a point $x$ on a
manifold $\mathcal M$.
"""
abstract type TVector end

# scale tangential vectors
*{T <: TVector}(ξ::T,s::Number)::T = T(s* getValue(ξ) )
*{T <: TVector}(s::Number, ξ::T)::T = T(s* getValue(ξ) )
*{T <: TVector}(ξ::Vector{T},s::Number)::T = [ξe*s for ξe in ξ]
*{T <: TVector}(s::Number, ξ::Vector{T}) = [s*ξe for ξe in ξ]
# /
/{T <: TVector}(ξ::T,s::Number)::T = T( getValue(ξ) ./s)
/{T <: TVector}(s::Number, ξ::T)::T = T(s./ getValue(ξ) )
/{T <: TVector}(ξ::Vector{T},s::Number) = [ξe/s for ξe in ξ]
/{T <: TVector}(s::Number, ξ::Vector{T}) = [s/ξe for ξe in ξ]
# + - of TVectors
function +{T <: TVector}(ξ::T,ν::T)
    return T( getValue(ξ) + getValue(ν) )
end
function -{T <: TVector}(ξ::T,ν::T)::T
    return T( getValue(ξ) - getValue(ν) )
end
# unary operators
-{T <: TVector}(ξ::T)::T = T(- getValue(ξ))
+{T <: TVector}(ξ::T)::T = T(getValue(ξ))

# compare Points & vectors
=={T <: MPoint}(x::T, y::T)::Bool = all(getValue(x) == getValue(y) )
=={T <: TVector}(ξ::T,ν::T)::Bool = (  all( getValue(ξ) == getValue(ν) )  )
#
#
# General functions available on manifolds based on exp/log/dist
#
#
"""
    midPoint(M,x,y)
Compute the (geodesic) mid point of x and y.
# Arguments
* `M` – a manifold
* `x`,`y` – two `MPoint`s on `M`
# Output
* `m` – resulting mid point
"""
function midPoint{mT <: Manifold, T <: MPoint}(M::mT,x::T, y::T)::T
  return exp(M,x,0.5*log(x,y))
end
"""
    geodesic(M,x,y)
return a function to evaluate the geodesic connecting `x` and `y`
on the manifold `M`.
"""
function geodesic{mT <: Manifold, T <: MPoint}(M::mT, x::T,y::T)::Function
  return (t::Float64 -> exp(M,x,t*log(M,x,y)))
end
"""
    geodesic(M,x,y,n)
returns vector containing the equispaced n sample-values along the geodesic
from `x`to `y` on the manifold `M`.
"""
function geodesic{mT <: Manifold, T <: MPoint}(M::mT, x::T,y::T,n::Integer)::Vector{T}
  geo = geodesic(M,x,y);
  return [geo(t) for t in linspace(0.,1.,n)]
end
"""
    geodesic(M,x,y,t)
returns the point along the geodesic from `x`to `y` given by the `t`(in [0,1]) on the manifold `M`
"""
geodesic{mT <: Manifold, T <: MPoint}(M::mT,x::T,y::T,t::Number)::T = geodesic(x,y)(t)
"""
    geodesic(M,x,y,T)
returns vector containing the MPoints along the geodesic from `x` to `y` on
the manfiold `M` specified by the points from the vector `T` (of numbers between 0 and 1).
"""
function geodesic{mT <: Manifold, P <: MPoint, S <: Number}(M::mT, x::P,y::P,T::Vector{S})::Vector{T}
  geo = geodesic(M,x,y);
  return [geo(t) for t in T]
end
#
#
# General documentation of exp/log/... and its fallbacks in case of non-implemented tuples
#
#
"""
    addNoise(M,x,σ)
adds noise of standard deviation `σ` to the MPoint `x` on the manifold `M`.
"""
function addNoise{mT <: Manifold, T <: MPoint}(M::mT,x::T,σ::Number)::T
  sig1 = string( typeof(x) )
  sig2 = string( typeof(σ) )
  sig3 = string( typeof(M) )
  throw( ErrorException(" addNoise – not Implemented for Point $sig1 and standard deviation of type $sig2 on the manifold $sig3.") )
end
"""
    distance(M,x,y)
computes the gedoesic distance between two points `x` and `y` on a manifold `M`.
"""
function distance{mT <: Manifold, T <: MPoint}(M::mT, x::T, y::T)::Number
  sig1 = string( typeof(x) )
  sig2 = string( typeof(y) )
  sig3 = string( typeof(M) )
  throw( ErrorException(" Distance – not Implemented for the two points $sig1 and $sig2 on the manifold $sig3." ) )
end
doc"""
    dot(M,ξ,ν)
  computes the inner product of two tangential vectors ξ and ν in TpM
  of p on the manifold `M`.
"""
function dot{mT <: Manifold, T <: TVector}(M::mT, ξ::T, ν::T)::Number
  sig1 = string( typeof(ξ) )
  sig2 = string( typeof(ν) )
  sig3 = string( typeof(M) )
  throw( ErrorException(" Dot – not Implemented for the two tangential vectors $sig1 and $sig2 on the manifold $sig3." ) )
end
doc"""
    exp(M,x,ξ)
computes the exponential map at `p` for the tangential vector `ξ`
on the manifold `M`.

# Optional Arguments
the standard values is given in brackets
* `t` : (1.0) shorten the tangent vector by the factor t
"""
function exp(M::mT, x::T, ξ::S,t::Number=1.0) where {mT<:Manifold, T<:MPoint, S<:TVector}
  sig1 = string( typeof(x) )
  sig2 = string( typeof(ξ) )
  sig3 = string( typeof(M) )
  throw( ErrorException(" Exp – not Implemented for Point $sig1 and tangential vector $sig2 on the manifold $sig3." ) )
end
"""
    getValue(x)
get the actual value representing the point `x` on a manifold.
This should be implemented if you do not use the field x.value to avoid the
try-catch in the fallback implementation.
"""
function getValue{P <: MPoint}(x::P)
    try
        return x.value
    catch
        sig1 = string( typeof(x) )
        throw( ErrorException("getValue – not implemented for manifold point $sig1.") );
    end
end
"""
    getValue(ξ)
get the actual value representing the tangent vector `ξ` to a manifold.
This should be implemented if you do not use the field ξ.value to avoid the
try-catch in the fallback implementation.
"""
function getValue{T <: TVector}(ξ::T)
    try
        return ξ.value
    catch
        sig1 = string( typeof(ξ) )
        throw( ErrorException("getValue – not implemented for tangent vector $sig1.") );
    end
end
"""
    log(M,x,y)
computes the tangential vector at x whose unit speed geodesic reaches y after
time T = `distance(M,x,y)` (note that the geodesic above is [0,1]
parametrized).
"""
function log{mT<:Manifold, T<:MPoint, S<:MPoint}(M::mT,x::T,y::S)::TVector
  sig1 = string( typeof(x) )
  sig2 = string( typeof(y) )
  sig3 = string( typeof(M) )
  throw( ErrorException(" Log – not Implemented for Points $sig1 and $sig2 on the manifold $sig3.") )
end
"""
    manifoldDimension(x)
returns the dimension of the manifold `M` the point `x` belongs to.
"""
function manifoldDimension{T<:MPoint}(x::T)::Integer
  sig1 = string( typeof(x) )
  throw( ErrorException(" Not Implemented for manifold points $sig1 " ) )
end
"""
    manifoldDimension(M)
returns the dimension of the manifold `M`.
"""
function manifoldDimension{T<:Manifold}(M::T)::Integer
  sig1 = string( typeof(M) )
  throw( ErrorException(" Not Implemented for manifold $sig1 " ) )
end
doc"""
    norm(M,x,ξ)
  computes the length of a tangential vector $\xi\in T_x\mathcal M$
"""
function norm{mT<:Manifold, T<: MPoint, S<:TVector}(M::mT,x::T,ξ::S)::Number
	sig1 = string( typeof(ξ) )
	sig2 = string( typeof(x) )
	sig3 = string( typeof(M) )
  throw( ErrorException("Norm - Not Implemented for types $sig1 in the tangent space of a $sig2 on the manifold $sig3" ) )
end
doc"""
    parallelTransport(M,x,y,,ξ)
Parallel transport of a vector `ξ` given at the tangent space $T_x\mathcal M$
of `x` to the tangent space $T_y\mathcal M$ at `y` along the geodesic form `x` to `y`.
If the geodesic is not unique, this function takes the same choice as `geodesic`.
"""
function parallelTransport{mT<:Manifold, P<:MPoint, Q<:MPoint, T<:TVector}(M::mT, x::P, y::Q, ξ::T)
  sig1 = string( typeof(x) )
  sig2 = string( typeof(y) )
  sig3 = string( typeof(ξ) )
  sig4 = string( typeof(M) )
  throw( ErrorException(" parallelTransport not implemented for Points $sig1 and $sig2, and a tangential vector $sig3 on the manifold $sig4." ) )
end
# The extended types for more information/security on base points of tangent vectors
# ---
"""
A decorator pattern based extension of TVector to additionally store the base
point. The decorator is then used to verify, that exp and dot are only called
with correct base points.
"""
struct TVectorE{T <: TVector, P <: MPoint} <: TVector
    vector::T
    base::P
    TVectorE{T,P}(ξ::T,x::P) where {T <: TVector, P <: MPoint} = new(ξ,x)
end
getValue{T <: TVectorE}(ξ::T) = getValue(ξ.vector)
"""
    getBase(ξ)
returns the base point of a tangent vector for the extended tangent vector.
"""
getBase{T <: TVectorE}(ξ::T) = getBase(ξ.base)
"""
A decorator pattern based extension of MPoint to identify when to switch
to the extended `TVectorE` for functions just working on points, e.g. `log`
"""
struct MPointE{P <: MPoint} <: MPoint
    base::P
    MPointE{P}(x::P) where {P <: MPoint} = new(x)
end
getValue{P <: MPointE}(x::P) = getValue( getBase(x) );
"""
    getBase(x)
returns the point this extended manifold point stores internally.
"""
getBase{P <: MPointE}(x::P) = x.base;

show(io::IO, ξ::TVectorE) = print(io, "$(ξ.value)_$(ξ.base)")
function +{T <: TVectorE}(ξ::T,ν::T)
    checkBase(ξ,ν)
    return T(ξ.value+ν.value,ξ.base)
end
function -{T <: TVectorE}(ξ::T,ν::T)::T
    checkBase(ξ,ν)
    return T(ξ.value-ν.value,ξ.base)
end
"""
    checkBase(ξ,ν)
checks, whether the base of two tangent vectors is identical, if both tangent
vectors are of type `TVectorE`. If one of them is not an extended vector, the
function returns true, expecting the tangent vector implicitly to be correct.
"""
function checkBase{T <: TVectorE}(ξ::T,ν::T)
    if getValue( getBase(ξ) ) != getValue( getBase(ν) )
        throw(
            ErrorException("The two tangent vectors $ξ and $ν do not have the same base.")
        );
    else
        return true;
    end
end
checkBase{T <: TVectorE, S <: TVector}(ξ::T,ν::S) = true
checkBase{T <: TVectorE, S <: TVector}(ξ::S,ν::T) = true
"""
    checkBase(ξ,x)
checks, whether the base of the tangent vector `ξ` is `x`. If `ξ` is not an
extended tangent vector `TVectorE` the function returns true, assuming the base
implicitly to be correct
"""
function checkBase{T <: TVectorE, P <: MPoint}(ξ::T,x::P)
    if getValue( getBase(ξ) ) != getValue(x)
        throw(
            ErrorException("The tangent vector $ξ is not from the tangent space of $x")
        );
    else
        return true;
    end
end
checkBase{T<: TVector, P<: MPoint}(ξ::T,x::P) = true
# unary operators
*{T <: TVectorE}(ξ::T,s::Number)::T = T(s*ξ.value,ξ.base)
*{T <: TVectorE}(s::Number, ξ::T)::T = T(s*ξ.value,ξ.base)
# /
/{T <: TVectorE}(ξ::T,s::Number)::T = T(ξ.value./s,ξ.base)
/{T <: TVectorE}(s::Number, ξ::T)::T = T(s./ξ.value,ξ.base)
-{T <: TVectorE}(ξ::T)::T = T(-ξ.value,ξ.base)
+{T <: TVectorE}(ξ::T)::T = T(ξ.value,ξ.base)

# compare extended vectors
=={T <: TVectorE}(ξ::T,ν::T)::Bool = ( checkBase(ξ,ν) && all(ξ.value==ν.value) )

# extended exp check base and return exp of value if that did not fail
exp{mT<:Manifold, T<:TVectorE, S<:MPointE}(M::mT,p::S,ξ::T)::T = exp(M.p.point,ξ)
function exp{mT<:Manifold, T<:TVectorE, S<:MPoint}(M::mT,p::S,ξ::T)::T
    checkBase(ξ,x);
    return exp(M,x,ξ.value);
end
# for extended vectors set the base to true
log{mT<:Manifold, P<:MPointE}(M::mT,x::P,y::P) = TVectorE(log(M,x,y),x);
log{mT<:Manifold, P<:MPointE, Q<:MPoint}(M::mT,x::P,y::Q) = TVectorE(log(M,x,y),x);
log{mT<:Manifold, P<:MPointE, Q<:MPoint}(M::mT,x::Q,y::P) = TVectorE(log(M,x,y),x);
# break down to inner if base
function dot{mT<:Manifold, T<:TVectorE}(M::mT,ξ::T,ν::T)::Float64
    checkBase()
    return dot(M,ξ.value,ν.value);
end
dot{mT<:Manifold, T<:TVectorE, S<:TVector}(M::mT,ξ::T,ν::S) = dot(M,ξ.value,ν);
dot{mT<:Manifold, T<:TVectorE, S<:TVector}(M::mT,ξ::S,ν::T) = dot(M,ξ.value,ν);
# break down to inner if base is checked
function norm{mT<:Manifold, T<:TVectorE}(M::mT,ξ::T,ν::T)::Float64
    checkBase()
    return norm(M,ξ.value,ν.value);
end
norm{mT<:Manifold, T<:TVectorE, S<:TVector}(M::mT,ξ::T,ν::S) = dot(M,ξ.value,ν);
norm{mT<:Manifold, T<:TVectorE, S<:TVector}(M::mT,ξ::S,ν::T) = dot(M,ξ.value,ν);
