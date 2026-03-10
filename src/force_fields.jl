

# Define force field with correct signature
function gravity_force_field(x::Vector{Float64}, t::Float64)
    n = length(x)
    force_at_x = push!([0.0 for _ in 1:n-1], -1.0)  # Gravity in last component
    return force_at_x
end

# # Simulate
# initial_position = [0.0, 0.0]
# time = 2.0
# final_point = point_move_under_force_field(initial_position, gravity_force_field, time, dt=0.01, plot_trajectory=true)