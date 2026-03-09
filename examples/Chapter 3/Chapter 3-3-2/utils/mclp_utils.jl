using PyCall # For Python map plot (folium, pyproj)

# Function to plot solution on map
function plot_solution(selected_facilities, covered_points, coordinates, radius)
    # Ensure folium is installed
    try
        pyimport("folium")
    catch
        run(`$(PyCall.python) -m pip install folium`)
    end
    
    # Import folium library
    folium = pyimport("folium")

    # Create map
    m = folium.Map(tiles="Cartodb Positron")

    # Fit map to bounds of coordinates
    bounds = [(minimum(coordinates[:,1]), 
               minimum(coordinates[:,2])), 
              (maximum(coordinates[:,1]), 
               maximum(coordinates[:,2]))]
    m.fit_bounds(bounds, padding=(38, 38))

    # Insert all points
    n = size(coordinates, 1)
    for pId in 1:n
        folium.Circle(location=(coordinates[pId,1],
                                coordinates[pId,2]),
                                radius=10, 
                                tooltip="$pId", 
                                fill=true, 
                                fill_opacity=1,
                                color=(pId in covered_points) ? "green" : "blue"
                                ).add_to(m)
    end

    # Insert selected facilities with coverage circles
    for fId in selected_facilities
        folium.Circle(location=(coordinates[fId,1],
                                coordinates[fId,2]),
                                radius=radius, 
                                tooltip="Facility $fId", 
                                fill=true, 
                                fill_opacity=0.2,
                                color="green").add_to(m)
        folium.Circle(location=(coordinates[fId,1],
                                coordinates[fId,2]),
                                radius=10, 
                                tooltip="Facility $fId", 
                                fill=true, 
                                fill_opacity=1,
                                color="green").add_to(m)
    end

    return m
end

# Function to create distance matrix using pyproj
function create_distance_matrix(coordinates)
    # Ensure pyproj is installed
    try
        pyimport("pyproj")
    catch
        run(`$(PyCall.python) -m pip install pyproj`)
    end
    
    # Import pyproj only if not already imported
    pyproj = pyimport("pyproj")
    geod = pyproj.Geod(ellps="WGS84")

    # Calculate distance matrix
    n = size(coordinates, 1)
    distance_matrix = zeros(Float64, n, n)
    for i in 1:n-1
        for j in i+1:n
            lon1, lat1 = coordinates[i,2], coordinates[i,1]
            lon2, lat2 = coordinates[j,2], coordinates[j,1]
            distance_matrix[i,j] = geod.line_length([lon1, lon2], [lat1, lat2])
            distance_matrix[j,i] = distance_matrix[i,j]
        end
    end
    return distance_matrix
end