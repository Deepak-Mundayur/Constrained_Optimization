

# # ==========================================
# # 1. INTERNAL HELPER FUNCTIONS
# # ==========================================

# """
# Project a vector `v` onto the tangent space of the constraint variety at `pos`.
# """
# function project_to_tangent(v, pos, H_system::System)
#     Jx = jacobian(H_system, pos) 
#     return v - pinv(Jx) * Jx * v
# end

# """
# Automatically builds ONLY the parametrized projection system.
# """
# function build_projection_mechanics(H_system::System)
#     vars = variables(H_system)
#     H_expr = expressions(H_system)[1] 
    
#     @var p[1:2]
    
#     dH_dx1 = differentiate(H_expr, vars[1])
#     dH_dx2 = differentiate(H_expr, vars[2])
    
#     # Construct the perpendicularity condition (cross product = 0)
#     perp_expr = (vars[1] - p[1]) * dH_dx2 - (vars[2] - p[2]) * dH_dx1
    
#     F_system = System([H_expr, perp_expr], variables=vars, parameters=p)
    
#     return F_system
# end

# """
# Plots the constraint variety V(H) = 0 natively using the System.
# """
# function plot_variety(H_system::System, bounds=(-3.0, 3.0), pts=150)
#     x_vals = range(bounds[1], bounds[2], length=pts)
#     y_vals = range(bounds[1], bounds[2], length=pts)
    
#     # A System is directly callable as a function in HC.jl
#     z_vals = [real(H_system([x, y])[1]) for y in y_vals, x in x_vals]
    
#     plt = contour(x_vals, y_vals, z_vals, levels=[0.0], 
#                   color=:black, linewidth=2, legend=:outertopright, 
#                   aspect_ratio=:equal, title="Constrained Dynamics Projection")
#     return plt
# end

# # # ==========================================
# # # 2. THE ALGORITHMS
# # # ==========================================

# # function algorithm_1_auto(pos_start, v_start, Force_field, dt, N_steps, H_system::System; show_plot=true)
# #     F_system = build_projection_mechanics(H_system)

# #     pos_bead = float.(copy(pos_start))
# #     v_bead = float.(copy(v_start))
    
# #     plt = nothing
# #     if show_plot
# #         plt = plot_variety(H_system)
# #         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=6, label="Start Point")
# #     end

# #     println("--- Starting Automated Algorithm 1 ---")
# #     for i in 1:N_steps
# #         current_force = Force_field(pos_bead)
# #         v_bead = v_bead + current_force * dt
# #         pos_temp = pos_bead + v_bead * dt

# #         result = solve(
# #             F_system, 
# #             [pos_bead]; 
# #             start_parameters = pos_bead, 
# #             target_parameters = pos_temp, 
# #             show_progress = false
# #         )
        
# #         tracked_sol = solutions(result)[1]
# #         pos_bead = real.(tracked_sol)
        
# #         # Just pass the original H_system directly to the tangent projection
# #         v_bead = project_to_tangent(v_bead, pos_bead, H_system)

# #         println("Step $i: Position = $pos_bead")
        
# #         if show_plot
# #             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:green, markersize=4, label= i==1 ? "Projected Points" : "")
# #         end
# #     end
    
# #     if show_plot
# #         display(plt)
# #     end
    
# #     return pos_bead, v_bead
# # end


# # function algorithm_2_auto(pos_start, v_start, Force_field, dt, N_steps, H_system::System; show_plot=true)
# #     F_system = build_projection_mechanics(H_system)

# #     pos_bead = float.(copy(pos_start))
# #     v_bead = float.(copy(v_start))
    
# #     plt = nothing
# #     if show_plot
# #         plt = plot_variety(H_system)
# #         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=6, label="Start Point")
# #     end

# #     println("\n--- Starting Automated Algorithm 2 ---")
# #     for i in 1:N_steps
# #         current_force = Force_field(pos_bead)
        
# #         # Tangent projection using H_system natively
# #         force_proj = project_to_tangent(current_force, pos_bead, H_system)
# #         v_bead = v_bead + force_proj * dt
# #         pos_temp = pos_bead + v_bead * dt

# #         result = solve(
# #             F_system, 
# #             [pos_bead]; 
# #             start_parameters = pos_bead, 
# #             target_parameters = pos_temp, 
# #             show_progress = false
# #         )
        
