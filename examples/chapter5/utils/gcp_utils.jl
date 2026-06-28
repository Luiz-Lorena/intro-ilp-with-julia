# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Section: 5.3.3 - Solving GCP with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package

# Function to plot the solution
function plot_solution(graph, groups)
    # Number of vertices
    n = Graphs.nv(graph)
    
    # Generate distinguishable colors for the groups
    colors = distinguishable_colors(size(groups,1), [colorant"blue", colorant"green"])

    # Initialize vertex fill colors with default color (black)
    vertexfillcolors = fill(Colors.RGB(0.0, 0.0, 0.0), n)
    
    # Add colors to group vertices
    for (id, group) in enumerate(groups)
        for vertex in group
            vertexfillcolors[vertex] = colors[id]
        end
    end

    # Draw graph
    @drawsvg begin
        background("white")
        sethue("black")
        fontsize(25)
        drawgraph(
            graph,
            layout = shell,
            vertexshapesizes = 20,
            vertexlabels = 1:n,
            vertexfillcolors = vertexfillcolors
        )
    end
end