using Luxor, Colors

function plot_solution(items, unique_patterns_total)

    items_total = length(items.Length)
    patterns_total = length(unique_patterns_total)

    block_size = 25
    horizontal_blocks = patterns_total + 5
    vertical_blocks = items_total + 5
    width = block_size * horizontal_blocks
    heigth = block_size * vertical_blocks

    @drawsvg begin
        background("white")
        
        translate(13, 13)

        # Text on top
        fontsize(12)
        text("Cutting Patterns", Point(-block_size-5,-4*block_size), halign=:middle, valign=:middle)
        setopacity(0.3)
        sethue("gray")
        box(Point(0,-4*block_size), patterns_total*block_size, block_size, :fill)

        # Left text about part types (T1, ..., T5)
        t = Table(items_total, 1, block_size, block_size, Point(-(width/2)+2*block_size,0))
        for id in 1:items_total
            setopacity(0.3)
            sethue("gray")
            box(t[id], block_size, block_size, :fill)
            setopacity(1)
            sethue("black")
            text("T$id", t[id], halign=:center, valign=:middle)
        end
        
        # Top text about panel's id
        panel_id = 1
        t = Table(1, patterns_total, block_size, block_size, Point(0,-3*block_size))
        for id in 1:patterns_total
            setopacity(0.3)
            sethue("gray")
            box(t[id], block_size, block_size, :fill)
            setopacity(1)
            sethue("black")
            text("$panel_id", t[id], halign=:center, valign=:middle)
            panel_id += 1
        end
        
        # Add table data
        t = Table(items_total, patterns_total, block_size, block_size, Point(0, 0))
        t1 = Table(1, patterns_total, block_size, block_size, Point(0, block_size*3))
        
        total_production = 0
        col_id = 1
        for (pattern, total) in unique_patterns_total
            for (id, qty) in enumerate(pattern)
                setopacity(0.5)
                if qty > 0
                    sethue(colorant"#FFCA92")
                    box(t[id, col_id], block_size, block_size, :fill)
                end
                sethue("black")
                text(string(qty), t[id, col_id], halign=:center, valign=:middle)
            end
            setopacity(0.5)
            sethue("black")
            text(string(total), t1[col_id], halign=:center, valign=:middle)
            setopacity(0.3)
            sethue(colorant"blue")
            box(t1[col_id], block_size, block_size, :fill)
            col_id += 1

            total_production += total
        end

        # Add total production
        setopacity(0.5)
        sethue("black")
        t2 = Table(1, 1, block_size, block_size, Point(-(width/2)+(3+patterns_total)*block_size, block_size*3))
        text(string(total_production), t2[1], halign=:center, valign=:middle)
        setopacity(0.3)
        sethue("green")
        box(t2[1], block_size, block_size, :fill)

        # Add total label
        setopacity(0.3)
        sethue("gray")
        box(Point(-(width/2)+1.5*block_size,block_size*3), 2*block_size, block_size, :fill)
        box(Point(-(width/2)+block_size,0), block_size, 5*block_size, :fill)
        
        setopacity(1)
        sethue("black")
        text("Total", Point(-(width/2)+1.5*block_size,block_size*3), halign=:center, valign=:middle)
        @layer begin
            rotate(-π/2)           # 90 degrees rotation (π/2 radians)
            text("Item", Point(0, -(width/2)+block_size), halign=:center, valign=:middle)
        end

    end width heigth
end