# #         tracked_sol = solutions(result)[1]
# #         pos_bead = real.(tracked_sol)
# #         v_bead = project_to_tangent(v_bead, pos_bead, H_system)

# #         println("Step $i: Position = $pos_bead")
        
# #         if show_plot
# #             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:green, markersize=4, label= i==1 ? "Projected Points" : "")
# #         end
# #     end
    
# #     if show_plot
# #         display(plt)
# #     end
    
# #     return pos_bead, v_bead
# # end

# # # ==========================================
# # # 3. CLEAN USER EXECUTION
# # # ==========================================

# # @var x[1:2]
# # my_constraint_expr = x[1]^2 + x[2]^2 - 1.0
# # my_constraint_system = System([my_constraint_expr], variables=x)

# # Force_gravity(pos) = [0.0, -0.1]
# # pos_0 = [cos(pi/4), sin(pi/4)]
# # vel_0 = [0.0, 0.0]

# # algorithm_1_auto(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, show_plot=true)
# # algorithm_2_auto(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, show_plot=true)



# ############################################################################################################################



# # ==========================================
# # 2. THE ALGORITHMS (Now with GIF Animation)
# # ==========================================

# function algorithm_1(pos_start, v_start, Force_field, dt, N_steps, H_system::System; make_gif=true, filename="algo1.gif")
#     F_system = build_projection_mechanics(H_system)

#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
    
#     plt = nothing
#     anim = nothing
#     if make_gif
#         # Initialize the plot and the animation object
#         plt = plot_variety(H_system)
#         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:red, markersize=6, label="Start Point", xlim = (-2.0, 2.0), ylim = (-2.0,2.0))
#         anim = Animation()
#         frame(anim, plt) # Capture the starting frame
#     end

#     println("--- Starting Algorithm 1 ---")
#     for i in 1:N_steps
#         current_force = Force_field(pos_bead)
#         v_bead = v_bead + current_force * dt
#         pos_temp = pos_bead + v_bead * dt

#         if make_gif
#         scatter!(plt, [pos_temp[1]], [pos_temp[2]], color=:green, markersize=4, label= i==1 ? "Points after force is applied" : "")
#         frame(anim, plt)
#         end

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
        
#         if make_gif
#             # Plot the new point and capture the frame
#             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=4, label= i==1 ? "constrained Points" : "")
#             frame(anim, plt)
#         end
#     end
    
#     if make_gif
#         # Compile and save the GIF at 5 frames per second
#         gif(anim, filename, fps=5)
#         println("Animation saved to: $filename")
#     end
    
#     return pos_bead, v_bead
# end


# function algorithm_2(pos_start, v_start, Force_field, dt, N_steps, H_system::System; make_gif=true, filename="algo2.gif")
#     F_system = build_projection_mechanics(H_system)

#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
    
#     plt = nothing
#     anim = nothing
#     if make_gif
#         plt = plot_variety(H_system)
#         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:red, markersize=6, label="Start Point", xlim = (-1.5, 1.5), ylim = (-1.5,1.5))
#         anim = Animation()
#         frame(anim, plt)
#     end

#     println("\n--- Starting Automated Algorithm 2 ---")
#     for i in 1:N_steps
#         current_force = Force_field(pos_bead)
        
#         force_proj = project_to_tangent(current_force, pos_bead, H_system)
#         v_bead = v_bead + force_proj * dt
#         pos_temp = pos_bead + v_bead * dt

#         if make_gif
#         scatter!(plt, [pos_temp[1]], [pos_temp[2]], color=:green, markersize=4, label= i==1 ? "Points after force is applied" : "")
#         frame(anim, plt)
#         end

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
        
#         if make_gif
#             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=4, label= i==1 ? "Projected Points" : "")
#             frame(anim, plt)
#         end
#     end
    
#     if make_gif
#         gif(anim, filename, fps=5)
#         println("Animation saved to: $filename")
#     end
    
#     return pos_bead, v_bead
# end

# # ==========================================
# # 3. CLEAN USER EXECUTION
# # ==========================================

# # @var x[1:2]
# # my_constraint_expr = x[1]^2 + x[2]^2 - 1.0
# # my_constraint_system = System([my_constraint_expr], variables=x)

