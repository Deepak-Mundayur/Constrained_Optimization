
# # --- HELPER FUNCTIONS ---

# """
# Project a vector `v` onto the tangent space of the variety at point `x`.
# The tangent space is the kernel of the Jacobian `J(x)`.
# """
# function project_to_tangent(v, x, J)
#     Jx = J(x)
#     # Projection matrix onto the kernel is (I - J^+ * J)
#     # So the tangent vector is v - J^+ * J * v
#     return v - pinv(Jx) * Jx * v
# end

# """
# Project a point `p_guess` back onto the variety defined by H(x) = 0.
# Uses minimum-norm Newton corrector steps.
# """
# function project_to_variety(p_guess, H, J; max_iter=20, tol=1e-8)
#     x = float.(copy(p_guess))
#     for _ in 1:max_iter
#         hx = H(x)
#         if norm(hx) < tol
#             break
#         end
#         Jx = J(x)
#         # Newton step: dx = - J(x)^+ * H(x)
#         dx = -pinv(Jx) * hx
#         x = x + dx
#     end
#     return x
# end

# # --- ALGORITHM 1 ---

# function algorithm_1(p_start, v_start, F_func, dt, N, H, J)
#     p_bead = float.(copy(p_start))
#     v_bead = float.(copy(v_start))

#     println("Starting Generalized Algorithm 1...")
#     for i in 1:N
#         # Get current force (can be a constant or depend on position)
#         F = F_func(p_bead)

#         # --- Substep 1 ---
#         v_bead = v_bead + F * dt
#         p_temp = p_bead + v_bead * dt

#         # --- Substep 2 ---
#         # 1. Project p_temp back to the variety H(x) = 0
#         p_bead = project_to_variety(p_temp, H, J)

#         # 2. Project velocity to the tangent space of the new position
#         v_bead = project_to_tangent(v_bead, p_bead, J)

#         println("Step $i: Position = $p_bead")
#     end
#     return p_bead, v_bead
# end

# # --- ALGORITHM 2 ---

# function algorithm_2(p_start, v_start, F_func, dt, N, H, J)
#     p_bead = float.(copy(p_start))
#     v_bead = float.(copy(v_start))

#     println("Starting Generalized Algorithm 2...")
#     for i in 1:N
#         F = F_func(p_bead)

#         # --- Substep 1 ---
#         # Project force onto tangent at current p_bead FIRST
#         F_proj = project_to_tangent(F, p_bead, J)
        
#         v_bead = v_bead + F_proj * dt
#         p_temp = p_bead + v_bead * dt

#         # --- Substep 2 ---
#         # 1. Project p_temp back to the variety H(x) = 0
#         p_bead = project_to_variety(p_temp, H, J)

#         # 2. Project velocity to the tangent space of the new position
#         v_bead = project_to_tangent(v_bead, p_bead, J)

#         println("Step $i: Position = $p_bead")
#     end
#     return p_bead, v_bead
# end

# # # --- EXAMPLE USAGE (Unit Circle) ---
# # # H(x) = x_1^2 + x_2^2 - 1 = 0
# # H_circle(x) = [x[1]^2 + x[2]^2 - 1.0]

# # # Jacobian matrix of H (1x2 matrix)
# # J_circle(x) = [2*x[1] 2*x[2]]

# # # Constant force function
# # gravity(x) = [0.0, -0.1]

# # p0 = [cos(pi/4), sin(pi/4)]
# # v0 = [0.0, 0.0]

# # println("\n--- Testing Algo 1 ---")
# # algorithm_1(p0, v0, gravity, 1.0, 5, H_circle, J_circle)

# # println("\n--- Testing Algo 2 ---")
# # algorithm_2(p0, v0, gravity, 1.0, 5, H_circle, J_circle)