using Plots
using HomotopyContinuation
using LinearAlgebra

struct Point
    position::Vector{Float64}
    velocity::Vector{Float64}
end



function single_step_under_force(p,force,dt)
    velocity = p.velocity + force * dt
    position = p.position + p.velocity * dt
    return Point(position, velocity)
end

function point_move_under_force_field(initial_position::Vector{Float64}, force_field::Function, time::Float64; dt=0.01, plot_trajectory=true)
    p = Point(initial_position, zeros(length(initial_position)))
    
    # Collect trajectory data if plotting
    positions = plot_trajectory ? Vector{Vector{Float64}}() : nothing
    times = plot_trajectory ? Vector{Float64}() : nothing
    
    for t in 0:dt:time
        if plot_trajectory
            push!(positions, copy(p.position))
            push!(times, t)
        end
        force = force_field(p.position, t)
        p = single_step_under_force(p, force, dt)
    end
    
    # Plot trajectory if requested
    if plot_trajectory && length(positions) > 0
        x_coords = [pos[1] for pos in positions]
        y_coords = [pos[2] for pos in positions]
        plt = plot(x_coords, y_coords, label="Trajectory", marker=:circle, markersize=3, linewidth=2)
        display(plt)  # Explicitly display the plot
    end
    
    return p
end



function motion_under_force_field_with_constraint(initial_position::Vector{Float64}, force_field::Function, constraint_system::System, time::Float64; dt=0.01, plot_trajectory=true)
    n= length(initial_position)
    p = Point(initial_position, zeros(n))
    z = variables(constraint_system)
    constraint = expressions(constraint_system)
    ∇constraint = differentiate(constraint, variables(constraint_system))'

    #Constructing the Witness set system for projection
    @var λ, a[1:n]
    witness_eqns = vcat([z[i]-a[i] - λ*∇constraint[i] for i in 1:n], constraint)
    W = System(witness_eqns, variables = [z..., λ], parameters = a[1:n])

    a_0 = randn(Float64, n)
    full_sol = real_solutions(solve(W, target_parameters = a_0))[1]
    p_0 = full_sol[1:n]
    λ_0 = full_sol[end]
    current_solution = full_sol

    #Ourside points due to force
    temp_as = [Point(a_0, zeros(n))]
    p = Point(p_0, zeros(n))

    # Collect trajectory data if plotting
    positions = plot_trajectory ? Vector{Vector{Float64}}() : nothing
    times = plot_trajectory ? Vector{Float64}() : nothing

    for t in 0:dt:time
        if plot_trajectory
            push!(positions, copy(p.position))
            push!(times, t)
        end
        force = force_field(p.position, t)
        a_temp = single_step_under_force(p, force, dt)
        push!(temp_as, a_temp)

        # Projecting back to the constrained surface:
        result = solve(W, current_solution, target_parameters = vec(a_temp.position), start_parameters = vec(temp_as[end-1].position))
        new_full_sol = solutions(result)[1]
        position_new = new_full_sol[1:n]
        λ_new = new_full_sol[end]
        ∇constraint_p = evaluate(∇constraint, z=> p.position)
        n = ∇constraint_p / norm(∇constraint_p)  # Normal vector to the constraint surface at p
        P = I - n * n'  # Projection matrix onto the tangent space of the constraint surface
        velocity_new = P * p.velocity
        p = Point(position_new, velocity_new)
        current_solution = new_full_sol
    end

    # Plot trajectory if requested
    if plot_trajectory && length(positions) > 0
        x_coords = [pos[1] for pos in positions]
        y_coords = [pos[2] for pos in positions]
        plt = plot(x_coords, y_coords, label="Trajectory", marker=:circle, markersize=3, linewidth=2)
        display(plt)  # Explicitly display the plot
    end
    
    return p    
end