# # Force_gravity(pos) = [0.0, -0.1]
# # pos_0 = [cos(pi/4), sin(pi/4)]
# # vel_0 = [0.0, 0.0]

# # # Run it and generate GIFs in your current working directory
# # algorithm_1(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, make_gif=true, filename="dynamics_algo1.gif")
# # algorithm_2(pos_0, vel_0, Force_gravity, 1.0, 20, my_constraint_system, make_gif=true, filename="dynamics_algo2.gif")



# # using HomotopyContinuation
# # using LinearAlgebra
# # using Plots

# # ==========================================
# # 1. INTERNAL HELPER FUNCTIONS
# # ==========================================

# """
# Builds the square parametrized system for parallel transport projection.
# Variables: x (n=2). Parameters: a (anchor, k=2) and n (normal direction, k=2).
# """
# function build_parallel_transport_mechanics(H_system::System)
#     vars = variables(H_system)
#     H_expr = expressions(H_system)[1] 
    
#     # Parameters for the line's anchor point (a) and fixed direction (n)
#     @var a[1:2] n[1:2]
    
#     # The parallel line condition
#     line_expr = (vars[1] - a[1]) * n[2] - (vars[2] - a[2]) * n[1]
    
#     # System with m=n=2, k=4
#     F_system = System([H_expr, line_expr], variables=vars, parameters=[a; n])
    
#     return F_system
# end

# function plot_variety(H_system::System, bounds=(-3.0, 3.0), pts=150)
#     x_vals = range(bounds[1], bounds[2], length=pts)
#     y_vals = range(bounds[1], bounds[2], length=pts)
#     z_vals = [real(H_system([x, y])[1]) for y in y_vals, x in x_vals]
    
#     plt = contour(x_vals, y_vals, z_vals, levels=[0.0], 
#                   color=:black, linewidth=2, legend=:outertopright, 
#                   aspect_ratio=:equal, title="Parallel Transport Projection")
#     return plt
# end

# # ==========================================
# # 2. THE ALGORITHM
# # ==========================================

# function parallel_transport_algorithm(pos_start, v_start, Force_field, dt, N_steps, H_system::System; make_gif=true, filename="parallel_transport.gif")
#     F_system = build_parallel_transport_mechanics(H_system)

#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
    
#     plt = nothing
#     anim = nothing
#     if make_gif
#         plt = plot_variety(H_system)

#         scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:red, markersize=6, label="Start Point", xlim = [-2.0,2.0], ylim = [-1.0,1.0])
#         anim = Animation()
#         frame(anim, plt)
#     end

#     println("--- Starting Parallel Transport Algorithm ---")
#     for i in 1:N_steps
#         # 1. Evaluate Jacobian to get the normal space at the STARTING point
#         Jx = jacobian(H_system, pos_bead) 
#         n_vec = [Jx[1,1], Jx[1,2]]
        
#         # --- SUBSTEP 1: Physics Update ---
#         current_force = Force_field(pos_bead)
        
#         # Project force to tangent space
#         force_proj = current_force - pinv(Jx) * Jx * current_force
#         println("Step $i: Force = $current_force")
#         println("Step $i: Force projected = $force_proj")
#         # Update velocities and get temporary displacement
#         v_bead = v_bead + force_proj * dt
#         println("Step $i: Velocity = $v_bead")
#         pos_temp = pos_bead + v_bead * dt

#         println("Step $i: After force $pos_temp")

#         if make_gif
#             scatter!(plt, [pos_temp[1]], [pos_temp[2]], color=:green, markersize=4, label= i==1 ? "Points after force is applied" : "")
#             frame(anim, plt)
#         end

#         # --- SUBSTEP 2: Parallel Transport Projection ---
#         # The line is initially anchored at the start point
#         start_params = [pos_bead; n_vec] 
        
#         # The line shifts to be anchored at the temporary point, maintaining orientation
#         target_params = [pos_temp; n_vec] 

#         result = solve(
#             F_system, 
#             [pos_bead]; 
#             start_parameters = start_params, 
#             target_parameters = target_params, 
#             show_progress = false
#         )
        
#         if isempty(solutions(result))
#             error("Path tracking failed at step $i. Try decreasing the time step dt.")
#         end
        
