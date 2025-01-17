@doc raw"""
🏔️ Manopt.jl: optimization on Manifolds in Julia.

* 📚 Documentation: [manoptjl.org](https://manoptjl.org)
* 📦 Repository: [github.com/JuliaManifolds/Manopt.jl](https://github.com/JuliaManifolds/Manopt.jl)
* 💬 Discussions: [github.com/JuliaManifolds/Manopt.jl/discussions](https://github.com/JuliaManifolds/Manopt.jl/discussions)
* 🎯 Issues: [github.com/JuliaManifolds/Manopt.jl/issues](https://github.com/JuliaManifolds/Manopt.jl/issues)
"""
module Manopt

import Base: &, copy, getindex, identity, setindex!, show, |
import LinearAlgebra: reflect!
import ManifoldsBase: embed!

using ColorSchemes
using ColorTypes
using Colors
using DataStructures: CircularBuffer, capacity, length, push!, size, isfull
using Dates: Millisecond, Nanosecond, Period, canonicalize, value
using LinearAlgebra:
    Diagonal, I, eigen, eigvals, tril, Symmetric, dot, cholesky, eigmin, opnorm
using ManifoldDiff:
    adjoint_differential_log_argument,
    adjoint_differential_log_argument!,
    differential_exp_argument,
    differential_exp_argument!,
    differential_exp_basepoint,
    differential_exp_basepoint!,
    differential_log_argument,
    differential_log_argument!,
    differential_log_basepoint,
    differential_log_basepoint!,
    differential_shortest_geodesic_endpoint,
    differential_shortest_geodesic_endpoint!,
    differential_shortest_geodesic_startpoint,
    differential_shortest_geodesic_startpoint!,
    jacobi_field,
    jacobi_field!,
    riemannian_gradient,
    riemannian_gradient!,
    riemannian_Hessian,
    riemannian_Hessian!
using ManifoldsBase:
    AbstractBasis,
    AbstractDecoratorManifold,
    AbstractInverseRetractionMethod,
    AbstractManifold,
    AbstractPowerManifold,
    AbstractRetractionMethod,
    AbstractVectorTransportMethod,
    CachedBasis,
    DefaultManifold,
    DefaultOrthonormalBasis,
    DiagonalizingOrthonormalBasis,
    ExponentialRetraction,
    LogarithmicInverseRetraction,
    NestedPowerRepresentation,
    ParallelTransport,
    PowerManifold,
    ProductManifold,
    ProjectionTransport,
    QRRetraction,
    TangentSpace,
    ^,
    _read,
    _write,
    allocate,
    allocate_result,
    allocate_result_type,
    base_manifold,
    copy,
    copyto!,
    default_inverse_retraction_method,
    default_retraction_method,
    default_vector_transport_method,
    distance,
    embed,
    embed_project,
    embed_project!,
    exp,
    exp!,
    geodesic,
    get_basis,
    get_component,
    get_coordinates,
    get_coordinates!,
    get_embedding,
    get_iterator,
    get_vector,
    get_vector!,
    get_vectors,
    injectivity_radius,
    inner,
    inverse_retract,
    inverse_retract!,
    is_point,
    is_vector,
    log,
    log!,
    manifold_dimension,
    mid_point,
    mid_point!,
    norm,
    number_eltype,
    power_dimensions,
    project,
    project!,
    rand!,
    representation_size,
    requires_caching,
    retract,
    retract!,
    set_component!,
    shortest_geodesic,
    shortest_geodesic!,
    submanifold_components,
    vector_transport_to,
    vector_transport_to!,
    zero_vector,
    zero_vector!,
    ×,
    ℂ,
    ℝ
using Markdown
using Preferences:
    @load_preference, @set_preferences!, @has_preference, @delete_preferences!
using Printf
using Random: shuffle!, rand, randperm
using Requires
using SparseArrays
using Statistics: cor, cov, mean, std

