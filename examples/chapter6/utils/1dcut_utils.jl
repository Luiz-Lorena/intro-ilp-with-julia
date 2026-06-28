# -------------------------------------------------------------
#  Code for: "Introduction to Integer Programming and Applications with Julia"
#  Chapter: 6 - Column Generation
#  Section: 6.2.2 - Solving the KCS model with Julia
#  Author(s): Luiz Henrique Nogueira Lorena
# -------------------------------------------------------------

using Luxor  # For plotting
using Colors # For color manipulation

function plot_solution(unique_patterns_total)

    # items_total = length(demands)
    patterns_total = length(unique_patterns_total)
    items_total = length(unique_patterns_total[1][1])

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
        
        total_production = 0
        col_id = 1
        for (pattern, total) in unique_patterns_total
            for (id, qty) in enumerate(pattern)
                Luxor.setopacity(0.5)
                if qty > 0
                    Luxor.sethue(colorant"#FFCA92")
                    Luxor.box(t[id, col_id], block_size, block_size, :fill)
                end
                Luxor.sethue("black")
                Luxor.text(string(qty), t[id, col_id], halign=:center, valign=:middle)
            end
            Luxor.setopacity(0.5)
            Luxor.sethue("black")
            Luxor.text(string(total), t1[col_id], halign=:center, valign=:middle)
            Luxor.setopacity(0.3)
            Luxor.sethue(colorant"blue")
            Luxor.box(t1[col_id], block_size, block_size, :fill)
            col_id += 1

            total_production += total
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