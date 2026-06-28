# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 6 – Column Generation
#  Exercise: 6.3 - Column Generation for GCP
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # For graph visualization
using Colors # For color handling
using Plots  # For plotting

# Function to plot the convergence of reduced costs
function gcp_plot_reduced_costs(reduced_cost_history)
    p = Plots.plot(
        1:length(reduced_cost_history), 
        reduced_cost_history,
        label="Minimum Reduced Cost",
        xlabel="Iteration",
        ylabel="Reduced Cost",
        title="Convergence of the Pricing Subproblem",
        legend=:bottomright,
        linewidth=2
    )
    # Add a horizontal line at y=0 to show the convergence target
    Plots.hline!(p, [0], linestyle=:dash, color=:red, label="Optimality Threshold (RC=0)")
    # Display the plot
    display(p)
end

# Function to print the graph solution
function gcp_plot_solution(graph, solution = nothing)
    n = Graphs.nv(graph)
    if isnothing(solution)
        vertexfillcolors = fill(Colors.RGB(0, 0, 0), n)
    else
        colors = distinguishable_colors(maximum(solution), [colorant"blue", colorant"green", colorant"orange", colorant"purple", colorant"magenta", colorant"lightgreen", colorant"brown", colorant"lightblue"])
        vertexfillcolors = [colors[solution[v]] for v in 1:n]
    end
    # Layout
    d = Graphs.degree(graph)
    n = Graphs.nv(graph)
    M = zeros(n, n)
    for i in 1:n, j in 1:n
        if Graphs.has_edge(graph, i, j)
            M[i, j] = 1 / (d[i] * d[j]) # Inverse of the product of degrees for adjacent vertices
        else
            M[i, j] = 0.01 # Small value for non-adjacent vertices to encourage separation
        end
    end
    # Draw graph
    @drawsvg begin
        background("white")
        sethue("black")
        fontsize(14)
        drawgraph(
            graph,
            layout = Stress(iterations = 100, weights = M),
            vertexshapesizes = 10,
            vertexlabels = 1:n,
            vertexfillcolors = vertexfillcolors
        )
    end
end