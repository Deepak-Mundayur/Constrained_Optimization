

# ==========================================
# 1. INTERNAL HELPER FUNCTIONS
# ==========================================

"""
Project a vector `v` onto the tangent space of the constraint variety at `pos`.
"""
function project_to_tangent(v, pos, H_system::System)
    Jx = jacobian(H_system, pos) 
    return v - pinv(Jx) * Jx * v
end

"""
Automatically builds ONLY the parametrized projection system.
"""
function build_projection_mechanics(H_system::System)
    vars = variables(H_system)
    H_expr = expressions(H_system)[1] 
    
    @var p[1:2]
    
    dH_dx1 = differentiate(H_expr, vars[1])
    dH_dx2 = differentiate(H_expr, vars[2])
    
    # Construct the perpendicularity condition (cross product = 0)
    perp_expr = (vars[1] - p[1]) * dH_dx2 - (vars[2] - p[2]) * dH_dx1
    
    F_system = System([H_expr, perp_expr], variables=vars, parameters=p)
    
    return F_system
end

"""
Plots the constraint variety V(H) = 0 natively using the System.
"""
function plot_variety(H_system::System, bounds=(-3.0, 3.0), pts=150)
    x_vals = range(bounds[1], bounds[2], length=pts)
    y_vals = range(bounds[1], bounds[2], length=pts)
    
    # A System is directly callable as a function in HC.jl
    z_vals = [real(H_system([x, y])[1]) for y in y_vals, x in x_vals]
    
    plt = contour(x_vals, y_vals, z_vals, levels=[0.0], 
                  color=:black, linewidth=2, legend=:outertopright, 
                  aspect_ratio=:equal, title="Constrained Dynamics Projection")
    return plt
end

# # ==========================================
# # 2. THE ALGORITHMS
# # ==========================================

# function algorithm_1_auto(pos_start, v_start, Force_field, dt, N_steps, H_system::System; show_plot=true)
#     F_system = build_projection_mechanics(H_system)

#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
    
#     plt = nothing
#     if show_plot
#         plt = plot_variety(H_system)
#         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=6, label="Start Point")
#     end

#     println("--- Starting Automated Algorithm 1 ---")
#     for i in 1:N_steps
#         current_force = Force_field(pos_bead)
#         v_bead = v_bead + current_force * dt
#         pos_temp = pos_bead + v_bead * dt

#         result = solve(
#             F_system, 
#             [pos_bead]; 
#             start_parameters = pos_bead, 
#             target_parameters = pos_temp, 
#             show_progress = false
#         )
        
#         tracked_sol = solutions(result)[1]
#         pos_bead = real.(tracked_sol)
        
#         # Just pass the original H_system directly to the tangent projection
#         v_bead = project_to_tangent(v_bead, pos_bead, H_system)

#         println("Step $i: Position = $pos_bead")
        
#         if show_plot
#             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:green, markersize=4, label= i==1 ? "Projected Points" : "")
#         end
#     end
    
#     if show_plot
#         display(plt)
#     end
    
#     return pos_bead, v_bead
# end


# function algorithm_2_auto(pos_start, v_start, Force_field, dt, N_steps, H_system::System; show_plot=true)
#     F_system = build_projection_mechanics(H_system)

#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
    
#     plt = nothing
#     if show_plot
#         plt = plot_variety(H_system)
#         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=6, label="Start Point")
#     end

#     println("\n--- Starting Automated Algorithm 2 ---")
#     for i in 1:N_steps
#         current_force = Force_field(pos_bead)
        
#         # Tangent projection using H_system natively
#         force_proj = project_to_tangent(current_force, pos_bead, H_system)
#         v_bead = v_bead + force_proj * dt
#         pos_temp = pos_bead + v_bead * dt

#         result = solve(
#             F_system, 
#             [pos_bead]; 
#             start_parameters = pos_bead, 
#             target_parameters = pos_temp, 
#             show_progress = false
#         )
        
#         tracked_sol = solutions(result)[1]
#         pos_bead = real.(tracked_sol)
#         v_bead = project_to_tangent(v_bead, pos_bead, H_system)

#         println("Step $i: Position = $pos_bead")
        
#         if show_plot
#             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:green, markersize=4, label= i==1 ? "Projected Points" : "")
#         end
#     end
    
#     if show_plot
#         display(plt)
#     end
    
#     return pos_bead, v_bead
# end

# # ==========================================
# # 3. CLEAN USER EXECUTION
# # ==========================================

# @var x[1:2]
# my_constraint_expr = x[1]^2 + x[2]^2 - 1.0
# my_constraint_system = System([my_constraint_expr], variables=x)

