# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 3 – Location problems
#  Section: 3.1.2 – PMP-C: classical PMP
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

# For Python map plot (folium)
using PythonCall: pyimport

# Function to plot the solution of the P-Median Problem using folium
function plot_solution(client_coordinates, facility_coordinates, assignments, p)
    
    # Problem dimensions
    m = size(facility_coordinates, 1)

    # Import folium library and create map
    folium = pyimport("folium")
    plugins = pyimport("folium.plugins")
    fmap = folium.Map(tiles="Cartodb Positron")

    # Combine coordinates
    coordinates = vcat(client_coordinates, facility_coordinates)

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

    # Insert facility markers, closed facilities in black
    color_id = 1
    for facility_id in 1:m
        if !haskey(assignments, facility_id)
            folium.Marker((facility_coordinates[facility_id,1], 
                           facility_coordinates[facility_id,2]),
                           tooltip="Facility $facility_id (closed)",
                           icon=folium.Icon(color="black", 
                                            icon="fa-building", 
                                            prefix="fa")).add_to(fmap)
        else
            folium.Marker([facility_coordinates[facility_id,1], 
                           facility_coordinates[facility_id,2]],
                           tooltip="Facility $facility_id (open)",
                           icon=folium.Icon(color=colors[color_id], 
                                            icon="fa-building", 
                                            prefix="fa")).add_to(fmap)
            for client_id in assignments[facility_id]
                folium.PolyLine(locations=((facility_coordinates[facility_id,1], 
                                            facility_coordinates[facility_id,2]), 
                                           (client_coordinates[client_id,1], 
                                            client_coordinates[client_id,2])),
                                color=colors[color_id],
                                weight=2.5,
                                opacity=0.8).add_to(fmap)
                folium.Marker(location=(client_coordinates[client_id,1], 
                                        client_coordinates[client_id,2]),
                              tooltip="Client $client_id",
                              color=colors[color_id],
                              icon=plugins.BeautifyIcon(
                                            icon="user",
                                            icon_shape="circle",
                                            border_color=colors[color_id],
                                            text_color=colors[color_id],
                                            background_color="white"
                                           )).add_to(fmap)
            end
            color_id += 1
        end
    end
    return fmap
end