#         # Update position to the new intersection
#         tracked_sol = solutions(result)[1]
#         pos_bead = real.(tracked_sol)
        
#         # Update velocity projection to the NEW tangent space for the next loop iteration
#         Jx_new = jacobian(H_system, pos_bead)
#         v_bead = v_bead - pinv(Jx_new) * Jx_new * v_bead

#         println("Step $i: Position = $pos_bead")
        
#         if make_gif
#             scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=4, label= i==1 ? "Projected Points" : "")
#             frame(anim, plt)
#         end
#     end
    
#     if make_gif
#         gif(anim, filename, fps=5)
#         println("Animation saved to: $filename")
#     end
    
#     return pos_bead, v_bead
# end

# # ==========================================
# # 3. EXECUTION
# # ==========================================

# # @var x[1:2]
# # my_constraint_expr = x[1]^2 + 4x[2]^2 - 1.0 # Testing with the ellipse!
# # ellipse_system = System([my_constraint_expr], variables=x)

# # Force_gravity(pos) = [0.0, -0.1]

# # # Start exactly on the ellipse
# # pos_0 = [cos(pi/4), 0.5 * sin(pi/4)]
# # vel_0 = [0.0, 0.0]

# # # Smaller dt to prevent discriminant locus crossings on the ellipse
# # parallel_transport_algorithm(pos_0, vel_0, Force_gravity, 0.1, 50, ellipse_system, make_gif=true, filename="parallel_ellipse.gif")



# # using HomotopyContinuation
# # using LinearAlgebra

# # ==========================================
# # 1. MODIFIED ALGORITHMS (Returning History)
# # ==========================================
# # (Assuming project_to_tangent, build_projection_mechanics, 
# # and build_parallel_transport_mechanics are already loaded from your environment)

# function algo_1_history(pos_start, v_start, Force_field, dt, N_steps, H_system)
#     F_system = build_projection_mechanics(H_system)
#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
#     history = [copy(pos_bead)]

#     for i in 1:N_steps
#         current_force = Force_field(pos_bead)
#         v_bead = v_bead + current_force * dt
#         pos_temp = pos_bead + v_bead * dt

#         result = solve(F_system, [pos_bead]; start_parameters=pos_bead, target_parameters=pos_temp, show_progress=false)
#         pos_bead = real.(solutions(result)[1])
#         v_bead = project_to_tangent(v_bead, pos_bead, H_system)
        
#         push!(history, copy(pos_bead))
#     end
#     return history
# end

# function algo_2_history(pos_start, v_start, Force_field, dt, N_steps, H_system)
#     F_system = build_projection_mechanics(H_system)
#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
#     history = [copy(pos_bead)]

#     for i in 1:N_steps
#         current_force = Force_field(pos_bead)
#         force_proj = project_to_tangent(current_force, pos_bead, H_system)
#         v_bead = v_bead + force_proj * dt
#         pos_temp = pos_bead + v_bead * dt

#         result = solve(F_system, [pos_bead]; start_parameters=pos_bead, target_parameters=pos_temp, show_progress=false)
#         pos_bead = real.(solutions(result)[1])
#         v_bead = project_to_tangent(v_bead, pos_bead, H_system)
        
#         push!(history, copy(pos_bead))
#     end
#     return history
# end

# function parallel_transport_history(pos_start, v_start, Force_field, dt, N_steps, H_system)
#     F_system = build_parallel_transport_mechanics(H_system)
#     pos_bead = float.(copy(pos_start))
#     v_bead = float.(copy(v_start))
#     history = [copy(pos_bead)]

#     for i in 1:N_steps
#         Jx = jacobian(H_system, pos_bead) 
#         n_vec = [Jx[1,1], Jx[1,2]]
        
#         current_force = Force_field(pos_bead)
#         force_proj = current_force - pinv(Jx) * Jx * current_force
#         v_bead = v_bead + force_proj * dt
#         pos_temp = pos_bead + v_bead * dt

#         start_params = [pos_bead; n_vec] 
#         target_params = [pos_temp; n_vec] 

#         result = solve(F_system, [pos_bead]; start_parameters=start_params, target_parameters=target_params, show_progress=false)
#         pos_bead = real.(solutions(result)[1])
        
