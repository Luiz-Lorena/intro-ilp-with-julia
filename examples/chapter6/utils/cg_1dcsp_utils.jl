# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 6 - Column Generation
#  Section: 6.2.3.1 - Solving CG for 1D-CSP in Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Luxor  # For plotting
using Colors # For color manipulation
using Plots  # For plotting reduced cost convergence

# Function to plot the cutting patterns and their production quantities
function plot_solution(columns, solution)
    # Columns sorted by quantity produced in descending order
    sorted_patterns = sortperm(collect(solution), rev=true)

    # Extract the amount cutting patterns
    patterns_total = sum(solution .> 0)

    # Extract the total number of items (part types)
    items_total = length(columns[1])

    # Get the total production quantity
    total_production = sum(solution)

    # Get the IDs of the patterns that are actually produced
    pattern_ids = sorted_patterns[1:patterns_total]

    # Define the size of the plot based on the number of patterns and items
    block_size = 25
    horizontal_blocks = patterns_total + 5
    vertical_blocks = items_total + 5
    width = block_size * horizontal_blocks
    heigth = block_size * vertical_blocks

    @drawsvg begin
        Luxor.background("white")
        Luxor.translate(13, 13)

        # Text on top
        Luxor.fontsize(12)
        Luxor.text("Cutting Patterns", Point(-block_size-5,-4*block_size), halign=:middle, valign=:middle)
        Luxor.setopacity(0.3)
        Luxor.sethue("gray")
        Luxor.box(Luxor.Point(0,-4*block_size), patterns_total*block_size, block_size, :fill)

        # Left text about part types (T1, ..., T5)
        t = Luxor.Table(items_total, 1, block_size, block_size, Point(-(width/2)+2*block_size,0))
        for id in 1:items_total
            Luxor.setopacity(0.3)
            Luxor.sethue("gray")
            Luxor.box(t[id], block_size, block_size, :fill)
            Luxor.setopacity(1)
            Luxor.sethue("black")
            Luxor.text("T$id", t[id], halign=:center, valign=:middle)
        end
        
        # Top text about panel's id
        panel_id = 1
        t = Luxor.Table(1, patterns_total, block_size, block_size, Point(0,-3*block_size))
        for id in 1:patterns_total
            Luxor.setopacity(0.3)
            Luxor.sethue("gray")
            Luxor.box(t[id], block_size, block_size, :fill)
            Luxor.setopacity(1)
            Luxor.sethue("black")
            Luxor.text("$panel_id", t[id], halign=:center, valign=:middle)
            panel_id += 1
        end
        
        
        # Add table data
        t = Luxor.Table(items_total, patterns_total, block_size, block_size, Point(0, 0))
        t1 = Luxor.Table(1, patterns_total, block_size, block_size, Point(0, block_size*3))
        
        col_id = 1
        for (id,p) in enumerate(pattern_ids)
            pattern = columns[p]
            qty = solution[p]
            Luxor.setopacity(0.5)
            for (id, qty) in enumerate(pattern)
                if qty > 0
                    Luxor.sethue(colorant"#FFCA92")
                    Luxor.box(t[id, col_id], block_size, block_size, :fill)
                end
                Luxor.sethue("black")
                Luxor.text(string(qty), t[id, col_id], halign=:center, valign=:middle)
            end
            Luxor.setopacity(0.5)
            Luxor.sethue("black")
            Luxor.text(string(qty), t1[col_id], halign=:center, valign=:middle)
            Luxor.setopacity(0.3)
            Luxor.sethue(colorant"blue")
            Luxor.box(t1[col_id], block_size, block_size, :fill)
            col_id += 1
        end

        # Add total production
        Luxor.setopacity(0.5)
        Luxor.sethue("black")
        t2 = Luxor.Table(1, 1, block_size, block_size, Point(-(width/2)+(3+patterns_total)*block_size, block_size*3))
        Luxor.text(string(total_production), t2[1], halign=:center, valign=:middle)
        Luxor.setopacity(0.3)
        Luxor.sethue("green")
        Luxor.box(t2[1], block_size, block_size, :fill)

        # Add total label
        Luxor.setopacity(0.3)
        Luxor.sethue("gray")
        Luxor.box(Luxor.Point(-(width/2)+1.5*block_size,block_size*3), 2*block_size, block_size, :fill)
        Luxor.box(Luxor.Point(-(width/2)+block_size,0), block_size, 5*block_size, :fill)
        
        Luxor.setopacity(1)
        Luxor.sethue("black")
        Luxor.text("Total", Luxor.Point(-(width/2)+1.5*block_size,block_size*3), halign=:center, valign=:middle)
        @layer begin
            Luxor.rotate(-π/2)           # 90 degrees rotation (π/2 radians)
            Luxor.text("Item", Luxor.Point(0, -(width/2)+block_size), halign=:center, valign=:middle)
        end

    end width heigth
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