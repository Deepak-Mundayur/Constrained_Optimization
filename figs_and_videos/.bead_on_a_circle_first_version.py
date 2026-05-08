from manim import *
import numpy as np

class ConstrainedMotion(Scene):
    def construct(self):
        # 1. ലൂപ്പ് (യൂണിറ്റ് സർക്കിൾ) നിർമ്മിക്കുന്നു
        loop = Circle(radius=2, color=WHITE)
        self.add(loop)

        # തുടക്കത്തിലുള്ള സ്ഥാനവും വെലോസിറ്റിയും
        # p_bead ലൂപ്പിന് മുകളിലുള്ള ഒരു പോയിന്റ് (ഉദാഹരണത്തിന് 45 ഡിഗ്രിയിൽ)
        p_bead = np.array([2 * np.cos(PI/4), 2 * np.sin(PI/4), 0])
        v_bead = np.array([0.0, 0.0, 0.0])
        F = np.array([0, -1.0, 0])
        dt = 1
        N = 100

        # ബീഡ് (ഒരു ചെറിയ ബിന്ദു)
        bead = Dot(point=p_bead, color=RED)
        self.add(bead)

        for i in range(N):
            # --- Substep 1 ---
            # പുതിയ വെലോസിറ്റി: v = v + F * dt
            v_bead = v_bead + F * dt
            
            # താൽക്കാലിക സ്ഥാനം: ptemp = p + v * dt
            ptemp_bead = p_bead + v_bead * dt
            
            # ബീഡ് p_bead-ൽ നിന്ന് ptemp-ലേക്ക് നീങ്ങുന്നു
            self.play(bead.animate.move_to(ptemp_bead), run_time=0.5 / (i + 1)**0.5)

            # --- Substep 2 ---
            # വൃത്തത്തിന്റെ സമവാക്യം ഉപയോഗിച്ച് ഏറ്റവും അടുത്ത പോയിന്റ് (x) കണ്ടെത്തുന്നു
            # x = center + radius * (ptemp - center) / |ptemp - center|
            dist_from_origin = np.linalg.norm(ptemp_bead)
            if dist_from_origin > 0:
                x_point = 2 * (ptemp_bead / dist_from_origin)
            else:
                x_point = p_bead # ഡിവിഷൻ ബൈ സീറോ ഒഴിവാക്കാൻ

            # ptemp-ൽ നിന്ന് x-ലേക്കുള്ള വരി (Line of projection)
            proj_line = Line(ptemp_bead, x_point, color=YELLOW, stroke_width=2)
            temp_dot = Dot(point=x_point, color=BLUE, radius=0.04)
            
            self.add(proj_line, temp_dot)
            self.wait(0.1)

            # വെലോസിറ്റി പ്രൊജക്ഷൻ: വെലോസിറ്റിയെ ലൂപ്പിന് ടാൻജൻഷ്യൽ ആയി മാറ്റുന്നു
            # വൃത്തത്തിന്റെ നോർമൽ വെക്റ്റർ n = x_point / |x_point|
            n = x_point / np.linalg.norm(x_point)
            v_bead = v_bead - np.dot(v_bead, n) * n

            # p_bead അപ്ഡേറ്റ് ചെയ്യുന്നു
            p_bead = x_point
            
            # ബീഡിനെ പുതിയ സ്ഥാനത്തേക്ക് മാറ്റുന്നു, വരി ഒഴിവാക്കുന്നു
            self.play(bead.animate.move_to(p_bead), FadeOut(proj_line), FadeOut(temp_dot), run_time=0.3)

        self.wait(2)
