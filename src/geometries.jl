
# ==========================================
# GROUP 1: PLANE CURVES (2D)
# ==========================================
function plane_circle()
    @var x y
    return "Circle", System([x^2 + y^2 - 1.0], variables=[x, y]), [0.7071067811865476, 0.7071067811865476]
end

function plane_bicuspid()
    @var x y
    expr = (x^2 - 1)*(x - 1)^2 + (y^2 - 1)^2
    return "Bicuspid Curve", System([expr], variables=[x, y]), [0.0, 1.0]
end

function plane_lemniscate_gerono()
    @var x y
    expr = x^4 - x^2 + y^2
    # Start slightly off origin to avoid the exact singular crossing initially
    return "Lemniscate of Gerono", System([expr], variables=[x, y]), [1.0, 0.0]
end

function plane_nephroid()
    @var x y
    expr = (x^2 + y^2 - 4)^3 - 108*y^2
    return "Nephroid", System([expr], variables=[x, y]), [2.0, 0.0]
end

function plane_astroid()
    @var x y
    expr = (x^2 + y^2 - 1)^3 + 27*x^2*y^2
    return "Astroid", System([expr], variables=[x, y]), [1.0, 0.0]
end

function plane_cardioid()
    @var x y
    expr = (x^2 + y^2 + x)^2 - (x^2 + y^2)
    return "Cardioid", System([expr], variables=[x, y]), [0.0, 1.0]
end




# ==========================================
# GROUP 2: SURFACES IN R^3 (3D)
# ==========================================
function surface_sphere()
    @var x y z
    return "3D Sphere", System([x^2 + y^2 + z^2 - 1.0], variables=[x, y, z]), [0.0, 0.0, 1.0]
end

function surface_torus()
    @var x y z
    expr = (x^2 + y^2 + z^2 + 3.0)^2 - 16.0*(x^2 + y^2)
    return "3D Torus", System([expr], variables=[x, y, z]), [3.0, 0.0, 0.0]
end


# ==========================================
# GROUP 3: CURVES IN R^3 (1D Curves in 3D Space)
# ==========================================
function curve_viviani()
    @var x y z
    # Viviani's curve is the intersection of a sphere and a cylinder (2 equations, 3 variables)
    eq1 = x^2 + y^2 + z^2 - 4.0
    eq2 = (x - 1.0)^2 + y^2 - 1.0
    return "Viviani's Curve", System([eq1, eq2], variables=[x, y, z]), [2.0, 0.0, 0.0]
end


# ==========================================
# GROUP 4: MATROID REALIZATION SPACES
# ==========================================
function matroid_U24()
    @var x 
    # The realization space of the uniform matroid U(2,4) with gauge fixing.
    # We use a slack variable `z` to enforce the inequality x != 0 and x != 1
    # Note: This is a placeholder for when we build the full Matroid architecture!
    @var z1 z2
    eq1 = z1 * x - 1.0         # Forces x != 0
    eq2 = z2 * (x - 1.0) - 1.0 # Forces x != 1
    
    # We need a valid starting point where x != 0 and x != 1
    p0 = [2.0, 0.5, 1.0] # [x, z1, z2]
    return "Matroid U(2,4)", System([eq1, eq2], variables=[x, z1, z2]), p0
end

