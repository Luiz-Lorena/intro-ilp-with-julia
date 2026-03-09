using PyCall # For Python map plot (folium)

# Function to plot the solution using folium
function plot_solution(coordinates, assignments, p)
    # Install required Python packages if missing
    try
        pyimport("folium")
    catch
        run(`$(PyCall.python) -m pip install folium`)
    end

    # Import folium library and create map
    folium = pyimport("folium")
    plugins = pyimport("folium.plugins")
    map = folium.Map(tiles="Cartodb Positron")

    # Fit map to bounds of coordinates
    bounds = [(minimum(coordinates[:,1]), 
               minimum(coordinates[:,2])), 
              (maximum(coordinates[:,1]), 
               maximum(coordinates[:,2]))]
    map.fit_bounds(bounds, padding=(38, 38))

    # Colors accepted by folium
    colors = ["orange", "purple", "green", "blue", "pink", 
              "red", "cadetblue","beige", "black", "darkblue", 
              "darkgreen", "darkred", "darkpurple"]

    # If not enough colors set all to black
    if p > length(colors)
        colors = fill("black", p)
    end

    # Insert facility points
    color_id = 1
    for (facility_id, client_ids) in assignments
        lat = round(coordinates[facility_id,1], digits=4)
        lon = round(coordinates[facility_id,2], digits=4)
        # Insert facility with color green if selected using a warehouse icon
        folium.Marker([coordinates[facility_id,1], 
                       coordinates[facility_id,2]],
                       tooltip="Facility $facility_id (open)",
                       icon=folium.Icon(color=colors[color_id], 
                                        icon="fa-building", 
                                        prefix="fa")).add_to(map)
        # Add the client points connected to the facility
        for client_id in client_ids
            lat_client = round(coordinates[client_id,1], digits=4)
            lon_client = round(coordinates[client_id,2], digits=4)
            # Draw line from facility to client
            folium.PolyLine(locations=[[lat, lon], [lat_client, lon_client]],
                            color=colors[color_id],
                            weight=2.5,
                            opacity=0.8).add_to(map)
            # Insert client point with color
            folium.Marker(location=[coordinates[client_id,1], 
                          coordinates[client_id,2]],
                          tooltip="Client $client_id",
                          color=colors[color_id],
                          icon=plugins.BeautifyIcon(
                                            icon="user",
                                            icon_shape="circle",
                                            border_color=colors[color_id],
                                            text_color=colors[color_id],
                                            background_color="white"
                                        )).add_to(map)
        end
        color_id += 1
    end
    return map
end