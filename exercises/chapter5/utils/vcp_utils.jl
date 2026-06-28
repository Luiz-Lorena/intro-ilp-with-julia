# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Exercise: 5.2 - Solving VCP with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package

# Function to plot the solution
function plot_solution(graph, positions, C)
    # Compute bounding box and center
    xmin = minimum(p.x for p in positions)
    xmax = maximum(p.x for p in positions)
    ymin = minimum(p.y for p in positions)
    ymax = maximum(p.y for p in positions)

    # Calculate the center point of the bounding box
    center_pt = Point((xmin + xmax)/2, (ymin + ymax)/2)

    # Draw graph
    n = Graphs.nv(graph)
    fig_solution = @drawsvg begin
        background("white")
        sethue("black")
        fontsize(16)
        translate(O - center_pt) # Center the layout
        drawgraph(
            graph,
            layout = positions,
            vertexshapesizes = 12,
            vertexlabels = 1:n,
            vertexfillcolors = [i in C ? Colors.RGB(1,0,0) : Colors.RGB(0,0,0) for i in 1:n]
        )
    end 350 300
    return fig_solution
end