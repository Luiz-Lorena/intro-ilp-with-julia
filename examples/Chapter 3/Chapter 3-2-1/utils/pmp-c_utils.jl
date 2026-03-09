using PyCall          # For Python map plot (folium)

# Function to plot the solution of the p-median problem using folium
function plot_solution(client_coordinates, facility_coordinates, assignments, p)
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

    # Combine coordinates
    coordinates = vcat(client_coordinates, facility_coordinates)

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

    color_id = 1
    for facility_id in 1:size(facility_coordinates, 1)
        # Insert facility marker, closed facilities in black
        if !haskey(assignments, facility_id)
            folium.Marker([facility_coordinates[facility_id,1], 
                           facility_coordinates[facility_id,2]],
                           tooltip="Facility $facility_id (closed)",
                           icon=folium.Icon(color="black", 
                                            icon="fa-building", 
                                            prefix="fa")).add_to(map)
        else
            folium.Marker([facility_coordinates[facility_id,1], 
                           facility_coordinates[facility_id,2]],
                           tooltip="Facility $facility_id (open)",
                           icon=folium.Icon(color=colors[color_id], 
                                            icon="fa-building", 
                                            prefix="fa")).add_to(map)
            for client_id in assignments[facility_id]
                # Draw line from facility to client
                folium.PolyLine(locations=[[facility_coordinates[facility_id,1], 
                                            facility_coordinates[facility_id,2]], 
                                           [client_coordinates[client_id,1], 
                                            client_coordinates[client_id,2]]],
                                color=colors[color_id],
                                weight=2.5,
                                opacity=0.8).add_to(map)
                # Insert client point with color
                folium.Marker(location=[client_coordinates[client_id,1], 
                                        client_coordinates[client_id,2]],
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
    end
    return map
end