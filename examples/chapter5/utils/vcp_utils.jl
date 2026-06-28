# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Section: 5.2.4 - Solving VCP with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package

# Function to plot the solution
function plot_solution(graph, C)
    # Create color vector
    n = Graphs.nv(graph)
    vertexfillcolors = [i in C ? Colors.RGB(1,0,0) : Colors.RGB(0,0,0) for i in 1:n]
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
            vertexfillcolors = vertexfillcolors
        )
    end
end