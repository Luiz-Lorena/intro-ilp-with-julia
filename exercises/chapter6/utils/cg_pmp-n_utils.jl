# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 3 – Location problems
#  Section: 3.1.3 – Capacitated P-Median Problem on a single node set (CPMP-N)
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using PythonCall: pyimport # For Python map plot (folium)
using Plots # For plotting convergence of reduced costs

# Function to plot the convergence of reduced costs
function cpmp_plot_reduced_costs(reduced_cost_history)
    p = Plots.plot(
        1:length(reduced_cost_history), 
        reduced_cost_history,
        label="Minimum Reduced Cost",
        xlabel="Iteration",
        ylabel="Reduced Cost",
        title="Convergence of the Pricing Subproblem",
        legend=:bottomright,
        linewidth=2
    )
    # Add a horizontal line at y=0 to show the convergence target
    Plots.hline!(p, [0], linestyle=:dash, color=:red, label="Optimality Threshold (RC=0)")
    # Display the plot
    display(p)
end

# Function to plot the solution using folium
function cpmp_plot_solution(coordinates, assignments, p)

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
            # Insert client point with color
            folium.Marker(location=(coordinates[client_id,1], 
                                    coordinates[client_id,2]),
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
    return fmap
end