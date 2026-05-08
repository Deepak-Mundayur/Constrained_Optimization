
# ==========================================
# GROUP 1: PLANE CURVES (2D)
# ==========================================
function plane_circle()
    @var x y
    return "Circle", System([x^2 + y^2 - 1.0], variables=[x, y]), [0.0, 1.0]
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