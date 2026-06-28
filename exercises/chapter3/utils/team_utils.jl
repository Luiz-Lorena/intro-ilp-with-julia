# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 3 – Location problems
#  Exercise: 3.7 – Formulate the mathematical model known as TEAM model
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

# For Python map plot (folium)
using PythonCall
using HDF5 # For data handling

# Function to plot the solution on a map using Folium
function plot_solution(file_path, xBasic_opt, xAdvanced_opt, y_opt)

    # Import Python packages
    folium = pyimport("folium")
    gpd = pyimport("geopandas")
    shapely_wkt = pyimport("shapely.wkt")

    # Load the data from HDF5 file
    districts_ids = h5read(file_path, "districts_ids")
    districts_population = h5read(file_path, "districts_population")
    districts_geometry = h5read(file_path, "districts_geometry")
    facilities_geometry = h5read(file_path, "facilities_geometry")

    # Convert geometry from WKT to shapely objects if needed
    if districts_geometry[1] isa AbstractString
        py_geoms = pylist([shapely_wkt.loads(wkt) for wkt in districts_geometry])
    else
        py_geoms = Py(districts_geometry)
    end

    # Create a GeoDataFrame for districts
    districts_dict = pydict(Dict(
        "Id" => districts_ids,
        "Population" => districts_population,
        "geometry" => py_geoms,
        "Covered" => y_opt .> 0.5
    ))

    districts_gdf = gpd.GeoDataFrame(districts_dict)

    # Set CRS
    districts_gdf.crs = "EPSG:4326"

    fmap = districts_gdf.explore(
        tiles="CartoDB Positron",
        column="Covered",
        cmap="RdYlGn",
        legend=true,
        tooltip=["Id", "Population"]
    )

    # Convert facility geometries from WKT if needed
    if facilities_geometry[1] isa AbstractString
        py_geoms = pylist([shapely_wkt.loads(wkt) for wkt in facilities_geometry])
    else
        py_geoms = Py(facilities_geometry)
    end

    # Create facilities GeoDataFrame
    facilities_dict = pydict(Dict(
        "geometry" => py_geoms
    ))

    facilities_gdf = gpd.GeoDataFrame(facilities_dict)
    facilities_gdf.crs = "EPSG:4326"

    # Add ambulance facilities to the map
    facilities = length(facilities_gdf)

    for i in 1:facilities

        sol_basic = round(xBasic_opt[i]) == 1
        sol_advanced = round(xAdvanced_opt[i]) == 1

        # Determine color and popup
        if sol_basic && sol_advanced
            color = "green"
            popup = "Facility $i) Basic: 1 | Advanced: 1"

        elseif sol_basic
            color = "orange"
            popup = "Facility $i) Basic: 1 | Advanced: 0"

        elseif sol_advanced
            color = "orange"
            popup = "Facility $i) Basic: 0 | Advanced: 1"

        else
            color = "red"
            popup = "Facility $i) Basic: 0 | Advanced: 0"
        end

        # Access shapely geometry
        geom = pyconvert(Py, facilities_gdf.geometry.iloc[i - 1])

        lat = pyconvert(Float64, geom.y)
        lon = pyconvert(Float64, geom.x)

        marker = folium.Marker(
            location=[lat, lon],
            tooltip="Facility $i) Basic: $(sol_basic ? 1 : 0) | Advanced: $(sol_advanced ? 1 : 0)",
            popup=folium.Popup(popup, max_width=250),
            icon=folium.Icon(
                color=color,
                icon="fa-ambulance",
                prefix="fa"
            )
        )

        marker.add_to(fmap)
    end

    return fmap
end