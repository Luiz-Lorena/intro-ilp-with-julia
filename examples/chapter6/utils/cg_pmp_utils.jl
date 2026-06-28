# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 6 - Column Generation
#  Section: 6.3.2 - Solving CG for the PMP in Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Colors # For color manipulation
using Plots  # For plotting reduced cost convergence
using PythonCall: pyimport # For Python map plot (folium)

# Function to plot the solution using folium
function plot_solution(instance, columns, solution)

    # Generate distinguishable colors for the groups
    colors = ["green", "orange", "purple", "blue", "pink", "red", "beige", "cadetblue", "gray", "darkblue", "darkgreen", "lightgreen", "darkred", "lightblue", "darkpurple", "lightred"]

    # Import folium library and create map
    folium = pyimport("folium")
    plugins = pyimport("folium.plugins")
    fmap = folium.Map(tiles="Cartodb Positron")

    # Fit map to bounds of coordinates
    fmap.fit_bounds(((minimum(instance.coordinates[:,1]), 
                      minimum(instance.coordinates[:,2])), 
                     (maximum(instance.coordinates[:,1]), 
                      maximum(instance.coordinates[:,2]))), 
                    padding=(38, 38))

    selected_columns = [columns[i] for i in 1:length(columns) if solution[i] == 1]

    color_id = 1
    for column in selected_columns
        median_coord = instance.coordinates[column.median, :]
        folium.Marker(location=median_coord,
                      popup="Facility $(column.median)",
                      icon=folium.Icon(color=colors[mod1(color_id, length(colors))], 
                                       icon="fa-building", 
                                       prefix="fa")).add_to(fmap)

        assigned_clients = [i for i in 1:instance.n if column.client_assignments[i] == 1 && i != column.median]
        
        for client_id in assigned_clients
            client_coord = instance.coordinates[client_id, :]
            # Insert client point with color
            folium.Marker(location=client_coord,
                          tooltip="Client $client_id",
                          color=colors[color_id],
                          icon=plugins.BeautifyIcon(
                                            icon="user",
                                            icon_shape="circle",
                                            border_color=colors[mod1(color_id, length(colors))],
                                            text_color=colors[mod1(color_id, length(colors))],
                                            background_color="white"
                                        )).add_to(fmap)
            # Draw line from facility to client
            folium.PolyLine(locations=(median_coord, client_coord),
                            color=colors[color_id],
                            weight=2.5,
                            opacity=0.8).add_to(fmap)
        end
        color_id += 1
    end
    display(fmap)
end

# Function to plot the convergence of reduced costs
function plot_reduced_costs(reduced_cost_history)
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