local _, UUF = ...

UUF.Defaults = {
    global = {
        UseGlobalProfile = false,
        GlobalProfile = "Default",
    },
    profile = {
        General = {
            AllowUIScaling = false,
            UIScale = 1,
            Font = "Friz Quadrata TT",
            FontFlag = "OUTLINE",
            FontShadows = {
                Colour = {0, 0, 0, 0},
                OffsetX = 0,
                OffsetY = 0
            },
            ForegroundTexture = "Blizzard Raid Bar",
            BackgroundTexture = "Solid",
            CustomColours = {
                Reaction = {
                    [1] = {204/255, 64/255, 64/255},            -- Hated
                    [2] = {204/255, 64/255, 64/255},            -- Hostile
                    [3] = {204/255, 128/255, 64/255},           -- Unfriendly
                    [4] = {204/255, 204/255, 64/255},           -- Neutral
                    [5] = {64/255, 204/255, 64/255},            -- Friendly
                    [6] = {64/255, 204/255, 64/255},            -- Honored
                    [7] = {64/255, 204/255, 64/255},            -- Revered
                    [8] = {64/255, 204/255, 64/255},            -- Exalted
                },
                Power = {
                    [0] = {0, 0, 1},            -- Mana
                    [1] = {1, 0, 0},            -- Rage
                    [2] = {1, 0.5, 0.25},       -- Focus
                    [3] = {1, 1, 0},            -- Energy
                    [6] = {0, 0.82, 1},         -- Runic Power
                    [8] = {0.3, 0.52, 0.9},     -- Lunar Power
                    [11] = {0, 0.5, 1},         -- Maelstrom
                    [13] = {0.4, 0, 0.8},       -- Insanity
                    [17] = {0.79, 0.26, 0.99},  -- Fury
                    [18] = {1, 0.61, 0}         -- Pain
                },
            },
            HealthSeparator = "-",
        },
        player = {
            Enabled = true,
            Frame = {
                Width = 244,
                Height = 42,
                XPosition = -425.1,
                YPosition = -275.1,
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {128/255, 128/255, 128/255, 1.0},
            },
            PowerBar = {
                Enabled = true,
                Height = 3,
                ColourByType = true,
                ColourBackgroundByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {128/255, 128/255, 128/255, 1},
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "FRAME",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByType = true,
                }
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Tags = {
                Name = {
                    Enabled = true,
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByStatus = false,
                },
                Health = {
                    Enabled = true,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    Layout = "CurrentPercent",
                },
            },
        },
        target = {
            Enabled = true,
            Frame = {
                Width = 244,
                Height = 42,
                XPosition = 425.1,
                YPosition = -275.1,
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {128/255, 128/255, 128/255, 1.0},
            },
            PowerBar = {
                Enabled = true,
                Height = 3,
                ColourByType = true,
                ColourBackgroundByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {128/255, 128/255, 128/255, 1},
                Text = {
                    Enabled = true,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "FRAME",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByType = true,
                }
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Tags = {
                Name = {
                    Enabled = true,
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByStatus = false,
                },
                Health = {
                    Enabled = true,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    Layout = "CurrentPercent",
                },
            },
        },
        targettarget = {
            Enabled = true,
            Frame = {
                Width = 122,
                Height = 21,
                XPosition = 0,
                YPosition = -28.1,
                AnchorFrom = "TOPRIGHT",
                AnchorParent = "UUF_Target",
                AnchorTo = "BOTTOMRIGHT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {128/255, 128/255, 128/255, 1.0},
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Tags = {
                Name = {
                    Enabled = true,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByStatus = false,
                },
                Health = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    Layout = "CurrentPercent",
                },
            },
        },
        pet = {
            Enabled = true,
            Frame = {
                Width = 122,
                Height = 21,
                XPosition = 0,
                YPosition = -28.1,
                AnchorFrom = "TOPLEFT",
                AnchorParent = "UUF_Player",
                AnchorTo = "BOTTOMLEFT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {128/255, 128/255, 128/255, 1.0},
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Tags = {
                Name = {
                    Enabled = true,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByStatus = false,
                },
                Health = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    Layout = "CurrentPercent",
                },
            },
        },
        focus = {
            Enabled = true,
            Frame = {
                Width = 122,
                Height = 21,
                XPosition = 0,
                YPosition = 28.1,
                AnchorFrom = "BOTTOMLEFT",
                AnchorParent = "UUF_Player",
                AnchorTo = "TOPLEFT",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {128/255, 128/255, 128/255, 1.0},
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Tags = {
                Name = {
                    Enabled = true,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByStatus = false,
                },
                Health = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    Layout = "CurrentPercent",
                },
            },
        },
        boss = {
            Enabled = true,
            Frame = {
                Width = 244,
                Height = 42,
                XPosition = 550.1,
                YPosition = 0.1,
                AnchorFrom = "CENTER",
                AnchorTo = "CENTER",
                ClassColour = false,
                ReactionColour = false,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {128/255, 128/255, 128/255, 1.0},
                GrowthDirection = "DOWN",
                Spacing = 1,
            },
            PowerBar = {
                Enabled = true,
                Height = 3,
                ColourByType = true,
                ColourBackgroundByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {128/255, 128/255, 128/255, 1},
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "FRAME",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByType = true,
                }
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                }
            },
            Tags = {
                Name = {
                    Enabled = true,
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByStatus = false,
                },
                Health = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    Layout = "CurrentPercent",
                },
            },
        },
    },
}