#         Jx_new = jacobian(H_system, pos_bead)
#         v_bead = v_bead - pinv(Jx_new) * Jx_new * v_bead
        
#         push!(history, copy(pos_bead))
#     end
#     return history
# end

# # ==========================================
# # 2. EXECUTION & COMPARISON
# # ==========================================

# @var x[1:2]
# circle_expr = x[1]^2 + x[2]^2 - 1.0
# circle_system = System([circle_expr], variables=x)

# Force_gravity(pos) = [0.0, -0.1]
# pos_0 = [cos(pi/4), sin(pi/4)]
# vel_0 = [0.0, 0.0]

# dt = 1.0
# N = 20

# # Get the sequences
# seq_1 = algo_1_history(pos_0, vel_0, Force_gravity, dt, N, circle_system)
# seq_2 = algo_2_history(pos_0, vel_0, Force_gravity, dt, N, circle_system)
# seq_3 = parallel_transport_history(pos_0, vel_0, Force_gravity, dt, N, circle_system)

# # Compare the final positions to see the divergence
# println("--- Final Position Comparison ---")
# println("Algorithm 1:           ", round.(seq_1[end], digits=4))
# println("Algorithm 2:           ", round.(seq_2[end], digits=4))
# println("Parallel Transport:    ", round.(seq_3[end], digits=4))

# # Calculate the maximum Euclidean distance between the sequences at any time step
# max_diff_1_2 = maximum([norm(seq_1[i] - seq_2[i]) for i in 1:length(seq_1)])
# max_diff_2_3 = maximum([norm(seq_2[i] - seq_3[i]) for i in 1:length(seq_2)])
# max_diff_1_3 = maximum([norm(seq_1[i] - seq_3[i]) for i in 1:length(seq_1)])

# println("\n--- Maximum Sequence Divergence ---")
# println("Max difference (Algo 1 vs Algo 2):        ", round(max_diff_1_2, digits=6))
# println("Max difference (Algo 2 vs Parallel Tpt):  ", round(max_diff_2_3, digits=6))
# println("Max difference (Algo 1 vs Parallel Tpt):  ", round(max_diff_1_3, digits=6))


# ==========================================
# 1. INTERNAL HELPER FUNCTIONS
# ==========================================

"""
Project a vector `v` onto the tangent space of the constraint variety at `pos`.
"""
function project_to_tangent(v, pos, H_system::System)
    Jx = real.(jacobian(H_system, pos)) 
    return v - pinv(Jx) * Jx * v
end

"""
Builds the parametrized orthogonal projection system.
"""
function build_projection_mechanics(H_system::System)
    vars = variables(H_system)
    H_expr = expressions(H_system)[1] 
    
    @var p[1:2]
    
    dH_dx1 = differentiate(H_expr, vars[1])
    dH_dx2 = differentiate(H_expr, vars[2])
    
    perp_expr = (vars[1] - p[1]) * dH_dx2 - (vars[2] - p[2]) * dH_dx1
    
    F_system = System([H_expr, perp_expr], variables=vars, parameters=p)
    return F_system
end

"""
Builds the square parametrized system for parallel transport projection.
"""
function build_parallel_transport_mechanics(H_system::System)
    vars = variables(H_system)
    H_expr = expressions(H_system)[1] 
    
    @var a[1:2] n[1:2]
    
    line_expr = (vars[1] - a[1]) * n[2] - (vars[2] - a[2]) * n[1]
    
    F_system = System([H_expr, line_expr], variables=vars, parameters=[a; n])
    return F_system
end

"""
Plots the constraint variety V(H) = 0 natively using the System.
"""
function plot_variety(H_system::System, bounds=(-3.0, 3.0), pts=150; plot_title="Constrained Dynamics")
    x_vals = range(bounds[1], bounds[2], length=pts)
    y_vals = range(bounds[1], bounds[2], length=pts)
    
    z_vals = [real(H_system([x, y])[1]) for y in y_vals, x in x_vals]
    
    plt = contour(x_vals, y_vals, z_vals, levels=[0.0], 
                  color=:black, linewidth=2, legend=:outertopright, 
                  aspect_ratio=:equal, title=plot_title)
    return plt
end



# ==========================================
# 2. THE MASTER SOLVER aka THE ENGINE
# ==========================================

