using PyCall  # For Python map plot (folium)
using HDF5    # For reading HDF5 files

# Function to convert a pair of nodes (i, j) to a route index
function pair_to_index(i::Int, j::Int, n::Int=10)
    if i == j
        error("Self-loop at ($i, $j) is not allowed.")
    end
    base = (i - 1) * (n - 1)
    offset = j < i ? j - 1 : j - 2
    return base + offset + 1  # shift back to 1-based
end

# Function to plot TSP solution on a map
function plot_tsp_solution(file_path::String, solution::Matrix{Float64})
    
    # Install required Python packages if missing
    try
        pyimport("folium")
        pyimport("geopandas")
        pyimport("shapely")
    catch
        run(`$(PyCall.python) -m pip install folium geopandas shapely`)
    end

    # Load the data from HDF5 file
    locations_geometry = h5read(file_path, "locations_geometry")

    # Import python folium, geopandas and shapely libraries
    folium = pyimport("folium")
    folium_plugins = pyimport("folium.plugins")
    gpd = pyimport("geopandas")
    shapely_wkt = pyimport("shapely.wkt")

    # Convert geometry from WKT to shapely objects if needed
    if typeof(locations_geometry[1]) <: AbstractString
        py_geoms = [shapely_wkt.loads(wkt) for wkt in locations_geometry]
    else
        py_geoms = locations_geometry
    end

    # Create a GeoDataFrame for locations
    locations_gdf = gpd.GeoDataFrame(Dict(
        "geometry" => py_geoms
    ))
    # Set the coordinate reference system (CRS) if known
    locations_gdf.crs = "EPSG:4326"  # Assuming WGS84 coordinates

    # Map Limits
    lat_min = minimum(locations_gdf.geometry.y)
    lon_min = minimum(locations_gdf.geometry.x)
    lat_max = maximum(locations_gdf.geometry.y)
    lon_max = maximum(locations_gdf.geometry.x)

    # Import folium library and create map
    map = folium.Map(tiles="Cartodb Positron")
    bounds = [(lat_min,lon_min), (lat_max,lon_max)]
    map.fit_bounds(bounds,padding=(130,130))

    # Add locations to the map with icons
    locations = length(locations_gdf)
    for id in 1:locations
        lat = locations_gdf[:geometry][id].y
        lon = locations_gdf[:geometry][id].x
        folium.Marker(
            location=[lat, lon],
            tooltip="Location $id",
            icon=folium.Icon(color="blue", icon="$id", prefix="fa")
        ).add_to(map) 
    end

    # Load routes geometry from HDF5 file
    routes_geometry = h5read(file_path, "routes_geometry")
    
    # Convert routes geometry from WKT to shapely objects if needed
    if typeof(routes_geometry[1]) <: AbstractString
        py_geoms = [shapely_wkt.loads(wkt) for wkt in routes_geometry]
    else
        py_geoms = routes_geometry
    end
    
    # Create a GeoDataFrame for routes
    routes_gdf = gpd.GeoDataFrame(Dict(
        "geometry" => py_geoms
    ))
    
    # Set the coordinate reference system (CRS) if known
    routes_gdf.crs = "EPSG:4326"  # Assuming WGS84 coordinates

    # Add solution path to the map
    n = size(solution, 1)
    for i in 1:n
        for j in 1:n
            if i != j && solution[i, j] > 0.5
                
                # Get the index for the route from i to j
                index = pair_to_index(i, j, n)

                # Get the geometry for the route
                route_geom = routes_gdf["geometry"][index]

                # Add the route to the map
                line = folium.PolyLine(
                    locations=[[r[2], r[1]] for r in route_geom.coords],
                    color="blue",
                    weight=2.5,
                    opacity=0.8,
                    tooltip="Path from $i to $j"
                ).add_to(map)
            end
        end
    end
    return map
end