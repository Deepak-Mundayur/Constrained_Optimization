module Constrained_Optimization

using HomotopyContinuation
using Plots

include("force_directed_point.jl")
include("force_fields.jl")

export Point, single_step_under_force, point_move_under_force_field, motion_under_force_field_with_constraint
export gravity_force_field

end