function run_constrained_dynamics(pos_start, v_start, vector_field, dt, N_steps, H_system; 
                                  predictor = tangent_predictor, 
                                  corrector = hc_orthogonal_corrector,
                                  field_type = :velocity,
                                  make_gif = false,
                                  filename = "dynamics.gif",
                                  stop_tol = 1e-6)
                                  
    F_ortho = build_projection_mechanics(H_system)
    F_parallel = build_parallel_transport_mechanics(H_system)

    pos_bead = float.(copy(pos_start))
    v_bead = float.(copy(v_start))
    history = [copy(pos_bead)]
    
    plt = nothing
    anim = nothing
    if make_gif
        plt = plot_variety(H_system)
        scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:red, markersize=6, label="Start")
        anim = Animation()
        frame(anim, plt) 
    end

    println("--- Executing Dynamics Path ---")
    for i in 1:N_steps
        field_value = vector_field(pos_bead)
        
        # 1. PREDICTOR STEP 
        pos_temp, v_bead = predictor(pos_bead, v_bead, field_value, dt, H_system, field_type)

        # 2. CORRECTOR STEP 
        pos_bead, v_bead = corrector(pos_temp, pos_bead, v_bead, H_system; F_ortho=F_ortho, F_parallel=F_parallel)
        
        push!(history, copy(pos_bead))

        if make_gif
            scatter!(plt, [pos_bead[1]], [pos_bead[2]], color=:blue, markersize=4, label="")
            frame(anim, plt)
        end

        # ---------------------------------------------------------
        # 3. EARLY STOPPING CHECK (Goal 3d)
        # ---------------------------------------------------------
        step_distance = norm(history[end] - history[end-1])
        if step_distance < stop_tol
            println("Convergence reached at step $i. The point stopped moving.")
            break
        end
    end
    
    if make_gif
        gif(anim, filename, fps=5)
        println("Animation saved to: $filename")
    end
    
    return history
end


# ==========================================
# 5. EXECUTION SCRIPT
# ==========================================

# # @var x[1:2]
# # circle_expr = x[1]^2 + x[2]^2 - 1.0
# # circle_system = System([circle_expr], variables=x)

# # force_gravity(pos) = [0.0, -0.1]
# # velocity_rotation(pos) = [-pos[2], pos[1]] # A field that rotates points around the origin

# # pos_0 = [cos(pi/4), sin(pi/4)]
# # vel_0 = [0.0, 0.0]

# # dt = 0.5
# # N = 20

# # # Example 1: Run with a force field (gravity)
# # run_constrained_dynamics(pos_0, vel_0, force_gravity, dt, N, circle_system, 
# #                          predictor = ambient_predictor, 
# #                          corrector = hc_orthogonal_corrector, 
# #                          field_type = :force,
# #                          make_gif = true, filename = "dynamics_force.gif")

# # # Example 2: Run with a velocity field (rotation)
# # history_vf = run_constrained_dynamics(pos_0, vel_0, velocity_rotation, dt, N, circle_system, 
# #                                       predictor = tangent_predictor, 
# #                                       corrector = moore_penrose_corrector,
# #                                       field_type = :velocity,
# #                                       make_gif = true, filename = "dynamics_velocity.gif")

# # println("Final position (velocity field): ", history_vf[end])



# """
# Runs a constrained physics simulation on a specific geometry and prints a detailed diagnostic summary.

# Arguments:
# - `name`: String name of the geometry (e.g., "3D Sphere")
# - `sys`: HomotopyContinuation System representing the manifold
# - `p0`: Initial starting coordinates of the bead
# - `vector_field`: The vector field function to apply (e.g., gravity_force_field)

# Keyword Arguments:
# - `dt`: Time step size (default 0.05)
# - `N`: Number of time steps (default 100)
# """
# function run_and_analyze(name, sys, p0, vector_field; dt=0.05, N=100)
#     println("==================================================")
#     println(" SIMULATION: $name")
#     println("==================================================")

#     dim = length(p0)
#     v0 = zeros(dim) 

#     # 1. Compile the Geometry for HomotopyOpt
#     vars = variables(sys)
#     eqs = expressions(sys)
#     current_variety = ConstraintVariety(vars, eqs, p0)

