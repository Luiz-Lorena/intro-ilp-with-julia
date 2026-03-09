using Graphs                # For graph data structures
using SimpleWeightedGraphs  # For weighted graphs
using Karnak                # For drawing graphs
using Colors                # For color manipulation

# Utility functions for TSP solution plotting
function plot_tsp_solution(points, x_opt)
    # Extract the route from the solution
    route = [(coord[1], coord[2]) for coord in findall(x_opt .> 0.5)]

    # Create a weighted directed graph with n vertices
    g = SimpleWeightedGraph(points.From, points.To, points.Distance)

    # Define a function to check if an edge is part of the route
    function is_in_route(e, route)
        return (e.src, e.dst) in route || (e.dst, e.src) in route ? true : false
    end

    # Draw graph
    @drawsvg begin
        background("white")
        sethue("black")
        fontsize(20)
        drawgraph(
            g,
            vertexshapesizes = 12,
            vertexlabels = 1:nv(g),
            edgelabels = [g.weights[e.src, e.dst] for e in edges(g)],
            edgelabelfontsizes = 18,
            edgestrokecolors = [is_in_route(e, route) ? RGB(1, 0, 0) : RGB(0, 0, 0) for e in edges(g)],
            edgestrokeweights = [is_in_route(e, route) ? 3 : 1 for e in edges(g)]
        )
    end
end