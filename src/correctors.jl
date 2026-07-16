# ==========================================
# CORRECTORS (Projecting back to the manifold)
# ==========================================


function hc_orthogonal_corrector(pos_temp, pos_old, v, H_system; F_ortho, kwargs...)
    n_vars = length(pos_old)
    m_eqs = length(expressions(H_system))
    
    # Pad the starting position with zeros for the m Lagrange multipliers
    start_sol = vcat(pos_old, zeros(Float64, m_eqs))
    
    result = solve(F_ortho, [start_sol]; start_parameters=pos_old, target_parameters=pos_temp, show_progress=false)
    
    # Extract only the first n_vars from the tracked solution (ignoring the λ values)
    tracked_full = real.(solutions(result)[1])
    pos_bead = tracked_full[1:n_vars]
    
    v_bead = project_to_tangent(v, pos_bead, H_system)
    return pos_bead, v_bead
end

function ordinary_newton_corrector(pos_temp, pos_old, v, H_system; F_ortho, kwargs...)
    n_vars = length(pos_old)
    m_eqs = length(expressions(H_system))
    
    pos_full = vcat(float.(copy(pos_temp)), zeros(Float64, m_eqs))
    target_params = pos_temp 

    for iter in 1:50
        val = real.(F_ortho(pos_full, target_params))
        if norm(val) < 1e-10
            break
        end
        Jx = real.(jacobian(F_ortho, pos_full, target_params))
        pos_full = pos_full - inv(Jx) * val
    end

    pos_bead = pos_full[1:n_vars]
    v_bead = project_to_tangent(v, pos_bead, H_system)
    return pos_bead, v_bead
end

function hc_parallel_corrector(pos_temp, pos_old, v, H_system; F_parallel, kwargs...)
    Jx = jacobian(H_system, pos_old) 
    n_vec = [Jx[1,1], Jx[1,2]]
    
    start_params = [pos_old; n_vec] 
    target_params = [pos_temp; n_vec] 

    result = solve(F_parallel, [pos_old]; start_parameters=start_params, target_parameters=target_params, show_progress=false)
    pos_bead = real.(solutions(result)[1])
    v_bead = project_to_tangent(v, pos_bead, H_system)
    return pos_bead, v_bead
end


function moore_penrose_corrector(pos_temp, pos_old, v, H_system; kwargs...)
    # Underdetermined Newton-Raphson acting directly on the manifold constraint H(x) = 0
    pos_bead = float.(copy(pos_temp))
    
    for iter in 1:50
        val = real.(H_system(pos_bead))
        if norm(val) < 1e-10
            break
        end
        # Use Moore-Penrose pseudoinverse since Jx is a wide 1x2 matrix
        Jx = real.(jacobian(H_system, pos_bead))
        pos_bead = pos_bead - pinv(Jx) * val
    end
    
    v_bead = project_to_tangent(v, pos_bead, H_system)
    return pos_bead, v_bead
end


# HomotopyOpt (Heaton-Himmelmann ED Retraction)
# function ed_retraction_corrector(pos_temp, pos_old, v, H_system; variety=nothing, kwargs...)
#     # If the user passed a pre-compiled variety, use it! Otherwise, make one.
#     V = variety !== nothing ? variety : ConstraintVariety(variables(H_system), expressions(H_system), pos_old)
    
#     num_eqs = length(expressions(H_system))
#     V.EDTracker.startSolution = vcat(pos_old, zeros(num_eqs))
    
#     step_vector = pos_temp - pos_old 
    
#     new_p, success = EDStep(V, pos_old, 1.0, step_vector; homotopyMethod="Newton")
    
#     if !success
#         println("  [Warning] HomotopyOpt EDStep failed to converge. Falling back...")
#         return pos_temp, v 
#     end
    
#     v_new = project_to_tangent(v, new_p, H_system)
#     return new_p, v_new
# end