
"""
Simulates an unconstrained force-directed graph drawing in (R^2)^n.
Now upgraded to Newtonian kinematic mechanics to match Algorithm 1's Predictor step.
"""
function force_directed_kinematic(
    num_vertices::Int, 
    edges::Vector{Tuple{Int, Int}}; 
    iters::Int=1000, 
    dt::Float64=0.01,
    k_coulomb::Float64=1.0, 
    k_hooke::Float64=1.0, 
    rest_length::Float64=1.0,
    damping::Float64=0.85  # Friction to stop infinite oscillation
)
    # 1. Initialize random positions and ZERO velocities
    p = [randn(2) for _ in 1:num_vertices]
    v = [zeros(2) for _ in 1:num_vertices]
    
    # Pre-allocate array for the Forces
    F = [zeros(2) for _ in 1:num_vertices]

    for iter in 1:iters
        # Reset forces for this step
        for i in 1:num_vertices
            fill!(F[i], 0.0)
        end

        # 2. Coulomb Repulsion: Vertices repel each other
        for i in 1:num_vertices
            for j in 1:num_vertices
                if i != j
                    diff = p[i] - p[j]
                    dist_sq = dot(diff, diff)
                    
                    if dist_sq > 1e-4
                        force_magnitude = k_coulomb / dist_sq
                        direction = diff / sqrt(dist_sq)
                        F[i] += force_magnitude * direction
                    end
                end
            end
        end

        # 3. Hooke Attraction: Edges pull connected vertices together
        for (u, w) in edges
            diff = p[u] - p[w]
            dist = norm(diff)
            
            if dist > 1e-4
                direction = diff / dist
                force_magnitude = -k_hooke * (dist - rest_length)
                force_vec = force_magnitude * direction
                
                # Apply equal and opposite forces
                F[u] += force_vec
                F[w] -= force_vec
            end
        end

        # 4. The "Predictor" Step: Update Velocity and Position
        # Exactly mirrors the predictor step of your constrained algorithms
        for i in 1:num_vertices
            # Update velocity, applying the damping friction
            v[i] = (v[i] + F[i] * dt) * damping
            
            # Update position based on the new velocity
            p[i] = p[i] + v[i] * dt
        end
    end

    return p
end

# --- Test the Unified Physics ---
n_nodes = 4
graph_edges = [(1, 2), (2, 3), (3, 1), (3, 4)]

final_positions = force_directed_kinematic(n_nodes, graph_edges, iters=1500)

println("--- Soft Penalty Equilibrium Reached ---")
for (i, pos) in enumerate(final_positions)
    println("Node $i: [$(round(pos[1], digits=3)), $(round(pos[2], digits=3))]")
end