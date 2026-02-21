local _, UUF = ...

-- =========================================================================
-- CASTBAR DEFAULTS TEMPLATE
-- =========================================================================
-- Provides the default configuration structure for all castbar enhancements.
-- Used across all unit types (player, target, boss, party, etc.)

local CastBarDefaults = {
    Enabled = true,
    Width = 244,
    Height = 24,
    Layout = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
    Foreground = {128/255, 128/255, 255/255},
    Background = {34/255, 34/255, 34/255},
    NotInterruptibleColour = {255/255, 64/255, 64/255},
    MatchParentWidth = true,
    ColourByClass = false,
    Inverse = false,
    FrameStrata = "MEDIUM",
    ForegroundOpacity = 1,
    BackgroundOpacity = 1,
    Icon = {
        Enabled = true,
        Position = "LEFT",
    },
    Text = {
        SpellName = {
            Enabled = true,
            FontSize = 12,
            Layout = {"LEFT", "LEFT", 3, 0},
            Colour = {1, 1, 1},
            MaxChars = 15,
        },
        Duration = {
            Enabled = true,
            FontSize = 12,
            Layout = {"RIGHT", "RIGHT", -3, 0},
            Colour = {1, 1, 1},
        }
    },
    -- New castbar enhancement features
    TimerDirection = {
        Enabled = true,
        Type = "ARROW",  -- ARROW, TEXT, BAR (arrow points left/right, text shows L/R direction)
        Size = 12,
        Layout = {"CENTER", "BOTTOM", 0, 3},
        Colour = {1, 1, 1},
    },
    ChannelTicks = {
        Enabled = true,
        Colour = {1, 255/255, 255/255},
        Opacity = 0.8,
        Thickness = 1,
    },
    EmpowerStages = {
        Enabled = true,
        Style = "LINES",  -- LINES, FILLS, BOXES
        Colour = {255/255, 128/255, 0},  -- Orange/gold
        Thickness = 2,
    },
    LatencyIndicator = {
        Enabled = true,
        ShowValue = true,  -- Display ms as text
        Colour = {255/255, 255/255, 0},  -- Yellow
        HighLatencyThreshold = 300,  -- ms before turning red
        HighLatencyColour = {255/255, 0, 0},  -- Red
    },
    InterruptFeedback = {
        Enabled = true,
        ShowInterruptable = true,
        ShowResist = true,
        InterruptableColour = {0, 255/255, 0},  -- Green
        ResistColour = {128/255, 0, 128/255},  -- Purple
    },
    Performance = {
        SimplifyForLargeGroups = true,
        GroupSizeThreshold = 15,  -- Switch to simple bar above this group size
    },
}

UUF.CastBarDefaults = CastBarDefaults
