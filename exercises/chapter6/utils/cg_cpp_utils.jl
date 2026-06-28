# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 6 – Column Generation
#  Exercise: 6.2 - Column Generation for CPP
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package
using Plots  # For plotting convergence of reduced costs

# Function to plot the convergence of reduced costs
function cpp_plot_reduced_costs(reduced_cost_history)
    p = Plots.plot(
        1:length(reduced_cost_history), 
        reduced_cost_history,
        label="Minimum Reduced Cost",
        xlabel="Iteration",
        ylabel="Reduced Cost",
        title="Convergence of the Pricing Subproblem",
        legend=:topright,
        linewidth=2
    )
    # Add a horizontal line at y=0 to show the convergence target
    Plots.hline!(p, [0], linestyle=:dash, color=:red, label="Optimality Threshold (RC=0)")
    # Display the plot
    display(p)
end

# Function to plot the solution of the CPP
function cpp_plot_solution(graph, partition)
    
    # Vertex fill coloring based on partition
    n = Graphs.nv(graph)
    if maximum(partition) == 1
        vertexfillcolors = fill(Colors.RGB(0, 0, 0), n)
        colors = fill(Colors.RGB(0, 0, 0), 1)
    else
        # Generate distinguishable colors for the groups
        colors = Colors.distinguishable_colors(maximum(partition), [colorant"blue", colorant"green", colorant"orange", colorant"purple", colorant"magenta", colorant"lightgreen", colorant"brown", colorant"lightblue"])

        # Assign colors to vertices based on their partition
        vertexfillcolors = [colors[partition[i]] for i in 1:n]
    end
    # Draw graph
    @drawsvg begin
        background("white")
        sethue("black")
        fontsize(18)
        drawgraph(
            graph,
            layout = stress,
            vertexshapesizes = 12,
            vertexlabels = 1:n,
            vertexfillcolors = vertexfillcolors,
            edgestrokecolors = (n, from, to, src, dst) -> begin
                # src and dst are vertex indices
                if partition[from] == partition[to]
                    # same color as partition
                    colors[partition[from]]  
                else
                    # inter-cluster edges
                    colorant"black"
                end
            end,
            edgestrokeweights = (n, from, to, src, dst) -> begin
                # src and dst are vertex indices
                if partition[from] == partition[to]
                    # same weight as partition
                    3.0  
                else
                    # inter-cluster edges
                    1.0 
                end
            end
        )
    end
end