function matroid_collinearity_bounded_system(n_points::Int, bounds, collinear_sets::Vector{NTuple{3, Int}})
    (xmin, xmax), (ymin, ymax) = bounds
    
    # Primary variables: n points (x, y)
    vars_xy = Variable[]
    for i in 1:n_points
        push!(vars_xy, Variable("x$i"))
        push!(vars_xy, Variable("y$i"))
    end
    
    # Slack variables: 4 per point (Left, Right, Bottom, Top)
    vars_slacks = Variable[]
    for i in 1:n_points
        push!(vars_slacks, Variable("z_L$i"))
        push!(vars_slacks, Variable("z_R$i"))
        push!(vars_slacks, Variable("z_B$i"))
        push!(vars_slacks, Variable("z_T$i"))
    end
    
    eqs = Expression[]
    
    #  Bounding Box Equations
    for i in 1:n_points
        idx_x = 2*i - 1; idx_y = 2*i
        x_var = vars_xy[idx_x]; y_var = vars_xy[idx_y]
        
        z_L = vars_slacks[4*i - 3]; z_R = vars_slacks[4*i - 2]
        z_B = vars_slacks[4*i - 1]; z_T = vars_slacks[4*i]
        
        push!(eqs, z_L * (x_var - xmin) - 1.0)
        push!(eqs, z_R * (xmax - x_var) - 1.0)
        push!(eqs, z_B * (y_var - ymin) - 1.0)
        push!(eqs, z_T * (ymax - y_var) - 1.0)
    end
    
    #  Strict Collinearity Equations
    for (i, j, k) in collinear_sets
        xi, yi = vars_xy[2*i - 1], vars_xy[2*i]
        xj, yj = vars_xy[2*j - 1], vars_xy[2*j]
        xk, yk = vars_xy[2*k - 1], vars_xy[2*k]
        
        # Cross product / determinant constraint for 2D collinearity
        collinear_eq = (xj - xi)*(yk - yi) - (yj - yi)*(xk - xi)
        push!(eqs, collinear_eq)
    end
    
    all_vars = vcat(vars_xy, vars_slacks)
    sys = System(eqs, variables=all_vars)
    
    return "Collinear Repelling System", sys
end



function matroid_collinearity_system(n_points::Int, collinear_sets::Vector{NTuple{3, Int}}; hard_non_collinearity_relns=false)
    # Primary variables: n points (x, y)
    vars_xy = Variable[]
    for i in 1:n_points
        push!(vars_xy, Variable("x$i"))
        push!(vars_xy, Variable("y$i"))
    end
    
    eqs = Expression[]
    
    # Standardize collinear_sets for easy O(1) lookup. 
    # Sorting ensures (1, 2, 3) is treated the same as (3, 2, 1).
    collinear_lookup = Set(Tuple(sort([c...])) for c in collinear_sets)
    
    # Collinearity Equations
    for (i, j, k) in collinear_sets
        xi, yi = vars_xy[2*i - 1], vars_xy[2*i]
        xj, yj = vars_xy[2*j - 1], vars_xy[2*j]
        xk, yk = vars_xy[2*k - 1], vars_xy[2*k]
        
        collinear_eq = (xj - xi)*(yk - yi) - (yj - yi)*(xk - xi)
        push!(eqs, collinear_eq)
    end
    
    # The non-collinearity conditions
    t_vars = Variable[]
    
    if hard_non_collinearity_relns
        # Iterate over all unique combinations of 3 points
        for i in 1:(n_points - 2)
            for j in (i + 1):(n_points - 1)
                for k in (j + 1):n_points
                    
                    # If this triplet is NOT meant to be collinear, force the determinant away from 0
                    if !((i, j, k) in collinear_lookup)
                        # Create a unique slack variable for this specific non-collinear triplet
                        t_var = Variable("t_$(i)_$(j)_$(k)")
                        push!(t_vars, t_var)
                        
                        xi, yi = vars_xy[2*i - 1], vars_xy[2*i]
                        xj, yj = vars_xy[2*j - 1], vars_xy[2*j]
                        xk, yk = vars_xy[2*k - 1], vars_xy[2*k]
                        
                        det_ijk = (xj - xi)*(yk - yi) - (yj - yi)*(xk - xi)
                        push!(eqs, t_var * det_ijk - 1.0)
                    end
                end
            end
        end
        return "Collinearity system", System(eqs, variables=vcat(vars_xy, t_vars))
    end
    
    return "Collinearity system", System(eqs, variables=vars_xy)
end

# ==========================================
# THE BUNDLER (The Wrapped Groups)
# ==========================================
"""
Returns a Dictionary where the keys are the Group Names, 
and the values are arrays of Geometry Tuples.
"""
function get_geometry_suite()
    return Dict(
        "Plane Curves" => [
            plane_circle(), plane_bicuspid(), plane_lemniscate_gerono(), 
            plane_nephroid(), plane_astroid(), plane_cardioid()
            # Add the rest of your 20 here!
        ],
        
        "Surfaces in R3" => [
            surface_sphere(), surface_torus()
        ],
        
        "Curves in R3" => [
            curve_viviani()
        ],
        
        "Matroids" => [
            matroid_U24()
        ]
    )
end