include("plans/plan.jl")
# solvers general framework
include("solvers/solver.jl")
# specific solvers
include("solvers/adaptive_regularization_with_cubics.jl")
include("solvers/alternating_gradient_descent.jl")
include("solvers/augmented_Lagrangian_method.jl")
include("solvers/ChambollePock.jl")
include("solvers/conjugate_gradient_descent.jl")
include("solvers/cyclic_proximal_point.jl")
include("solvers/difference_of_convex_algorithm.jl")
include("solvers/difference-of-convex-proximal-point.jl")
include("solvers/DouglasRachford.jl")
include("solvers/exact_penalty_method.jl")
include("solvers/Lanczos.jl")
include("solvers/NelderMead.jl")
include("solvers/FrankWolfe.jl")
include("solvers/gradient_descent.jl")
include("solvers/LevenbergMarquardt.jl")
include("solvers/particle_swarm.jl")
include("solvers/primal_dual_semismooth_Newton.jl")
include("solvers/quasi_Newton.jl")
include("solvers/truncated_conjugate_gradient_descent.jl")
include("solvers/trust_regions.jl")
include("solvers/stochastic_gradient_descent.jl")
include("solvers/subgradient.jl")
include("solvers/debug_solver.jl")
include("solvers/record_solver.jl")
include("helpers/checks.jl")
include("helpers/exports/Asymptote.jl")
include("helpers/LineSearchesTypes.jl")
include("deprecated.jl")

"""
    Manopt.JuMP_Optimizer()

Creates a new optimizer object for the [MathOptInterface](https://jump.dev/MathOptInterface.jl/) (MOI).
An alias `Manopt.JuMP_Optimizer` is defined for convenience.

The minimization of a function `f(X)` of an array `X[1:n1,1:n2,...]`
over a manifold `M` starting at `X0`, can be modeled as follows:
```julia
using JuMP
model = Model(Manopt.JuMP_Optimizer)
@variable(model, X[i1=1:n1,i2=1:n2,...] in M, start = X0[i1,i2,...])
@objective(model, Min, f(X))
```
The optimizer assumes that `M` has a `Array` shape described
by `ManifoldsBase.representation_size`.
"""
global JuMP_Optimizer

"""
    struct VectorizedManifold{M} <: MOI.AbstractVectorSet
        manifold::M
    end

Representation of points of `manifold` as a vector of `R^n` where `n` is
`MOI.dimension(VectorizedManifold(manifold))`.
"""
global JuMP_VectorizedManifold

"""
    struct ArrayShape{N} <: JuMP.AbstractShape

Shape of an `Array{T,N}` of size `size`.
"""
global JuMP_ArrayShape

function __init__()
    #
    # Requires fallback for Julia < 1.9
    #
    @static if !isdefined(Base, :get_extension)
        @require JuMP = "4076af6c-e467-56ae-b986-b466b2749572" begin
            include("../ext/ManoptJuMPExt.jl")
        end
        @require Manifolds = "1cead3c2-87b3-11e9-0ccd-23c62b72b94e" begin
            include("../ext/ManoptManifoldsExt/ManoptManifoldsExt.jl")
        end
        @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
            include("../ext/ManoptPlotsExt/ManoptPlotsExt.jl")
        end
        @require LineSearches = "d3d80556-e9d4-5f37-9878-2ab0fcc64255" begin
            include("../ext/ManoptLineSearchesExt.jl")
        end
        @require LRUCache = "8ac3fa9e-de4c-5943-b1dc-09c6b5f20637" begin
            include("../ext/ManoptLRUCacheExt.jl")
        end
    end
    return nothing
end
#
# General
export ℝ, ℂ, &, |
export mid_point, mid_point!, reflect, reflect!
#
# Problems
export AbstractManoptProblem, DefaultManoptProblem, TwoManifoldProblem
#
# Objectives
export AbstractDecoratedManifoldObjective,
    AbstractManifoldGradientObjective,
    AbstractManifoldCostObjective,
    AbstractManifoldObjective,
    AbstractPrimalDualManifoldObjective,
    ConstrainedManifoldObjective,
    EmbeddedManifoldObjective,
    ManifoldCountObjective,
    NonlinearLeastSquaresObjective,
    ManifoldAlternatingGradientObjective,
    ManifoldCostGradientObjective,
    ManifoldCostObjective,
    ManifoldDifferenceOfConvexObjective,
    ManifoldDifferenceOfConvexProximalObjective,
    ManifoldGradientObjective,
    ManifoldHessianObjective,
    ManifoldProximalMapObjective,
    ManifoldStochasticGradientObjective,
    ManifoldSubgradientObjective,
    PrimalDualManifoldObjective,
    PrimalDualManifoldSemismoothNewtonObjective,
    SimpleManifoldCachedObjective,
    ManifoldCachedObjective
