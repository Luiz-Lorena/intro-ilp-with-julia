# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 3 – Location problems
#  Exercise: 3.2 – Fault-tolerant P-Median Problem
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

# For Python map plot (folium)
using PythonCall: pyimport

function plot_solution(coordinates, assignments, p)
    # Import folium library and create map
    folium = pyimport("folium")
    plugins = pyimport("folium.plugins")
    fmap = folium.Map(tiles="Cartodb Positron")

    # Fit map to bounds of coordinates
    fmap.fit_bounds(((minimum(coordinates[:,1]), minimum(coordinates[:,2])), 
                     (maximum(coordinates[:,1]), maximum(coordinates[:,2]))), 
                    padding=(38, 38))

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
        # Insert facility with color green if selected using a warehouse icon
        folium.Marker([coordinates[facility_id,1], 
                       coordinates[facility_id,2]],
                       tooltip="Facility $facility_id (open)",
                       icon=folium.Icon(color=colors[color_id], 
                                        icon="fa-building", 
                                        prefix="fa")).add_to(fmap)
        
        # Add the client points connected to the facility
        for client_id in client_ids
            # Draw line from facility to client
            folium.PolyLine(locations=((coordinates[facility_id,1], coordinates[facility_id,2]), 
                                       (coordinates[client_id,1], coordinates[client_id,2])),
                            color=colors[color_id],
                            weight=2.5,
                            opacity=0.8).add_to(fmap)
            if !(client_id in keys(assignments))
            # Insert client point with color
            folium.Marker(location=(coordinates[client_id,1], 
                                    coordinates[client_id,2]),
                        tooltip="Client $client_id",
                        color=colors[color_id],
                        icon=plugins.BeautifyIcon(
                                            icon="user",
                                            icon_shape="circle",
                                            border_color="black",#colors[color_id],
                                            text_color="black",#colors[color_id],
                                            background_color="white"
                                        )).add_to(fmap)
            end
        end
        color_id += 1
    end
    return fmap
end