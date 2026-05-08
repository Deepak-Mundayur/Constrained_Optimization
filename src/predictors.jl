# ==========================================
# PREDICTORS (Moving out from the manifold)
# ==========================================

function ambient_predictor(pos, v, field_val, dt, H_system, field_type)
    v_new = (field_type == :force) ? (v + field_val * dt) : field_val
    pos_temp = pos + v_new * dt
    return pos_temp, v_new
end

function tangent_predictor(pos, v, field_val, dt, H_system, field_type)
    if field_type == :force
        field_proj = project_to_tangent(field_val, pos, H_system)
        v_new = v + field_proj * dt
    else # :velocity
        v_new = project_to_tangent(field_val, pos, H_system)
    end
    pos_temp = pos + v_new * dt
    return pos_temp, v_new
end


