# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Section: 5.4.5 - Weighted Graph Partitioning Problem
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package

# Function to plot the solution
function plot_solution(graph, partitions, edge_cuts, k)
    # Use distinguishable_colors for better color selection
    n = Graphs.nv(graph)
    m = Graphs.ne(graph)

    # Generate distinguishable colors for the groups
    colors = distinguishable_colors(k, [colorant"blue", colorant"green"])

    # Assign colors to vertices based on their partition
    vertexfillcolors = fill(Colors.RGB(0,0,0), n)
    for id in 1:k
        for v in partitions[id] 
            vertexfillcolors[v] = colors[id]
        end
    end

    # Prepare edge colors and weights
    edgestrokecolors = fill(Colors.RGB(0,0,0), m)
    edgestrokeweights = fill(1, m)
    for (e_id, e) in enumerate(Graphs.edges(graph))
        if edge_cuts[e_id]
            edgestrokecolors[e_id] = Colors.RGB(1, 0, 0)
            edgestrokeweights[e_id] = 3
        end
    end

    # Draw graph
    @drawsvg begin
        background("white")
        sethue("black")
        fontsize(25)
        drawgraph(
            graph,
            layout = spring,
            vertexshapesizes = 20,
            vertexlabels = 1:n,
            vertexfillcolors = vertexfillcolors,
            edgestrokecolors = edgestrokecolors,
            edgestrokeweights = edgestrokeweights,
            edgelabels = [Int(graph.weights[e.src, e.dst]) for e in Graphs.edges(graph)]
        )
    end
end