# Force_gravity(pos) = [0.0, -0.1]
# pos_0 = [cos(pi/4), sin(pi/4)]
# vel_0 = [0.0, 0.0]

# algorithm_1_auto(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, show_plot=true)
# algorithm_2_auto(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, show_plot=true)



############################################################################################################################



# ==========================================
# 2. THE ALGORITHMS (Now with GIF Animation)
# ==========================================

function algorithm_1(pos_start, v_start, Force_field, dt, N_steps, H_system::System; make_gif=true, filename="algo1.gif")
    F_system = build_projection_mechanics(H_system)

    pos_bead = float.(copy(pos_start))
    v_bead = float.(copy(v_start))
    
    plt = nothing
    anim = nothing
    if make_gif
        # Initialize the plot and the animation object
        plt = plot_variety(H_system)
        scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:red, markersize=6, label="Start Point", xlim = (-1.5, 1.5), ylim = (-1.5,1.5))
        anim = Animation()
        frame(anim, plt) # Capture the starting frame
    end

    println("--- Starting Algorithm 1 ---")
    for i in 1:N_steps
        current_force = Force_field(pos_bead)
        v_bead = v_bead + current_force * dt
        pos_temp = pos_bead + v_bead * dt

        if make_gif
        scatter!(plt, [pos_temp[1]], [pos_temp[2]], color=:green, markersize=4, label= i==1 ? "Projected Points" : "")
        frame(anim, plt)
        end

        result = solve(
            F_system, 
            [pos_bead]; 
            start_parameters = pos_bead, 
            target_parameters = pos_temp, 
            show_progress = false
        )
        
        tracked_sol = solutions(result)[1]
        pos_bead = real.(tracked_sol)
        
        v_bead = project_to_tangent(v_bead, pos_bead, H_system)

        println("Step $i: Position = $pos_bead")
        
        if make_gif
            # Plot the new point and capture the frame
            scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=4, label= i==1 ? "constrained Points" : "")
            frame(anim, plt)
        end
    end
    
    if make_gif
        # Compile and save the GIF at 5 frames per second
        gif(anim, filename, fps=5)
        println("Animation saved to: $filename")
    end
    
    return pos_bead, v_bead
end


function algorithm_2(pos_start, v_start, Force_field, dt, N_steps, H_system::System; make_gif=true, filename="algo2.gif")
    F_system = build_projection_mechanics(H_system)

    pos_bead = float.(copy(pos_start))
    v_bead = float.(copy(v_start))
    
    plt = nothing
    anim = nothing
    if make_gif
        plt = plot_variety(H_system)
        scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:red, markersize=6, label="Start Point", xlim = (-1.5, 1.5), ylim = (-1.5,1.5))
        anim = Animation()
        frame(anim, plt)
    end

    println("\n--- Starting Automated Algorithm 2 ---")
    for i in 1:N_steps
        current_force = Force_field(pos_bead)
        
        force_proj = project_to_tangent(current_force, pos_bead, H_system)
        v_bead = v_bead + force_proj * dt
        pos_temp = pos_bead + v_bead * dt

        if make_gif
        scatter!(plt, [pos_temp[1]], [pos_temp[2]], color=:green, markersize=4, label= i==1 ? "Projected Points" : "")
        frame(anim, plt)
        end

        result = solve(
            F_system, 
            [pos_bead]; 
            start_parameters = pos_bead, 
            target_parameters = pos_temp, 
            show_progress = false
        )
        
        tracked_sol = solutions(result)[1]
        pos_bead = real.(tracked_sol)
        v_bead = project_to_tangent(v_bead, pos_bead, H_system)

        println("Step $i: Position = $pos_bead")
        
        if make_gif
            scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=4, label= i==1 ? "Projected Points" : "")
            frame(anim, plt)
        end
    end
    
    if make_gif
        gif(anim, filename, fps=5)
        println("Animation saved to: $filename")
    end
    
    return pos_bead, v_bead
end

# ==========================================
# 3. CLEAN USER EXECUTION
# ==========================================

# @var x[1:2]
# my_constraint_expr = x[1]^2 + x[2]^2 - 1.0
# my_constraint_system = System([my_constraint_expr], variables=x)

# Force_gravity(pos) = [0.0, -0.1]
# pos_0 = [cos(pi/4), sin(pi/4)]
# vel_0 = [0.0, 0.0]

# # Run it and generate GIFs in your current working directory
# algorithm_1(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, make_gif=true, filename="dynamics_algo1.gif")
# algorithm_2(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, make_gif=true, filename="dynamics_algo2.gif")