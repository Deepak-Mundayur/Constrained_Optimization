from manim import *
import numpy as np

class ConstrainedMotionAlgo2(Scene):
    def construct(self):
        # 1. Setup the Loop (Unit Circle with radius 2)
        loop = Circle(radius=2, color=WHITE)
        self.add(loop)

        # Initial conditions
        # Starting p_bead on the loop at 45 degrees
        p_bead = np.array([2 * np.cos(PI/4), 2 * np.sin(PI/4), 0])
        v_bead = np.array([0.0, 0.0, 0.0])
        F_original = np.array([0, -0.1, 0])  # Gravity-like force
        dt = 1
        N = 100

        # Create the Bead (Red Dot)
        bead = Dot(point=p_bead, color=RED)
        self.add(bead)

        for i in range(N):
            # --- Substep 1 (Algorithm 2) ---
            # Calculate the normal vector at the current position
            n_current = p_bead / np.linalg.norm(p_bead)
            
            # Project the original force onto the tangent of the loop
            # Force tang = Force - (Force . normal) * normal
            F_proj = F_original - np.dot(F_original, n_current) * n_current
            
            # Update velocity using the projected force: v = v + F_proj * dt
            v_bead = v_bead + F_proj * dt
            
            # Calculate temporary position: ptemp = p + v * dt
            ptemp_bead = p_bead + v_bead * dt
            
            # Animate movement from p_bead to ptemp_bead
            self.play(
                bead.animate.move_to(ptemp_bead), 
                run_time=0.4 / (1 + i*0.05)
            )

            # --- Substep 2 (Same as Algorithm 1) ---
            # Find the closest point 'x' on the circle to ptemp_bead
            dist_from_origin = np.linalg.norm(ptemp_bead)
            if dist_from_origin > 0:
                x_point = 2 * (ptemp_bead / dist_from_origin)
            else:
                x_point = p_bead

            # Visualize the projection line and the target point x
            proj_line = Line(ptemp_bead, x_point, color=YELLOW, stroke_width=2)
            target_dot = Dot(point=x_point, color=BLUE, radius=0.04)
            
            self.add(proj_line, target_dot)
            self.wait(0.1)

            # Project velocity after the move: V = V - (V . normal) * normal
            # (normal at new projection point x)
            n_new = x_point / np.linalg.norm(x_point)
            v_bead = v_bead - np.dot(v_bead, n_new) * n_new

            # Update p_bead to the new point x on the loop
            p_bead = x_point
            
            # Animate the bead snapping back to the loop and cleaning up visuals
            self.play(
                bead.animate.move_to(p_bead), 
                FadeOut(proj_line), 
                FadeOut(target_dot), 
                run_time=0.2
            )

        self.wait(2)
