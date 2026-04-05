local _, UUF = ...

local Defaults = {
    global = {
        UseGlobalProfile = false,
        GlobalProfile = "Default",
        GlobalProfileName = "Default",
    },
    profile = {
        General = {
            TagUpdateInterval = 0.25,
            Separator = "||",
            ToTSeparator = "»",
            UseCustomAbbreviations = false,
            UIScale = {
                Enabled = false,
                Scale = 1.0,
            },
            Textures = {
                Foreground = "Better Blizzard",
                Background = "Better Blizzard",
            },
            Range = {
                Enabled = true,
                InRange = 1.0,
                OutOfRange = 0.5,
            },
            Fonts = {
                Font = "Friz Quadrata TT",
                FontFlag = "OUTLINE",
                Shadow = {
                    Enabled = false,
                    Colour = {0, 0, 0, 1},
                    XPos = 1,
                    YPos = -1,
                }
            },
            Colours = {
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
                    [0] = {0, 0, 1},                    -- Mana
                    [1] = {1, 0, 0},                    -- Rage
                    [2] = {1, 0.5, 0.25},               -- Focus
                    [3] = {1, 1, 0},                    -- Energy
                    [6] = {0, 0.82, 1},                 -- Runic Power
                    [8] = {0.75, 0.52, 0.9},            -- Lunar Power (Astral Power)
                    [11] = {0, 0.5, 1},                 -- Maelstrom
                    [13] = {0.4, 0, 0.8},               -- Insanity
                    [17] = {0.79, 0.26, 0.99},          -- Fury
                    [18] = {1, 0.61, 0},                -- Pain
                },
                SecondaryPower = {
                    [4] = {1, 0.96, 0.41},              -- Combo Points
                    [5] = {0.5, 0.5, 0.5},              -- Runes
                    [7] = {0.58, 0.51, 0.79},           -- Soul Shards
                    [9] = {0.95, 0.9, 0.6},             -- Holy Power
                    [12] = {0.71, 1, 0.92},             -- Chi
                    [16] = {0.41, 0.8, 0.94},           -- Arcane Charges
                    [19] = {100/255, 173/255, 206/255}, -- Essence
                },
                Dispel = {
                    ["Magic"] = {0.2, 0.6, 1 },
                    ["Curse"] = {0.6, 0, 1 },
                    ["Disease"] = {0.6, 0.4, 0 },
                    ["Poison"] = {0, 0.6, 0 },
                    ["Bleed"] = {0.6, 0, 0.1 }
                }
            }
        },
        Units = {
            player = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 244,
                    Height = 42,
                    Layout = {"CENTER", "CENTER", -425.1, -275.1},
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                    DispelHighlight = {
                        Enabled = true,
                        Style = "GRADIENT",
                    },
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 40,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 40,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 40,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                SecondaryPowerBar = {
                    Enabled = false,
                    Height = 3,
                    Position = "TOP",
                    ColourByType = true,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                },
                AlternativePowerBar = {
                    Enabled = true,
                    Height = 5,
                    Width = 100,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {34/255, 34/255, 34/255},
                    ColourByType = true,
                    Inverse = false,
                    Layout = {"LEFT", "BOTTOMLEFT", 3, 1},
                },
                CastBar = {
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
                    }
                },
                Portrait = {
                    Enabled = false,
                    Width = 42,
                    Height = 42,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 24,
                        Layout = {"CENTER", "TOP", 0, 0},
                    },
                    LeaderAssistantIndicator = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"TOPLEFT", "TOPLEFT", 3, -3},
                    },
                    Resting = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"LEFT", "TOPLEFT", 3, 0},
                        Texture = "RESTING0"
                    },
                    Combat = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"CENTER", "TOP", 0, 0},
                        Texture = "COMBAT0"
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Totems = {
                        Enabled = true,
                        Size = 42,
                        Layout = {"RIGHT", "LEFT", -1, 0, 1},
                        GrowthDirection = "LEFT",
                        TotemDuration = {
                            Layout = {"CENTER", "CENTER", 0, 0},
                            FontSize = 12,
                            ScaleByIconSize = false,
                            Colour = {1, 1, 1},
                        },
                    },
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 34,
                        Layout = {"BOTTOMRIGHT", "TOPRIGHT", 0, 1, 1},
                        Num = 4,
                        Wrap = 4,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 34,
                        Layout = {"BOTTOMLEFT", "TOPLEFT", 0, 1, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[curhp:abbr]",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"RIGHT", "BOTTOMRIGHT", -3, 2},
                        Colour = {1, 1, 1},
                        Tag = "[powercolor][curpp]",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            target = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 244,
                    Height = 42,
                    Layout = {"CENTER", "CENTER", 425.1, -275.1},
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                    DispelHighlight = {
                        Enabled = true,
                        Style = "GRADIENT",
                    },
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 40,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 40,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 40,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                CastBar = {
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
                    }
                },
                Portrait = {
                    Enabled = false,
                    Width = 42,
                    Height = 42,
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 24,
                        Layout = {"CENTER", "TOP", 0, 0},
                    },
                    LeaderAssistantIndicator = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"TOPRIGHT", "TOPRIGHT", -3, -3},
                    },
                    Combat = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"CENTER", "TOP", 0, 0},
                        Texture = "COMBAT0"
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Target = {
                        Enabled = false,
                        Colour = {1, 1, 1},
                    }
                },
                Range = {
                    Enabled = true,
                    InRange = 1.0,
                    OutOfRange = 0.5,
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 34,
                        Layout = {"BOTTOMLEFT", "TOPLEFT", 0, 1, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 34,
                        Layout = {"BOTTOMRIGHT", "TOPRIGHT", 0, 1, 1},
                        Num = 4,
                        Wrap = 4,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[curhp:abbr]",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"RIGHT", "BOTTOMRIGHT", -3, 2},
                        Colour = {1, 1, 1},
                        Tag = "[powercolor][curpp]",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            targettarget = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 122,
                    Height = 22,
                    AnchorParent = "UUF_Target",
                    Layout = {"TOPRIGHT", "BOTTOMRIGHT", 0, -26.1},
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 20,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 20,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 20,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                -- CastBar = {
                --     Enabled = false,
                --     Width = 244,
                --     Height = 24,
                --     Layout = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                --     Foreground = {128/255, 128/255, 255/255},
                --     Background = {34/255, 34/255, 34/255},
                --     NotInterruptibleColour = {255/255, 64/255, 64/255},
                --     MatchParentWidth = true,
                --     ColourByClass = false,
                --     FrameStrata = "MEDIUM",
                --     Icon = {
                --         Enabled = true,
                --         Position = "LEFT",
                --     },
                --     Text = {
                --         SpellName = {
                --             Enabled = true,
                --             FontSize = 12,
                --             Layout = {"LEFT", "LEFT", 3, 0},
                --             Colour = {1, 1, 1},
                --             MaxChars = 15,
                --         },
                --         Duration = {
                --             Enabled = true,
                --             FontSize = 12,
                --             Layout = {"RIGHT", "RIGHT", -3, 0},
                --             Colour = {1, 1, 1},
                --         }
                --     }
                -- },
                Portrait = {
                    Enabled = false,
                    Width = 22,
                    Height = 22,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"LEFT", "TOPLEFT", 3, 0},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Target = {
                        Enabled = false,
                        Colour = {1, 1, 1},
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"RIGHT", "LEFT", -1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"LEFT", "RIGHT", 1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            focus = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 122,
                    Height = 22,
                    AnchorParent = "UUF_Player",
                    Layout = {"BOTTOMLEFT", "TOPLEFT", 0, 36.1},
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                    DispelHighlight = {
                        Enabled = false,
                        Style = "GRADIENT",
                    },
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 20,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 20,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 20,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                CastBar = {
                    Enabled = true,
                    Width = 244,
                    Height = 24,
                    Layout = {"BOTTOMLEFT", "TOPLEFT", 0, 1},
                    Foreground = {128/255, 128/255, 255/255},
                    Background = {34/255, 34/255, 34/255},
                    NotInterruptibleColour = {255/255, 64/255, 64/255},
                    MatchParentWidth = true,
                    ColourByClass = false,
                    Inverse = false,
                    FrameStrata = "MEDIUM",
                    Icon = {
                        Enabled = false,
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
                    }
                },
                Portrait = {
                    Enabled = false,
                    Width = 22,
                    Height = 22,
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"RIGHT", "TOPRIGHT", -3, 0},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Target = {
                        Enabled = false,
                        Colour = {1, 1, 1},
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"RIGHT", "LEFT", -1, 0, 1},
                        Num = 1,
                        Wrap = 1,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"LEFT", "RIGHT", 1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            focustarget = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 122,
                    Height = 22,
                    AnchorParent = "UUF_Focus",
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 20,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 20,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 20,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                -- CastBar = {
                --     Enabled = false,
                --     Width = 244,
                --     Height = 24,
                --     Layout = {"TOPLEFT", "BOTTOMLEFT", 0, -1},
                --     Foreground = {128/255, 128/255, 255/255},
                --     Background = {34/255, 34/255, 34/255},
                --     NotInterruptibleColour = {255/255, 64/255, 64/255},
                --     MatchParentWidth = true,
                --     ColourByClass = false,
                --     FrameStrata = "MEDIUM",
                --     Icon = {
                --         Enabled = true,
                --         Position = "LEFT",
                --     },
                --     Text = {
                --         SpellName = {
                --             Enabled = true,
                --             FontSize = 12,
                --             Layout = {"LEFT", "LEFT", 3, 0},
                --             Colour = {1, 1, 1},
                --             MaxChars = 15,
                --         },
                --         Duration = {
                --             Enabled = true,
                --             FontSize = 12,
                --             Layout = {"RIGHT", "RIGHT", -3, 0},
                --             Colour = {1, 1, 1},
                --         }
                --     }
                -- },
                Portrait = {
                    Enabled = false,
                    Width = 22,
                    Height = 22,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"LEFT", "TOPLEFT", 3, 0},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Target = {
                        Enabled = false,
                        Colour = {1, 1, 1},
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"RIGHT", "LEFT", -1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"LEFT", "RIGHT", 1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            pet = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 122,
                    Height = 22,
                    AnchorParent = "UUF_Player",
                    Layout = {"TOPLEFT", "BOTTOMLEFT", 0, -26.1},
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 20,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 20,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 20,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                CastBar = {
                    Enabled = false,
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
                    Icon = {
                        Enabled = false,
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
                    }
                },
                Portrait = {
                    Enabled = false,
                    Width = 22,
                    Height = 22,
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = false,
                        Size = 16,
                        Layout = {"LEFT", "TOPLEFT", 3, 0},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Target = {
                        Enabled = false,
                        Colour = {1, 1, 1},
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"LEFT", "RIGHT", 1, 0, 1},
                        Num = 1,
                        Wrap = 1,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 22,
                        Layout = {"RIGHT", "LEFT", -1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER",0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            party = {
                Enabled = true,
                ForceHideBlizzard = true,
                ShowPlayer = false,
                Frame = {
                    Width = 182,
                    Height = 32,
                    Layout = {"TOPLEFT", "TOPLEFT", 24, -320, 8},
                    GrowthDirection = "DOWN",
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                    DispelHighlight = {
                        Enabled = true,
                        Style = "GRADIENT",
                    },
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 30,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 30,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 30,
                    },
                },
                PowerBar = {
                    Enabled = true,
                    OnlyHealers = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                CastBar = {
                    Enabled = true,
                    Width = 182,
                    Height = 16,
                    Layout = {"TOPLEFT", "BOTTOMLEFT", 0, -2},
                    Foreground = {128/255, 128/255, 255/255},
                    Background = {34/255, 34/255, 34/255},
                    NotInterruptibleColour = {255/255, 64/255, 64/255},
                    MatchParentWidth = true,
                    ColourByClass = false,
                    Inverse = false,
                    FrameStrata = "MEDIUM",
                    Icon = {
                        Enabled = false,
                        Position = "LEFT",
                    },
                    Text = {
                        SpellName = {
                            Enabled = true,
                            FontSize = 11,
                            Layout = {"LEFT", "LEFT", 3, 0},
                            Colour = {1, 1, 1},
                            MaxChars = 16,
                        },
                        Duration = {
                            Enabled = true,
                            FontSize = 11,
                            Layout = {"RIGHT", "RIGHT", -3, 0},
                            Colour = {1, 1, 1},
                        }
                    }
                },
                Portrait = {
                    Enabled = false,
                    Width = 32,
                    Height = 32,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 18,
                        Layout = {"CENTER", "TOP", 0, 0},
                    },
                    RoleIcon = {
                        Enabled = true,
                        Size = 14,
                        Layout = {"LEFT", "TOPLEFT", 2, -2},
                    },
                    Resurrect = {
                        Enabled = true,
                        Size = 14,
                        Layout = {"RIGHT", "TOPRIGHT", -2, -2},
                    },
                    LeaderAssistantIndicator = {
                        Enabled = true,
                        Size = 14,
                        Layout = {"TOPLEFT", "TOPLEFT", 3, -3},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 20,
                        Layout = {"LEFT", "RIGHT", 2, 0, 1},
                        Num = 2,
                        Wrap = 2,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 20,
                        Layout = {"RIGHT", "LEFT", -2, 0, 1},
                        Num = 4,
                        Wrap = 4,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 11,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 11,
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[curhp:abbr]",
                    },
                    TagThree = {
                        FontSize = 10,
                        Layout = {"RIGHT", "BOTTOMRIGHT", -3, 2},
                        Colour = {1, 1, 1},
                        Tag = "[powercolor][curpp]",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            raid = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 92,
                    Height = 38,
                    Layout = {"TOPLEFT", "TOPLEFT", 230, -24},
                    GrowthDirection = "DOWN_RIGHT",
                    HorizontalSpacing = 4,
                    VerticalSpacing = 4,
                    MaxColumns = 8,
                    UnitsPerColumn = 5,
                    GroupBy = "GROUP",
                    SortDirection = "ASC",
                    SortMethod = "INDEX",
                    GroupFilter = "",
                    FrameStrata = "LOW",
                    RoleOrder = {"TANK", "HEALER", "DAMAGER"},
                    ClassOrder = {"DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE", "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"},
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                    DispelHighlight = {
                        Enabled = true,
                        Style = "GRADIENT",
                    },
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 36,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 36,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 36,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    OnlyHealers = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    Position = "BOTTOM",
                    BackgroundMultiplier = 0.75,
                },
                CastBar = {
                    Enabled = false,
                    Width = 92,
                    Height = 12,
                    Layout = {"TOPLEFT", "BOTTOMLEFT", 0, -2},
                    Foreground = {128/255, 128/255, 255/255},
                    Background = {34/255, 34/255, 34/255},
                    NotInterruptibleColour = {255/255, 64/255, 64/255},
                    MatchParentWidth = true,
                    ColourByClass = false,
                    Inverse = false,
                    FrameStrata = "MEDIUM",
                    Icon = {
                        Enabled = false,
                        Position = "LEFT",
                    },
                    Text = {
                        SpellName = {
                            Enabled = false,
                            FontSize = 10,
                            Layout = {"LEFT", "LEFT", 3, 0},
                            Colour = {1, 1, 1},
                            MaxChars = 10,
                        },
                        Duration = {
                            Enabled = false,
                            FontSize = 10,
                            Layout = {"RIGHT", "RIGHT", -3, 0},
                            Colour = {1, 1, 1},
                        }
                    }
                },
                Portrait = {
                    Enabled = false,
                    Width = 32,
                    Height = 32,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 16,
                        Layout = {"CENTER", "TOP", 0, 0},
                    },
                    RoleIcon = {
                        Enabled = true,
                        Size = 12,
                        Layout = {"LEFT", "TOPLEFT", 2, -2},
                    },
                    Resurrect = {
                        Enabled = true,
                        Size = 12,
                        Layout = {"RIGHT", "TOPRIGHT", -2, -2},
                    },
                    LeaderAssistantIndicator = {
                        Enabled = true,
                        Size = 12,
                        Layout = {"TOPLEFT", "TOPLEFT", 2, -2},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 10,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 16,
                        Layout = {"LEFT", "RIGHT", 2, 0, 1},
                        Num = 2,
                        Wrap = 2,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 10,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 16,
                        Layout = {"RIGHT", "LEFT", -2, 0, 1},
                        Num = 2,
                        Wrap = 2,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 10,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 10,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 10,
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[curhp:abbr]",
                    },
                    TagThree = {
                        FontSize = 10,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFour = {
                        FontSize = 10,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 10,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
            boss = {
                Enabled = true,
                ForceHideBlizzard = true,
                Frame = {
                    Width = 244,
                    Height = 42,
                    Layout = {"CENTER", "CENTER", 550.1, -0.1, 26},
                    GrowthDirection = "DOWN",
                    FrameStrata = "LOW",
                },
                HealthBar = {
                    ColourByClass = true,
                    ColourBackgroundByClass = false,
                    ColourByReaction = true,
                    ColourWhenTapped = true,
                    Inverse = false,
                    Smoothing = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    IncomingHeals = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {64/255, 255/255, 128/255, 0.8},
                        Position = "ATTACH",
                        Height = 40,
                    },
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        MatchParentHeight = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                        Height = 40,
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        MatchParentHeight = true,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
                        Height = 40,
                    },
                },
                PowerBar = {
                    Enabled = false,
                    Height = 3,
                    Foreground = {8/255, 8/255, 8/255},
                    Background = {128/255, 128/255, 128/255},
                    ColourByType = true,
                    ColourBackgroundByType = false,
                    ColourByClass = false,
                    Smooth = true,
                    Inverse = false,
                    BackgroundMultiplier = 0.75,
                },
                CastBar = {
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
                    }
                },
                Portrait = {
                    Enabled = true,
                    Width = 42,
                    Height = 42,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
                    Style = "2D",
                },
                Indicators = {
                    RaidTargetMarker = {
                        Enabled = true,
                        Size = 24,
                        Layout = {"CENTER", "TOP", 0, 0},
                    },
                    Mouseover = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                        HighlightOpacity = 0.75,
                        Style = "GRADIENT"
                    },
                    Target = {
                        Enabled = true,
                        Colour = {1, 1, 1},
                    }
                },
                Auras = {
                    FrameStrata = "LOW",
                    AuraDuration = {
                        Layout = {"CENTER", "CENTER", 0, 0},
                        FontSize = 12,
                        ScaleByIconSize = false,
                        Colour = {1, 1, 1},
                    },
                    Buffs = {
                        Enabled = true,
                        OnlyShowPlayer = false,
                        Size = 42,
                        Layout = {"LEFT", "RIGHT", 1, 0, 1},
                        Num = 3,
                        Wrap = 3,
                        GrowthDirection = "RIGHT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HELPFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                    Debuffs = {
                        Enabled = false,
                        OnlyShowPlayer = false,
                        Size = 34,
                        Layout = {"BOTTOMRIGHT", "TOPRIGHT", 0, 1, 1},
                        Num = 4,
                        Wrap = 4,
                        GrowthDirection = "LEFT",
                        WrapDirection = "UP",
                        ShowType = false,
                        Filter = "HARMFUL",
                        Count = {
                            Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", 0, 2},
                            FontSize = 12,
                            Colour = {1, 1, 1, 1}
                        }
                    },
                },
                Tags = {
                    TagOne = {
                        FontSize = 12,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[name]",
                    },
                    TagTwo = {
                        FontSize = 12,
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Colour = {1, 1, 1},
                        Tag = "[curhp:abbr]",
                    },
                    TagThree = {
                        FontSize = 12,
                        Layout = {"RIGHT", "BOTTOMRIGHT", -3, 2},
                        Colour = {1, 1, 1},
                        Tag = "[powercolor][curpp]",
                    },
                    TagFour = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                    TagFive = {
                        FontSize = 12,
                        Layout = {"CENTER", "CENTER", 0, 0},
                        Colour = {1, 1, 1},
                        Tag = "",
                    },
                }
            },
        }
    },
}

local function CreateIndicatorDefaults(size, layout, extraOptions)
    local defaults = {
        Enabled = true,
        Size = size,
        Layout = {unpack(layout)},
    }

    if extraOptions then
        for key, value in pairs(extraOptions) do
            defaults[key] = value
        end
    end

    return defaults
end

local ReadyCheckIndicatorDefaults = {
    target = CreateIndicatorDefaults(24, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    targettarget = CreateIndicatorDefaults(16, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    focus = CreateIndicatorDefaults(16, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    focustarget = CreateIndicatorDefaults(16, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    pet = CreateIndicatorDefaults(16, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    party = CreateIndicatorDefaults(18, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    raid = CreateIndicatorDefaults(16, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
    boss = CreateIndicatorDefaults(24, {"CENTER", "CENTER", 0, 0}, {UseAtlasSize = false, FinishedTime = 10, FadeTime = 1.5}),
}

local PhaseIndicatorDefaults = {
    target = CreateIndicatorDefaults(16, {"BOTTOMLEFT", "BOTTOMLEFT", 3, 3}),
    targettarget = CreateIndicatorDefaults(14, {"BOTTOMLEFT", "BOTTOMLEFT", 2, 2}),
    focus = CreateIndicatorDefaults(14, {"BOTTOMLEFT", "BOTTOMLEFT", 2, 2}),
    focustarget = CreateIndicatorDefaults(14, {"BOTTOMLEFT", "BOTTOMLEFT", 2, 2}),
    pet = CreateIndicatorDefaults(14, {"BOTTOMLEFT", "BOTTOMLEFT", 2, 2}),
    party = CreateIndicatorDefaults(12, {"BOTTOMLEFT", "BOTTOMLEFT", 2, 2}),
    raid = CreateIndicatorDefaults(10, {"BOTTOMLEFT", "BOTTOMLEFT", 2, 2}),
    boss = CreateIndicatorDefaults(16, {"BOTTOMLEFT", "BOTTOMLEFT", 3, 3}),
}

local SummonIndicatorDefaults = {
    party = CreateIndicatorDefaults(14, {"BOTTOM", "BOTTOM", 0, 2}, {UseAtlasSize = false}),
    raid = CreateIndicatorDefaults(12, {"BOTTOM", "BOTTOM", 0, 2}, {UseAtlasSize = false}),
}

for unit, indicatorDefaults in pairs(ReadyCheckIndicatorDefaults) do
    Defaults.profile.Units[unit].Indicators.ReadyCheck = Defaults.profile.Units[unit].Indicators.ReadyCheck or indicatorDefaults
end

for unit, indicatorDefaults in pairs(PhaseIndicatorDefaults) do
    Defaults.profile.Units[unit].Indicators.Phase = Defaults.profile.Units[unit].Indicators.Phase or indicatorDefaults
end

for unit, indicatorDefaults in pairs(SummonIndicatorDefaults) do
    Defaults.profile.Units[unit].Indicators.Summon = Defaults.profile.Units[unit].Indicators.Summon or indicatorDefaults
end

for _, unitDefaults in pairs(Defaults.profile.Units) do
    if unitDefaults.HealthBar and not unitDefaults.HealthBar.DeadBackground then
        unitDefaults.HealthBar.DeadBackground = {96/255, 32/255, 32/255}
    end

    if unitDefaults.HealthBar and unitDefaults.HealthBar.UseDeadBackground == nil then
        unitDefaults.HealthBar.UseDeadBackground = true
    end
end

---@return table Defaults Returns the Default Table.
function UUF:GetDefaultDB() return Defaults end
