module Constrained_Optimization

using HomotopyContinuation
using Plots
using LinearAlgebra

#using HomotopyOpt

import HomotopyOpt: EDStep, ConstraintVariety

include("geometries.jl")
include("predictors.jl")
include("correctors.jl")
include("force_fields.jl")
include("track.jl")

export Point, single_step_under_force, point_move_under_force_field, motion_under_force_field_with_constraint
export gravity_force_field
export ambient_predictor, tangent_predictor
export hc_orthogonal_corrector, hc_parallel_corrector, ordinary_newton_corrector, moore_penrose_corrector, homotopyopt_ed_corrector
export run_constrained_dynamics
export get_geometry_suite, run_and_analyze, make_attractor_force
export optimize

end
