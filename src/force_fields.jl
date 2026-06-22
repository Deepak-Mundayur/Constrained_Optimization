


function gravity_force_field(x::Vector{Float64}; t=1.0)
    n = length(x)
    force_at_x = push!([0.0 for _ in 1:n-1], -1.0)  # Gravity in last component
    return force_at_x
end




function make_attractor_force(target_point::Vector{Float64})
    # Like in Hooke's Law, the force here is proportional to the distance to the target
    return function(x::Vector{Float64}; t=1.0)
        return target_point - x 
    end
end



function make_repelling_points_force(n_points::Int, bounds::Tuple{Tuple{Float64, Float64}, Tuple{Float64, Float64}}; k_p::Float64=1.0, k_w::Float64=1.0, total_vars::Int=6*n_points)
    # total_vars defaults to 6*n_points to account for the 2 primary variables 
    # and 4 slack variables per point in the matroid bounding box.
    
    return function(state::Vector{Float64}; t=1.0)
        (x_min, x_max), (y_min, y_max) = bounds
        forces = zeros(Float64, total_vars)
        
        for i in 1:n_points
            idx_i_x = 2*i - 1
            idx_i_y = 2*i
            
            xi = state[idx_i_x]
            yi = state[idx_i_y]
            
            # 1. Boundary Repulsion (Inverse Square)
            if xi - x_min > 1e-9
                forces[idx_i_x] += k_w / (xi - x_min)^2
            end
            if x_max - xi > 1e-9
                forces[idx_i_x] -= k_w / (x_max - xi)^2
            end
            if yi - y_min > 1e-9
                forces[idx_i_y] += k_w / (yi - y_min)^2
            end
            if y_max - yi > 1e-9
                forces[idx_i_y] -= k_w / (y_max - yi)^2
            end
            
            # 2. Inter-particle Repulsion (Inverse Square)
            for j in 1:n_points
                if i != j
                    idx_j_x = 2*j - 1
                    idx_j_y = 2*j
                    
                    xj = state[idx_j_x]
                    yj = state[idx_j_y]
                    
                    diff_x = xi - xj
                    diff_y = yi - yj
                    dist_sq = diff_x^2 + diff_y^2
                    
                    if dist_sq > 1e-9
                        dist = sqrt(dist_sq)
                        forces[idx_i_x] += k_p * diff_x / (dist^3)
                        forces[idx_i_y] += k_p * diff_y / (dist^3)
                    end
                end
            end
        end
        
        # The forces acting on the slack variables remain 0.0
        return forces
    end
end


function make_bounded_repelling_force(n_pts::Int, bounds; k_p=10.0, k_wall=1000000000000000.0)
    (xmin, xmax), (ymin, ymax) = bounds

    function V(pos)
        force = zeros(length(pos))
        
        for i in 1:n_pts
            idx_x = 2*i - 1
            idx_y = 2*i
            x, y = pos[idx_x], pos[idx_y]
            
            #  Point-to-Point Repulsion 
            for j in 1:n_pts
                if i != j
                    jx, jy = pos[2*j - 1], pos[2*j]
                    dx = x - jx
                    dy = y - jy
                    dist_sq = dx^2 + dy^2 + 1e-6
                    
                    force[idx_x] += k_p * dx / dist_sq
                    force[idx_y] += k_p * dy / dist_sq
                end
            end
            
            # The bounding box forces ( Inverse square barrier)
            force[idx_x] += k_wall / (x - xmin)^2
            force[idx_x] -= k_wall / (xmax - x)^2
            
            force[idx_y] += k_wall / (y - ymin)^2
            force[idx_y] -= k_wall / (ymax - y)^2
        end
        
        # If the system has a saturation slack variable 't' at the end, 
        # its force is 0 
        if length(pos) > 2 * n_pts
            force[end] = 0.0
        end
        
        return force
    end
    
    return V
end