# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 5 – Graph Problems
#  Exercise: 5.3 - Solving GCP with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Karnak # Graphs Visualization package
using Colors # Colors package
using Images # Image processing
using PythonCall # Modern Python interoperability

# Function to plot the graph solution
function plot_solution_graph(graph, map_background_file, solution)

    chromatic_number = length(unique(solution))

    # Number of vertices in the graph
    n = Graphs.nv(graph)

    # Create colors and assign to vertices
    colors = Colors.distinguishable_colors(chromatic_number, 
                                           [RGB(0.1, 0.9, 0.2), 
                                            RGB(0, 0.2, 0.4), 
                                            RGB(0.6, 0.1, 0.5)])

    # Add colors to each vertex group
    vertexfillcolors = [colors[solution[i]] for i in 1:n]
    
    # Vertices positions for the layout
    vertexpositions = [Point(-115, -118), Point(-250, -48), Point(-65, -80),
                       Point(-100, -60), Point(-53, -40), Point(-95, -35),
                       Point(-33, -12), Point(45, -55), Point(20, -100),
                       Point(80, -10), Point(25, 0), Point(48, 43),
                       Point(-15, 50), Point(10, 165), Point(-65, 235),
                       Point(-57, 120), Point(-60, 80), Point(-93, 140),
                       Point(-138, 140), Point(-136, 81), Point(-195, 120),
                       Point(-200, -20), Point(-185, 65), Point(-73, 20),
                       Point(-35, -200), Point(20, -180), Point(-120, 0),
                       Point(160, -50), Point(-27, 120), Point(85, 140),
                       Point(135, 80), Point(165, -122), Point(155, -180),
                       Point(250, 40)]

    # Load background image (map)
    img = load(map_background_file)

    # Plot graph with colored vertices
    fig_solution = @drawsvg begin
        background("white")
        sethue("black")
        fontsize(14)
        placeimage(img, O - Point(60, -60); centered = true, alpha = 0.5)
        drawgraph(
            graph,
            vertexshapesizes = 10,
            vertexfillcolors = vertexfillcolors,
            vertexlabels = 1:n,
            layout = vertexpositions
        )
    end 700 560

    return fig_solution
end

# Function to plot the map with colored districts
function plot_solution_map(map_file, solution)
    
    # Number of vertices in the graph
    n = length(solution)

    # Calculate the chromatic number (number of unique colors used in the solution)
    chromatic_number = length(unique(solution))

    # Create colors and assign to vertices
    colors = Colors.distinguishable_colors(chromatic_number, 
                                           [RGB(0.1, 0.9, 0.2), 
                                            RGB(0, 0.2, 0.4), 
                                            RGB(0.6, 0.1, 0.5)])

    # Add colors to each vertex group
    vertexfillcolors = [colors[solution[i]] for i in 1:n]

    # Import geopandas via PythonCall
    gpd = pyimport("geopandas")

    # Load the GeoJSON file into a GeoDataFrame
    districts_gdf = gpd.read_file(map_file)

    # Create hex colors for each district
    color_values = ["#" * Colors.hex(c) for c in vertexfillcolors]

    # Convert Julia Dict and Vector to Python equivalents for compatibility
    py_colors = pylist(color_values)
    py_style_kwds = pydict(Dict("fillOpacity" => 0.9, "weight" => 1))
    py_tooltip = pylist(["Id"])

    # Create a map with colored districts
    fmap = districts_gdf.explore(
        tiles = "CartoDB Positron",
        color = py_colors,       # converted to python list
        legend = false,
        tooltip = py_tooltip,    # converted to python list
        style_kwds = py_style_kwds # converted to python dict
    )
    return fmap
end