#     # 2. Wrap the corrector to bypass the keyword argument error
#     wrapped_corrector(p_t, p_prev, v_t, s; kwargs...) = 
#         homotopyopt_ed_corrector(p_t, p_prev, v_t, s; variety=current_variety, kwargs...)

#     # 3. Run the dynamics
#     println("[Running Dynamics...]")
#     history = run_constrained_dynamics(
#         p0, v0, vector_field, dt, N, sys;
#         predictor = tangent_predictor,
#         corrector = wrapped_corrector,  
#         field_type = :velocity,
#         make_gif = false 
#     )

#     # 4. Detailed Results Analysis
#     p_final = history[end]

#     println("\n==================================================")
#     println(" DETAILED RESULTS SUMMARY")
#     println("==================================================")
#     println("Total Time Steps (N) : ", N)
#     println("Time Step Size (dt)  : ", dt)
#     println("Total Simulated Time : ", round(N * dt, digits=2), " seconds")
#     println("--------------------------------------------------")
#     println("Initial Position (p0): ", round.(p0, digits=4))
#     println("Final Position (pN)  : ", round.(p_final, digits=4))
#     println("--------------------------------------------------")

#     # Calculate Z-drop
#     z_start = p0[end]
#     z_final = p_final[end]
#     drop_distance = z_start - z_final

#     println("Starting Height (Z)  : ", round(z_start, digits=4))
#     println("Final Height (Z)     : ", round(z_final, digits=4))
#     println("Elevation Lost       : ", round(drop_distance, digits=4), " units")

#     # Calculate actual arc-length traveled
#     path_length = sum(norm(history[i] - history[i-1]) for i in 2:length(history))
#     println("Total Path Length    : ", round(path_length, digits=4), " units traveled")
#     println("==================================================\n")
    
#     return history
# end

# ==========================================================
#  THE PUBLIC API: optimize
# ==========================================================
# """
#     optimize(F::System, V::Function; p0=nothing, dt=0.1, max_steps=100, corrector=ed_retraction_corrector)

# The high-level interface for Manifold Gradient Descent. 
# - If p0 is not provided, it automatically finds a starting point on the manifold.
# - Returns (final_point, trajectory_history).
# """
# function optimize(F::System, V::Function; 
#                   p0=nothing, 
#                   dt=0.1, 
#                   max_steps=100, 
#                   corrector=ed_retraction_corrector)
    
#     # 1. Setup the Geometry
#     vars = variables(F)
#     eqs = expressions(F)
    
#     # 2. HANDLE STARTING POINT (p0)
#     start_p = if p0 === nothing
#         println("[Info] No p0 provided. Computing Witness Set to find a starting point...")
        
#         # Compute the witness set for the manifold
#         W = witness_set(F) 
        
#         # Extract all points from the witness set
#         pts = solutions(W)
        
#         # Filter for points that are numerically real (imaginary part near zero)
#         real_pts = [real(p) for p in pts if all(abs.(imag.(p)) .< 1e-8)]
        
#         if isempty(real_pts)
#             error("Could not find any real points on the manifold component found by witness_set.")
#         end
        
#         println("[Info] Found $(length(real_pts)) real points. Picking the first one.")
#         real_pts[1]
#     else
#         float.(copy(p0))
#     end
    
#     # 3. Compile the Variety for the Corrector
#     current_variety = ConstraintVariety(vars, eqs, start_p)
    
#     # 4. Wrap the corrector
#     wrapped_corrector(p_t, p_prev, v_t, s; kwargs...) = 
#         corrector(p_t, p_prev, v_t, s; variety=current_variety, kwargs...)

#     # 5. Call the Engine
#     history = run_constrained_dynamics(
#         start_p, 
#         zeros(length(start_p)), 
#         V, 
#         dt, 
#         max_steps, 
#         F;
#         predictor = tangent_predictor,
#         corrector = wrapped_corrector,
#         field_type = :velocity,
#         make_gif = false
#     )
    
#     return history[end], history
# end


