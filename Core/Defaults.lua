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
            ForegroundTexture = "BetterBlizzard",
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
                    [8] = {0.75, 0.52, 0.9},     -- Lunar Power
                    [11] = {0, 0.5, 1},         -- Maelstrom
                    [13] = {0.4, 0, 0.8},       -- Insanity
                    [17] = {0.79, 0.26, 0.99},  -- Fury
                    [18] = {1, 0.61, 0}         -- Pain
                },
                Classification = {
                    ["worldboss"] = {204/255, 64/255, 64/255},
                    ["rareelite"] = {128/255, 64/255, 204/255},
                    ["elite"] = {255/255, 204/255, 64/255},
                    ["rare"] = {0/255, 112/255, 204/255},
                    ["normal"] = {255/255, 255/255, 255/255}
                }
            },
            HealthTagLayout = "•",
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
                ClassColour = true,
                ReactionColour = true,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {26/255, 26/255, 26/255, 1.0},
                AnchorToEssentialCooldowns = false,
                InverseGrowth = false,
            },
            HealPrediction = {
                Absorbs = {
                    Enabled = true,
                    Colour = {255/255, 204/255, 0/255, 1},
                    GrowthDirection = "RIGHT",
                }
            },
            CastBar = {
                Enabled = true,
                Height = 24,
                Width = 244,
                XPosition = 0,
                YPosition = -1,
                AnchorFrom = "TOP",
                AnchorTo = "BOTTOM",
                FGColour = {128/255, 128/255, 255/255, 1},
                BGColour = {26/255, 26/255, 26/255, 1},
                Text = {
                    SpellName = {
                        Enabled = true,
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                    },
                    Time = {
                        Enabled = true,
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                    },
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 1,
                ColourByType = true,
                ColourBackgroundByType = true,
                Alignment = "BOTTOM",
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {26/255, 26/255, 26/255, 1},
                DarkenFactor = 0.75,
                InverseGrowth = false,
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "POWER",
                    AnchorTo = "RIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                    ColourByType = true,
                },
            },
            AlternatePowerBar = {
                Enabled = true,
                Height = 10,
                Width = 122,
                XPosition = -3,
                YPosition = 0,
                AnchorFrom = "RIGHT",
                AnchorTo = "BOTTOMRIGHT",
                ColourByType = true,
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {26/255, 26/255, 26/255, 1},
                InverseGrowth = false,
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                },
                RaidTargetMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                Status = {
                    Combat = false,
                    Resting = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = -3,
                    RestingTexture = "RESTING0",
                    CombatTexture = "DEFAULT",
                },
                Leader = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    OffsetX = -3,
                    OffsetY = 0,
                },
                TargetIndicator = {
                    Enabled = false,
                    Colour = {1, 1, 1, 1},
                    Style = "GLOW"
                }
            },
            Portrait = {
                Enabled = true,
                Size = 42,
                AnchorFrom = "RIGHT",
                AnchorTo = "LEFT",
                OffsetX = -1,
                OffsetY = 0,
                Zoom = 0.3,
                MatchFrameHeight = true,
            },
            Tags = {
                TagOne = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagTwo = {
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    Tag = "[curhpperhp:abbr]",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagThree = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagFour = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
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
                ClassColour = true,
                ReactionColour = true,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {26/255, 26/255, 26/255, 1.0},
                DarkenFactor = 0.75,
                AnchorToEssentialCooldowns = false,
                InverseGrowth = false,
            },
            HealPrediction = {
                Absorbs = {
                    Enabled = true,
                    Colour = {255/255, 204/255, 0/255, 1},
                    GrowthDirection = "RIGHT",
                }
            },
            CastBar = {
                Enabled = true,
                Height = 24,
                Width = 244,
                XPosition = 0,
                YPosition = -1,
                AnchorFrom = "TOP",
                AnchorTo = "BOTTOM",
                FGColour = {128/255, 128/255, 255/255, 1},
                BGColour = {26/255, 26/255, 26/255, 1},
                Text = {
                    SpellName = {
                        Enabled = true,
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                    },
                    Time = {
                        Enabled = true,
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                    },
                }
            },
            PowerBar = {
                Enabled = true,
                Height = 1,
                ColourByType = true,
                ColourBackgroundByType = true,
                Alignment = "BOTTOM",
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {26/255, 26/255, 26/255, 1},
                DarkenFactor = 0.75,
                InverseGrowth = false,
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "POWER",
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
                },
                RaidTargetMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                Leader = {
                    Enabled = true,
                    Size = 15,
                    AnchorFrom = "LEFT",
                    AnchorTo = "TOPLEFT",
                    OffsetX = 3,
                    OffsetY = 0,
                },
                TargetIndicator = {
                    Enabled = false,
                    Colour = {1, 1, 1, 1},
                    Style = "GLOW"
                }
            },
            Portrait = {
                Enabled = true,
                Size = 42,
                AnchorFrom = "LEFT",
                AnchorTo = "RIGHT",
                OffsetX = 1,
                OffsetY = 0,
                Zoom = 0.3,
                MatchFrameHeight = true,
            },
            Tags = {
                TagOne = {
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    Tag = "[name:namewithtargettarget]",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagTwo = {
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    Tag = "[curhpperhp:abbr]",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagThree = {
                    AnchorFrom = "RIGHT",
                    AnchorTo = "TOPRIGHT",
                    Tag = "[levelclassification]",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagFour = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
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
                ClassColour = true,
                ReactionColour = true,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {26/255, 26/255, 26/255, 1.0},
                InverseGrowth = false,
            },
            HealPrediction = {
                Absorbs = {
                    Enabled = true,
                    Colour = {255/255, 204/255, 0/255, 1},
                    GrowthDirection = "RIGHT",
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                ColourBackgroundByType = true,
                Alignment = "BOTTOM",
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {26/255, 26/255, 26/255, 1},
                DarkenFactor = 0.75,
                InverseGrowth = false,
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "POWER",
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
                },
                RaidTargetMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                TargetIndicator = {
                    Enabled = false,
                    Colour = {1, 1, 1, 1},
                    Style = "GLOW"
                }
            },
            Tags = {
                TagOne = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "[name]",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagTwo = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagThree = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagFour = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
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
                ClassColour = true,
                ReactionColour = true,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {26/255, 26/255, 26/255, 1.0},
                InverseGrowth = false,
            },
            HealPrediction = {
                Absorbs = {
                    Enabled = true,
                    Colour = {255/255, 204/255, 0/255, 1},
                    GrowthDirection = "RIGHT",
                }
            },
            Indicators = {
                MouseoverHighlight = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                },
                RaidTargetMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                TargetIndicator = {
                    Enabled = false,
                    Colour = {1, 1, 1, 1},
                    Style = "GLOW"
                }
            },
            Tags = {
                TagOne = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "[name]",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagTwo = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagThree = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagFour = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
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
                ClassColour = true,
                ReactionColour = true,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {26/255, 26/255, 26/255, 1.0},
                InverseGrowth = false,
            },
            HealPrediction = {
                Absorbs = {
                    Enabled = true,
                    Colour = {255/255, 204/255, 0/255, 1},
                    GrowthDirection = "RIGHT",
                }
            },
            PowerBar = {
                Enabled = false,
                Height = 3,
                ColourByType = true,
                ColourBackgroundByType = true,
                Alignment = "BOTTOM",
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {26/255, 26/255, 26/255, 1},
                DarkenFactor = 0.75,
                InverseGrowth = false,
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "POWER",
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
                },
                RaidTargetMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                TargetIndicator = {
                    Enabled = false,
                    Colour = {1, 1, 1, 1},
                    Style = "GLOW"
                }
            },
            Tags = {
                TagOne = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "[name]",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagTwo = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagThree = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagFour = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
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
                ClassColour = true,
                ReactionColour = true,
                FGColour = {26/255, 26/255, 26/255, 1.0},
                BGColour = {26/255, 26/255, 26/255, 1.0},
                GrowthDirection = "DOWN",
                Spacing = 1,
                InverseGrowth = false,
            },
            HealPrediction = {
                Absorbs = {
                    Enabled = true,
                    Colour = {255/255, 204/255, 0/255, 1},
                    GrowthDirection = "RIGHT",
                }
            },
            CastBar = {
                Enabled = true,
                Height = 24,
                Width = 244,
                XPosition = 0,
                YPosition = -1,
                AnchorFrom = "TOP",
                AnchorTo = "BOTTOM",
                FGColour = {128/255, 128/255, 255/255, 1},
                BGColour = {26/255, 26/255, 26/255, 1},
                Text = {
                    SpellName = {
                        Enabled = true,
                        AnchorFrom = "LEFT",
                        AnchorTo = "LEFT",
                        OffsetX = 3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                    },
                    Time = {
                        Enabled = true,
                        AnchorFrom = "RIGHT",
                        AnchorTo = "RIGHT",
                        OffsetX = -3,
                        OffsetY = 0,
                        FontSize = 12,
                        Colour = {1, 1, 1, 1},
                    },
                }
            },
            PowerBar = {
                Enabled = true,
                Height = 3,
                ColourByType = true,
                ColourBackgroundByType = true,
                Alignment = "BOTTOM",
                FGColour = {8/255, 8/255, 8/255, 0.8},
                BGColour = {26/255, 26/255, 26/255, 1},
                DarkenFactor = 0.75,
                InverseGrowth = false,
                Text = {
                    Enabled = false,
                    AnchorFrom = "RIGHT",
                    AnchorParent = "POWER",
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
                },
                RaidTargetMarker = {
                    Enabled = true,
                    Size = 24,
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    OffsetX = 0,
                    OffsetY = 0,
                },
                TargetIndicator = {
                    Enabled = true,
                    Colour = {1, 1, 1, 1},
                    Style = "GLOW"
                }
            },
            Portrait = {
                Enabled = true,
                Size = 42,
                AnchorFrom = "RIGHT",
                AnchorTo = "LEFT",
                OffsetX = -1,
                OffsetY = 0,
                Zoom = 0.3,
                MatchFrameHeight = true,
            },
            Tags = {
                TagOne = {
                    AnchorFrom = "LEFT",
                    AnchorTo = "LEFT",
                    Tag = "[name]",
                    OffsetX = 3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagTwo = {
                    AnchorFrom = "RIGHT",
                    AnchorTo = "RIGHT",
                    Tag = "[curhpperhp:abbr]",
                    OffsetX = -3,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagThree = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
                TagFour = {
                    AnchorFrom = "CENTER",
                    AnchorTo = "CENTER",
                    Tag = "",
                    OffsetX = 0,
                    OffsetY = 0,
                    FontSize = 12,
                    Colour = {1, 1, 1, 1},
                },
            },
        },
    },
}