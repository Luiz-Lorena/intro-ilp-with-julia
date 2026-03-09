using Gadfly

######################
# Coordinate helpers #
######################

# Convert between 2D grid coordinates (i, j) and a 1D ID
function coordinates_to_id(i, j, grid_size)
    return (i - 1) * grid_size + j
end

# Convert a 1D ID back to 2D grid coordinates (i, j)
function id_to_coordinates(id, grid_size)
    i = div(id - 1, grid_size) + 1
    j = mod(id - 1, grid_size) + 1
    return (i, j)
end

# Transform a point from grid coordinates to plot coordinates
function grid_to_plot_coordinates(x, y, grid_size)
    return (y, grid_size + 1 - x)
end

##################
# Plot functions #
##################

# Draws a free flow game board with grid lines and points
function draw_free_flow_board(grid_size, data; label=false)
    
    # Plot limits
    grid_min = 0.5
    grid_max = grid_size + 0.5
    
    # Create plot
    p = plot(
        Theme(background_color="gray90"),
        Coord.cartesian(xmin=grid_min, 
                        xmax=grid_max, 
                        ymin=grid_min, 
                        ymax=grid_max, 
                        aspect_ratio=1),
        Guide.title("Freeflow Game $grid_size x $grid_size Grid"),
        Guide.xlabel(nothing),
        Guide.ylabel(nothing),
        Guide.xticks(ticks=nothing),
        Guide.yticks(ticks=nothing)
    )

    # Draw freeflow grid lines
    for i in grid_min:1:grid_max
        push!(p, layer(x=[i, i], y=[grid_min, grid_max], Geom.line, Theme(default_color="gray")))
        push!(p, layer(x=[grid_min, grid_max], y=[i, i], Geom.line, Theme(default_color="gray")))
    end

    # Draw points
    for row in eachrow(data)
        push!(p, layer(x=[row.Y], 
                       y=[grid_size+1-row.X], 
                       Geom.point, 
                       size=[0.2], 
                       Theme(default_color=row.palette)))
    end

    if(label)
        # Add cell number labels
        label_count = 1
        for row in 1:grid_size
            for col in 1:grid_size
                x = col
                y = grid_size + 1 - row  # Invert y to start from top
                push!(p, layer(x=[x], 
                            y=[y], 
                            label=[string(label_count)], 
                            Geom.label, 
                            Theme(default_color="black", point_size=10pt)))
                label_count += 1
            end
        end
    end

    return p
end

# Draws the solution for the free flow game
function draw_free_flow_solution(grid_size, data, solution)

    # Create plot for solution
    p = draw_free_flow_board(grid_size, data; label=false)

    # Color palette dictionary
    color_map = Dict(row.color => row.palette for row in eachrow(data))

    # Problem data
    total_colors = maximum(data.color)
    total_cells = grid_size^2
    total_directions = 4

    for k in 1:total_colors
        for i in 1:total_cells
            for j in 1:total_directions
                if solution[i,j,k] == 1
                    
                    current_coord = id_to_coordinates(i, grid_size)

                    # Initial line coordinates
                    x_start = current_coord[1]
                    y_start = current_coord[2]
                    
                    # Final line coordinates
                    x_end = x_start
                    y_end = y_start

                    # If up
                    if j == 1 
                        x_end = x_end - 1
                    # If down
                    elseif j == 2 
                        x_end = x_end + 1
                    # If right
                    elseif j == 3
                        y_end = y_end + 1
                    # If left
                    elseif j == 4
                        y_end = y_end - 1
                    end

                    # Add line to plot
                    # Convert grid coordinates to plot coordinates
                    (x_start, y_start) = grid_to_plot_coordinates(x_start, y_start, grid_size)
                    (x_end, y_end) = grid_to_plot_coordinates(x_end, y_end, grid_size)
    
                    # Add line to plot
                    push!(p, layer(x=[x_start, x_end], 
                                   y=[y_start, y_end], 
                                   Geom.line,
                                   Theme(default_color=color_map[k], line_width=1.5mm)))
                end
            end
        end
    end

    return p
end