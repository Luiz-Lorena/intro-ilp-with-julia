# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Exercise: 5.4 - Solving GPP with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package
using Images # Image processing

# Function to plot the solution
function plot_solution(graph, partitions, y, k; circuit_background = nothing)
    
    # Use distinguishable_colors for better color selection
    n = Graphs.nv(graph)
    m = Graphs.ne(graph)

    # Create colors and assign to vertices
    colors = Colors.distinguishable_colors(k, 
                                           [RGB(0, 0.2, 0.4),
                                            RGB(0.1, 0.9, 0.2), 
                                            RGB(0.6, 0.1, 0.5)])
    
    # Assign colors to vertices based on their partition
    vertexfillcolors = fill(Colors.RGB(0,0,0), n)
    for id in 1:k
        vertexfillcolors[partitions[id]] .= colors[id]
    end

    # Prepare edge colors and weights
    edgestrokecolors = fill(Colors.RGB(0,0,0), m)
    edgestrokeweights = fill(1, m)
    for (e_id, e) in enumerate(Graphs.edges(graph))
        if JuMP.value(y[e_id]) > 0.5
            edgestrokecolors[e_id] = Colors.RGB(1, 0, 0)
            edgestrokeweights[e_id] = 3
        end
    end

    # Vertices positions (for visualization)
    pos = [
        Point(-628, -190), Point(-625, -100), Point(-625, -10), Point(-625, 80),
        Point(-625, 160), Point(-625, 240), Point(-477, -210), Point(-477, -100),
        Point(-477, -10), Point(-487, 70), Point(-485, 200), Point(-340, -180),
        Point(-355, -60), Point(-350, 70), Point(-345, 160), Point(-347, 240),
        Point(-205, -190), Point(-195, -70), Point(-190, 20), Point(-197, 100),
        Point(-187, 240), Point(-37, -200), Point(-35, -120), Point(-37, -30),
        Point(-30, 100), Point(-37, 190), Point(80, -160), Point(85, -60),
        Point(80, 60), Point(95, 160), Point(93, 240), Point(193, -200),
        Point(203, -120), Point(203, -50), Point(210, 30), Point(205, 200),
        Point(355, -160), Point(355, -40), Point(353, 50), Point(350, 140),
        Point(333, 240), Point(475, -100), Point(473, 10), Point(473, 200),
        Point(570, -65), Point(615, 30), Point(615, 160), Point(733, 90)
    ]

    # Draw graph
    fig_solution = @drawsvg begin
        background("white")
        sethue("black")
        fontsize(18)
        if !isnothing(circuit_background)
            img = load(circuit_background)
            placeimage(img, O + Point(-540, 540); centered=true, alpha=0.1)
        end
        drawgraph(
            graph,
            layout = pos,
            vertexshapesizes = 12,
            vertexlabels = 1:n,
            vertexfillcolors = vertexfillcolors,
            edgestrokecolors = edgestrokecolors,
            edgestrokeweights = edgestrokeweights,
            edgecurvature = 20
        )
    end 1620 550

    return fig_solution
end