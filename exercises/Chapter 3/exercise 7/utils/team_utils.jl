using PyCall # 

function plot_solution(file_path, xBasic_opt, xAdvanced_opt, y_opt)

    # Install required Python packages if missing
    try
        pyimport("folium")
        pyimport("geopandas")
        pyimport("shapely")
    catch
        run(`$(PyCall.python) -m pip install folium geopandas shapely`)
    end

    # Load the data from HDF5 file
    districts_ids = h5read(file_path, "districts_ids")
    districts_population = h5read(file_path, "districts_population")
    districts_geometry = h5read(file_path, "districts_geometry")
    facilities_geometry = h5read(file_path, "facilities_geometry")

    folium = pyimport("folium")
    gpd = pyimport("geopandas")
    shapely_wkt = pyimport("shapely.wkt")

    # Convert geometry from WKT to shapely objects if needed
    if typeof(districts_geometry[1]) <: AbstractString
        py_geoms = [shapely_wkt.loads(wkt) for wkt in districts_geometry]
    else
        py_geoms = districts_geometry
    end

    # Create a GeoDataFrame for districts
    districts_gdf = gpd.GeoDataFrame(Dict(
        "Id" => districts_ids,
        "Population" => districts_population,
        "geometry" => py_geoms,
        "Covered" => y_opt .> 0.5#[round(y_opt[i]) for i in 1:length(y_opt)]
    ))
    # Set the coordinate reference system (CRS) if known
    districts_gdf.crs = "EPSG:4326"  # Assuming WGS84 coordinates

    map = districts_gdf.explore(
        tiles="CartoDB Positron",
        column="Covered",
        cmap="RdYlGn",
        legend=true,
        tooltip=["Id", "Population"]
    )

    # Convert geometry from WKT to shapely objects if needed
    if typeof(facilities_geometry[1]) <: AbstractString
        py_geoms = [shapely_wkt.loads(wkt) for wkt in facilities_geometry]
    else
        py_geoms = facilities_geometry
    end

    # Create a GeoDataFrame for facilities
    facilities_gdf = gpd.GeoDataFrame(Dict(
        "geometry" => py_geoms
    ))
    facilities_gdf.crs = "EPSG:4326"  # Assuming WGS84 coordinates

    # Add ambulance facilities to the map with icons and color coding
    facilities = length(facilities_gdf)
    for i in 1:facilities
        sol_basic = round(xBasic_opt[i]) == 1
        sol_advanced = round(xAdvanced_opt[i]) == 1

        # Determine color and popup description
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

        # Get coordinates for the facility
        lat = facilities_gdf[:geometry][i].y
        lon = facilities_gdf[:geometry][i].x
        
        folium.Marker(
            location=[lat, lon],
            tooltip="Facility $i) Basic: $(sol_basic ? 1 : 0) | Advanced: $(sol_advanced ? 1 : 0)",
            popup=folium.Popup(popup, max_width=250),  # Set max_width to control popup width
            icon=folium.Icon(color=color, icon="fa-ambulance", prefix="fa")
        ).add_to(map) 
    end

    return map

end