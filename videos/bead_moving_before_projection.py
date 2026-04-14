from manim import *
import numpy as np

class ConstrainedMotion(Scene):
    def construct(self):
        # 1. Setup the Loop (Unit Circle with radius 2)
        loop = Circle(radius=2, color=WHITE)
        self.add(loop)

        # Initial conditions
        # Starting p_bead on the loop at 45 degrees
        p_bead = np.array([2 * np.cos(PI/4), 2 * np.sin(PI/4), 0])
        v_bead = np.array([0.0, 0.0, 0.0])
        F = np.array([0, -0.1, 0])  # Gravity-like force
        dt = 1
        N = 20

        # Create the Bead (Red Dot)
        bead = Dot(point=p_bead, color=RED)
        self.add(bead)

        for i in range(N):
            # --- Substep 1 ---
            # Update velocity: v = v + F * dt (assuming mass = 1)
            v_bead = v_bead + F * dt
            
            # Calculate temporary position: ptemp = p + v * dt
            ptemp_bead = p_bead + v_bead * dt
            
            # Animate movement from p_bead to ptemp_bead
            # Reducing run_time slightly to keep the animation snappier as N increases
            self.play(
                bead.animate.move_to(ptemp_bead), 
                run_time=0.4 / (1 + i*0.05)
            )

            # --- Substep 2 ---
            # Find the closest point 'x' on the circle to ptemp_bead
            # Since it's a circle centered at origin: x = radius * unit(ptemp)
            dist_from_origin = np.linalg.norm(ptemp_bead)
            if dist_from_origin > 0:
                x_point = 2 * (ptemp_bead / dist_from_origin)
            else:
                x_point = p_bead # Avoid division by zero

            # Visualize the projection line and the target point x
            proj_line = Line(ptemp_bead, x_point, color=YELLOW, stroke_width=2)
            target_dot = Dot(point=x_point, color=BLUE, radius=0.04)
            
            self.add(proj_line, target_dot)
            self.wait(0.1)

            # Update velocity to the appropriate projection (tangential to the loop)
            # Normal vector n at x_point
            n = x_point / np.linalg.norm(x_point)
            # Project velocity: v_new = v_old - (v_old . n) * n
            v_bead = v_bead - np.dot(v_bead, n) * n

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
