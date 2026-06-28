# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Section: 5.4.4 - Solving GPP using Metis
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # For color handling

# Function to plot the graph with partitions
function plot_solution(graph, partition, edge_cuts, k)
    # Create a vector of k different colors
    n = Graphs.nv(graph)
    m = Graphs.ne(graph)
    
    # Generate distinguishable colors for the groups
    colors = distinguishable_colors(k, [colorant"blue", colorant"green"])

    # Assign colors to vertices based on their partition
    vertexfillcolors = [colors[partition[v]] for v in 1:n]

    # Prepare edge colors and weights
    edgestrokecolors = fill(Colors.RGB(0,0,0), m)
    edgestrokeweights = fill(1, m)
    for (e_id, _) in enumerate(Graphs.edges(graph))
        if edge_cuts[e_id]
            edgestrokecolors[e_id] = Colors.RGB(1, 0, 0)
            edgestrokeweights[e_id] = 3
        end
    end

    # Draw the graph with partitions
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
            edgestrokecolors = edgestrokecolors,
            edgestrokeweights = edgestrokeweights
        )
    end
end