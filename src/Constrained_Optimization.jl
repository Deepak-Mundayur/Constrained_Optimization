module Constrained_Optimization

using HomotopyContinuation
using Plots
using LinearAlgebra

#using HomotopyOpt

#import HomotopyOpt: EDStep, ConstraintVariety

include("geometries.jl")
include("predictors.jl")
include("correctors.jl")
include("force_fields.jl")
include("track.jl")

export Point, single_step_under_force, point_move_under_force_field, motion_under_force_field_with_constraint
export gravity_force_field
export ambient_predictor, tangent_predictor
export hc_orthogonal_corrector, hc_parallel_corrector, ordinary_newton_corrector, moore_penrose_corrector, ed_retraction_corrector
export run_constrained_dynamics
export get_geometry_suite, run_and_analyze, make_attractor_force
export optimize
export matroid_collinearity_bounded_system, matroid_collinearity_system, make_bounded_repelling_force, make_repelling_points_force, run_and_animate_collinear_system  # matroid_bounded_points ,

end