"""
    optimize(F::System, V::Function; p0=nothing, dt=0.1, max_steps=100, corrector=ed_retraction_corrector)

The high-level interface for Manifold Gradient Descent. 
- If p0 is not provided, it uses a Newton Pull-in method to find a real point on the manifold.
"""
function optimize(F::System, V::Function; 
                  p0 = nothing, 
                  dt = 0.1, 
                  max_steps = 100, 
                  corrector = ed_retraction_corrector,
                  kwargs...) 

    vars = variables(F)
    eqs = expressions(F)

    # 1. INITIALIZATION: Uses kwargs if you want to override tol/max_iters
    start_p = if p0 === nothing
        println("Projecting random guess onto manifold...")
        p_final, success = project_onto_manifold(F, randn(length(vars)); kwargs...)
        
        if !success
            error("Initialization failed: Manifold projection did not converge.")
        end
        p_final
    else
        float.(copy(p0))
    end
    
    # 2. SETUP: Compile variety and bake the corrector closure
    current_variety = ConstraintVariety(vars, eqs, start_p)
    
    # We allow the corrector to take its own internal kwargs as well
    wrapped_corrector(p_t, p_prev, v_t, s; corrector_kwargs...) = 
        corrector(p_t, p_prev, v_t, s; variety=current_variety, corrector_kwargs...)

    # 3. ENGINE
    history = run_constrained_dynamics(
        start_p, zeros(length(start_p)), V, dt, max_steps, F;
        predictor = tangent_predictor,
        corrector = wrapped_corrector,
        field_type = :velocity,
        make_gif = false,
        kwargs... 
    )
    
    return history[end], history
end

"""
    project_onto_manifold(F::System, guess::Vector; tol=1e-10, max_iters=100, kwargs...)

Robust Newton-Raphson pull-in using Moore-Penrose pseudo-inverse.
"""
function project_onto_manifold(F::System, guess::Vector; tol=1e-10, max_iters=100, kwargs...)
    p_curr = float.(copy(guess))
    
    for i in 1:max_iters
        val = real.(F(p_curr))
        if norm(val) < tol
            return p_curr, true # Found the manifold
        end
        
        Jx = real.(jacobian(F, p_curr))
        # The Moore-Penrose step: Δp = -J⁺ * F(p)
        p_curr -= pinv(Jx) * val 
    end
    
    return p_curr, false # Convergence failed
end


# ==========================================================
#  THE FULL REPORT GENERATOR: run_and_analyze
# ==========================================================
"""
    run_and_analyze(name, sys, p0, vector_field; dt=0.05, N=100)

Runs a simulation using `optimize` and prints a full diagnostic report
including elevation loss and path length.

Arguments:
- `name`: String name of the geometry (e.g., "3D Sphere")
- `sys`: HomotopyContinuation System representing the manifold
- `p0`: Initial starting coordinates of the bead
- `vector_field`: The vector field function to apply (e.g., gravity_force_field)

Keyword Arguments:
- `dt`: Time step size (default 0.05)
- `N`: Number of time steps (default 100)
"""
function run_and_analyze(name, sys, p0, vector_field; dt=0.05, N=100)
    println("==================================================")
    println(" SIMULATION: $name")
    println("==================================================")

    # 1. Call the API (Zero code duplication!)
    p_final, history = optimize(sys, vector_field; p0=p0, dt=dt, max_steps=N)

    # 2. Detailed Results Analysis
    println("\n==================================================")
    println(" DETAILED RESULTS SUMMARY")
    println("==================================================")
    println("Total Time Steps (N) : ", N)
    println("Time Step Size (dt)  : ", dt)
    println("Total Simulated Time : ", round(N * dt, digits=2), " seconds")
    println("--------------------------------------------------")
    println("Initial Position (p0): ", round.(p0, digits=4))
    println("Final Position (pN)  : ", round.(p_final, digits=4))
    println("--------------------------------------------------")

    # Calculate Elevation Lost (Assuming gravity pulls down on the last coordinate)
    z_start = p0[end]
    z_final = p_final[end]
    drop_distance = z_start - z_final

    println("Starting Height (Z)  : ", round(z_start, digits=4))
    println("Final Height (Z)     : ", round(z_final, digits=4))
    println("Elevation Lost       : ", round(drop_distance, digits=4), " units")

    # Calculate actual arc-length traveled
    path_length = sum(norm(history[i] - history[i-1]) for i in 2:length(history))
    println("Total Path Length    : ", round(path_length, digits=4), " units traveled")
    println("==================================================\n")
    
    return history
end