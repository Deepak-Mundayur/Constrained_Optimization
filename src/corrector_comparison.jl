# ==========================================
# 6. SEQUENCE COMPARISON SCRIPT
# ==========================================

@var x[1:2]
circle_expr = x[1]^2 + x[2]^2 - 1.0
circle_system = System([circle_expr], variables=x)

force_gravity(pos) = [0.0, -0.1]
pos_0 = [cos(pi/4), sin(pi/4)]
vel_0 = [0.0, 0.0]

dt = 0.5
N = 20

println("\n--- Generating Sequences (using a force field) ---")
# 1. Run using Moore-Penrose corrector
history_penrose = run_constrained_dynamics(pos_0, vel_0, force_gravity, dt, N, circle_system, 
                                      predictor = tangent_predictor, 
                                      corrector = moore_penrose_corrector,
                                      field_type = :force)

# 2. Run using Ordinary Newton solver
history_newton = run_constrained_dynamics(pos_0, vel_0, force_gravity, dt, N, circle_system, 
                                          predictor = tangent_predictor, 
                                          corrector = ordinary_newton_corrector,
                                          field_type = :force)

# --- Compare the Results ---
println("\n--- Final Position Comparison ---")
println("Moore-Penrose Corrector: ", round.(history_penrose[end], digits=6))
println("Ordinary Newton:         ", round.(history_newton[end], digits=6))

# Calculate the maximum Euclidean distance between the sequences at any time step
max_diff = maximum([norm(history_penrose[i] - history_newton[i]) for i in 1:length(history_penrose)])

println("\n--- Maximum Sequence Divergence ---")
println("Max difference (Moore-Penrose vs Ordinary Newton): ", max_diff)