#
# Evaluation & Problems - old
export AbstractEvaluationType, AllocatingEvaluation, InplaceEvaluation, evaluation_type
#
# AbstractManoptSolverState
export AbstractGradientSolverState,
    AbstractHessianSolverState,
    AbstractManoptSolverState,
    AbstractPrimalDualSolverState,
    AdaptiveRegularizationState,
    AlternatingGradientDescentState,
    AugmentedLagrangianMethodState,
    ChambollePockState,
    ConjugateGradientDescentState,
    CyclicProximalPointState,
    DifferenceOfConvexState,
    DifferenceOfConvexProximalState,
    DouglasRachfordState,
    ExactPenaltyMethodState,
    FrankWolfeState,
    GradientDescentState,
    LanczosState,
    LevenbergMarquardtState,
    NelderMeadState,
    ParticleSwarmState,
    PrimalDualSemismoothNewtonState,
    RecordSolverState,
    StochasticGradientDescentState,
    SubGradientMethodState,
    TruncatedConjugateGradientState,
    TrustRegionsState

# Objectives and Costs
export NelderMeadSimplex
export AlternatingGradient
#
# access functions and helpers for `AbstractManoptSolverState`
export default_stepsize
export get_cost, get_gradient, get_gradient!
export get_subgradient, get_subgradient!
export get_subtrahend_gradient!, get_subtrahend_gradient
export get_proximal_map, get_proximal_map!
export get_state,
    get_initial_stepsize,
    get_iterate,
    get_gradients,
    get_gradients!,
    get_manifold,
    get_preconditioner,
    get_preconditioner!,
    get_primal_prox,
    get_primal_prox!,
    get_differential_primal_prox,
    get_differential_primal_prox!,
    get_dual_prox,
    get_dual_prox!,
    get_differential_dual_prox,
    get_differential_dual_prox!,
    set_gradient!,
    set_iterate!,
    set_manopt_parameter!,
    linearized_forward_operator,
    linearized_forward_operator!,
    adjoint_linearized_operator,
    adjoint_linearized_operator!,
    forward_operator,
    forward_operator!,
    get_objective
export get_hessian, get_hessian!
export ApproxHessianFiniteDifference
export is_state_decorator, dispatch_state_decorator
export primal_residual, dual_residual
export get_constraints,
    get_inequality_constraint,
    get_inequality_constraints,
    get_equality_constraint,
    get_equality_constraints,
    get_grad_inequality_constraint,
    get_grad_inequality_constraint!,
    get_grad_inequality_constraints,
    get_grad_inequality_constraints!,
    get_grad_equality_constraint,
    get_grad_equality_constraint!,
    get_grad_equality_constraints,
    get_grad_equality_constraints!
export ConstraintType, FunctionConstraint, VectorConstraint
# Subproblem cost/grad
export AugmentedLagrangianCost, AugmentedLagrangianGrad, ExactPenaltyCost, ExactPenaltyGrad
export ProximalDCCost, ProximalDCGrad, LinearizedDCCost, LinearizedDCGrad
export FrankWolfeCost, FrankWolfeGradient
export TrustRegionModelObjective

export QuasiNewtonState, QuasiNewtonLimitedMemoryDirectionUpdate
export QuasiNewtonMatrixDirectionUpdate
export QuasiNewtonCautiousDirectionUpdate,
    BFGS, InverseBFGS, DFP, InverseDFP, SR1, InverseSR1
export InverseBroyden, Broyden
export AbstractQuasiNewtonDirectionUpdate, AbstractQuasiNewtonUpdateRule
export WolfePowellLinesearch, WolfePowellBinaryLinesearch
export AbstractStateAction, StoreStateAction
export has_storage, get_storage, update_storage!
export objective_cache_factory
#
# Direction Update Rules
export DirectionUpdateRule,
    IdentityUpdateRule, StochasticGradient, AverageGradient, MomentumGradient, Nesterov
export DirectionUpdateRule,
    SteepestDirectionUpdateRule,
    HestenesStiefelCoefficient,
    FletcherReevesCoefficient,
    PolakRibiereCoefficient,
    ConjugateDescentCoefficient,
    LiuStoreyCoefficient,
    DaiYuanCoefficient,
    HagerZhangCoefficient,
    ConjugateGradientBealeRestart
