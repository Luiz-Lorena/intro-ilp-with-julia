# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 7 – Lagrangian Relaxation
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Plots # For plotting

# Function to plot convergence of LB and UB
function plot_convergence(title,lb_history, ub_history, legend_position=:bottomright)
    p = plot(1:length(lb_history), [lb_history ub_history],
        label=["Lower Bound (LB)" "Upper Bound (UB)"],
        xlabel="Iteration",
        ylabel="Objective Value",
        title=title,
        linewidth=2,
        linestyle=[:dash :solid],
        legend=legend_position)
    display(p)
end