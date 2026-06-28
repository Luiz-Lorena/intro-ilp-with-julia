# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 4 – Traveling Salesman Problem
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using PythonCall: pyimport, pyconvert # for Python map plot (folium, geopandas)
using HDF5       # For reading HDF5 files

# Convert a pair of nodes (i, j) to a route index
function pair_to_index(i::Int, j::Int, n::Int)
    i == j && error("Self-loop at ($i, $j) is not allowed.")
    base = (i - 1) * (n - 1)
    offset = j < i ? j - 1 : j - 2
    return base + offset + 1
end

# Plot TSP solution on a map
function plot_tsp_solution(file_path::String, solution::Matrix{Float64})
    locations_geometry = h5read(file_path, "locations_geometry")
    routes_geometry = h5read(file_path, "routes_geometry")

    folium = pyimport("folium")
    gpd = pyimport("geopandas")

    # Load the locations geometry data into a GeoDataFrame
    # Passamos um vetor Julia de strings; o PythonCall converte implicitamente no argumento
    locations_gdf = gpd.GeoDataFrame(
        geometry=gpd.GeoSeries.from_wkt(locations_geometry)
    )

    # Import folium library and create map
    fmap = folium.Map(tiles="Cartodb Positron")

    # Map Limits: We explicitly convert to Float64 using pyconvert because Julia's minimum() expects native elements, not objects of type 'Py'
    lat_min = minimum(pyconvert(Vector{Float64}, locations_gdf.geometry.y))
    lon_min = minimum(pyconvert(Vector{Float64}, locations_gdf.geometry.x))
    lat_max = maximum(pyconvert(Vector{Float64}, locations_gdf.geometry.y))
    lon_max = maximum(pyconvert(Vector{Float64}, locations_gdf.geometry.x))

    # Fit map to bounds of coordinates
    bounds = ((lat_min, lon_min), (lat_max, lon_max))
    fmap.fit_bounds(bounds, padding=(100, 100))
    
    # Add locations to the map with icons
    # Usamos pyconvert para transformar a Series do Pandas em um Vector de objetos Py do Julia
    geometry_list = pyconvert(Vector, locations_gdf["geometry"])
    for (id, point) in enumerate(geometry_list)
        lat = pyconvert(Float64, point.y)
        lon = pyconvert(Float64, point.x)
        folium.Marker(
            location=(lat, lon),
            tooltip="Location $id",
            icon=folium.Icon(color="blue", 
                             icon="$id", 
                             prefix="fa")).add_to(fmap)
    end

    # Load routes geometry from HDF5 file
    routes_geometry = h5read(file_path, "routes_geometry")

    # Create a GeoDataFrame for routes
    routes_gdf = gpd.GeoDataFrame(
        geometry=gpd.GeoSeries.from_wkt(routes_geometry),
        crs="EPSG:4326",
    )

    # Add solution path to the map
    n = size(solution, 1)
    for i in 1:n, j in 1:n
        if i != j && solution[i, j] > 0.5
            # Get the index for the route from i to j
            idx = pair_to_index(i, j, n)
            
            # In PythonCall, to access iloc, we adjust the index (0-based in Python) and search for the element in the series.
            route_geom = routes_gdf.geometry.iloc[idx - 1]
            
            # PythonCall converts coordinates directly to a Tuple Vector{Float64, Float64}
            # In the format (longitude, latitude)
            coords = pyconvert(Vector{Tuple{Float64, Float64}}, route_geom.coords)

            # We inverted to (latitude, longitude) using Julia indices 1 and 2.
            locations_list = [(c[2], c[1]) for c in coords]

            # Add the route to the map
            folium.PolyLine(
                locations=locations_list,
                color="blue",
                weight=2.5,
                opacity=0.8,
                tooltip="Path from $i to $j",
            ).add_to(fmap)
        end
    end
    return fmap
end