#
# Solvers
export adaptive_regularization_with_cubics,
    adaptive_regularization_with_cubics!,
    alternating_gradient_descent,
    alternating_gradient_descent!,
    augmented_Lagrangian_method,
    augmented_Lagrangian_method!,
    ChambollePock,
    ChambollePock!,
    conjugate_gradient_descent,
    conjugate_gradient_descent!,
    cyclic_proximal_point,
    cyclic_proximal_point!,
    difference_of_convex_algorithm,
    difference_of_convex_algorithm!,
    difference_of_convex_proximal_point,
    difference_of_convex_proximal_point!,
    DouglasRachford,
    DouglasRachford!,
    exact_penalty_method,
    exact_penalty_method!,
    Frank_Wolfe_method,
    Frank_Wolfe_method!,
    gradient_descent,
    gradient_descent!,
    LevenbergMarquardt,
    LevenbergMarquardt!,
    NelderMead,
    NelderMead!,
    particle_swarm,
    particle_swarm!,
    primal_dual_semismooth_Newton,
    quasi_Newton,
    quasi_Newton!,
    stochastic_gradient_descent,
    stochastic_gradient_descent!,
    subgradient_method,
    subgradient_method!,
    truncated_conjugate_gradient_descent,
    truncated_conjugate_gradient_descent!,
    trust_regions,
    trust_regions!
# Solver helpers
export decorate_state!, decorate_objective!
export initialize_solver!, step_solver!, get_solver_result, stop_solver!
export solve!
export ApproxHessianFiniteDifference, ApproxHessianSymmetricRankOne, ApproxHessianBFGS
export update_hessian!, update_hessian_basis!
export ExactPenaltyCost, ExactPenaltyGrad, AugmentedLagrangianCost, AugmentedLagrangianGrad
export AdaptiveRagularizationWithCubicsModelObjective
export ExactPenaltyCost, ExactPenaltyGrad
export SmoothingTechnique, LinearQuadraticHuber, LogarithmicSumOfExponentials
#
# Stepsize
export Stepsize
export ArmijoLinesearch,
    ConstantStepsize, DecreasingStepsize, Linesearch, NonmonotoneLinesearch
export AdaptiveWNGradient
export get_stepsize, get_initial_stepsize, get_last_stepsize
#
# Stopping Criteria
export StoppingCriterion, StoppingCriterionSet
export StopAfter,
    StopAfterIteration,
    StopWhenResidualIsReducedByFactorOrPower,
    StopWhenAll,
    StopWhenAllLanczosVectorsUsed,
    StopWhenAny,
    StopWhenChangeLess,
    StopWhenCostLess,
    StopWhenCurvatureIsNegative,
    StopWhenEntryChangeLess,
    StopWhenGradientChangeLess,
    StopWhenGradientNormLess,
    StopWhenFirstOrderProgress,
    StopWhenModelIncreased,
    StopWhenPopulationConcentrated,
    StopWhenSmallerOrEqual,
    StopWhenStepsizeLess,
    StopWhenSubgradientNormLess,
    StopWhenTrustRegionIsExceeded
export get_active_stopping_criteria,
    get_stopping_criteria, get_reason, get_stopping_criterion
export update_stopping_criterion!
#
# Exports
export asymptote_export_S2_signals, asymptote_export_S2_data, asymptote_export_SPD
export render_asymptote
#
# Debugs
export DebugSolverState, DebugAction, DebugGroup, DebugEntry, DebugEntryChange, DebugEvery
export DebugChange,
    DebugGradientChange, DebugIterate, DebugIteration, DebugDivider, DebugTime
export DebugCost, DebugStoppingCriterion, DebugFactory, DebugActionFactory
export DebugGradient, DebugGradientNorm, DebugStepsize
export DebugPrimalBaseChange, DebugPrimalBaseIterate, DebugPrimalChange, DebugPrimalIterate
export DebugDualBaseChange, DebugDualBaseIterate, DebugDualChange, DebugDualIterate
export DebugDualResidual, DebugPrimalDualResidual, DebugPrimalResidual
export DebugProximalParameter, DebugWarnIfCostIncreases
export DebugGradient, DebugGradientNorm, DebugStepsize
export DebugWhenActive, DebugWarnIfFieldNotFinite, DebugIfEntry
export DebugWarnIfCostNotFinite, DebugWarnIfFieldNotFinite
export DebugWarnIfGradientNormTooLarge, DebugMessages
#
# Records - and access functions
export get_record, get_record_state, get_record_action, has_record
export RecordAction
export RecordActionFactory, RecordFactory
export RecordGroup, RecordEvery
export RecordChange, RecordCost, RecordIterate, RecordIteration
export RecordEntry, RecordEntryChange, RecordTime
export RecordGradient, RecordGradientNorm, RecordStepsize
export RecordPrimalBaseChange,
    RecordPrimalBaseIterate, RecordPrimalChange, RecordPrimalIterate
export RecordDualBaseChange, RecordDualBaseIterate, RecordDualChange, RecordDualIterate
export RecordProximalParameter
#
# Count
export get_count, reset_counters!
#
# Helpers
export check_gradient, check_differential, check_Hessian
end
