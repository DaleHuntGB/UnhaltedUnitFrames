local _, UUF = ...

local Defaults = {
    global = {
        UseGlobalProfile = false,
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
                    [0] = {0, 0, 1},            -- Mana
                    [1] = {1, 0, 0},            -- Rage
                    [2] = {1, 0.5, 0.25},       -- Focus
                    [3] = {1, 1, 0},            -- Energy
                    [6] = {0, 0.82, 1},         -- Runic Power
                    [8] = {0.75, 0.52, 0.9},    -- Astral Power
                    [11] = {0, 0.5, 1},         -- Maelstrom
                    [13] = {0.4, 0, 0.8},       -- Insanity
                    [17] = {0.79, 0.26, 0.99},  -- Fury
                    [18] = {1, 0.61, 0}         -- Pain
                },
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
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Size = 42,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Enabled = false,
                    Size = 42,
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Size = 22,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Size = 22,
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Size = 22,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Size = 22,
                    Layout = {"LEFT", "RIGHT", 1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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
                    AnchorToCooldownViewer = false,
                    Inverse = false,
                    Foreground = {8/255, 8/255, 8/255},
                    ForegroundOpacity = 0.8,
                    Background = {34/255, 34/255, 34/255},
                    BackgroundOpacity = 1.0,
                },
                HealPrediction = {
                    Absorbs = {
                        Enabled = true,
                        UseStripedTexture = true,
                        Colour = {255/255, 204/255, 0/255, 1.0},
                        Position = "LEFT",
                    },
                    HealAbsorbs = {
                        Enabled = true,
                        UseStripedTexture = false,
                        Colour = {128/255, 64/255, 255/255, 1.0},
                        Position = "RIGHT",
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
                    Size = 42,
                    Layout = {"RIGHT", "LEFT", -1, 0},
                    Zoom = 0.3,
                    UseClassPortrait = false,
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

---@return table Defaults Returns the Default Table.
function UUF:GetDefaultDB() return Defaults end