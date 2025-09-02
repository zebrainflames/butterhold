-- The room's shape is the KEY. The value is a list of variations.
local templates = {
    -- Key for a horizontal corridor
    ["L-R"] = {
        -- Variation 1
        {
            tiles = {
                {"X","X","X","X","X"},
                {" ","G","E","G"," "},
                {"X","X","X","X","X"},
            }
        },
        -- Variation 2 (different layout, same shape)
        {
            tiles = {
                {"X","X","L","X","X"},
                {" "," "," "," "," "},
                {"X","X","X","X","X"},
            }
        }
    },
    -- Key for a vertical corridor
    ["U-D"] = {
        {
            tiles = {
                {"X"," ","X"},
                {"X","G","X"},
                {"X"," ","X"},
                {"X","G","X"},
                {"X"," ","X"},
            }
        }
    },
    -- Key for a corner with exits Up and Right
    ["U-R"] = {
        {
            tiles = {
                {"X"," ","X","X","X"},
                {" ","G"," "," ","X"},
                {"X"," ","E"," "," "},
                {"X","X","X","L","X"},
            }
        }
    },
    -- Key for a T-junction with no top exit
    ["D-L-R"] = {
        {
            tiles = {
                {"X","X","X","X","X"},
                {" "," ","G"," "," "},
                {" ","G"," ","G"," "},
                {"X"," ","L"," ","X"},
                {"X","X"," ","X","X"},
            }
        }
    },
    -- Key for a 4-way intersection
    ["U-D-L-R"] = {
        {
            tiles = {
                {"X","X"," ","X","X"},
                {" ","G"," ","G"," "},
                {" "," ","E"," "," "},
                {" ","G"," ","G"," "},
                {"X","X"," ","X","X"},
            }
        }
    },
    -- A key for empty rooms with no required exits
    ["EMPTY"] = {
        {
            tiles = {
                {"X","X","X","X","X"},
                {"X","G","G","G","X"},
                {"X","G","L","G","X"},
                {"X","G","G","G","X"},
                {"X","X","X","X","X"},
            }
        }
    }
}
return templates
