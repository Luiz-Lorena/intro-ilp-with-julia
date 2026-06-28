# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Section: 5.5.4 - Solving CPP with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package

# Function to plot the solution of the CPP
function plot_solution(graph, partition)
    
    # Vertex fill coloring based on partition
    n = Graphs.nv(graph)

    # Generate distinguishable colors for the groups
    colors = distinguishable_colors(maximum(partition), [colorant"blue", colorant"green", colorant"orange", colorant"purple", colorant"magenta", colorant"lightgreen", colorant"brown", colorant"lightblue"])

    # Assign colors to vertices based on their partition
    vertexfillcolors = [colors[partition[i]] for i in 1:n]
    
    # Draw graph
    @drawsvg begin
        background("white")
        sethue("black")
        fontsize(25)
        drawgraph(
            graph,
            layout = stress,
            vertexshapesizes = 20,
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