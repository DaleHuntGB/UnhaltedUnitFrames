local _, UUF = ...
local UnhaltedUF = LibStub("AceAddon-3.0"):NewAddon("UnhaltedUF")

UUF.Defaults = {
    global = {
        TestMode = false,
        General = {
            UIScale                 = 0.5333333333333,
            Font                    = "Fonts\\FRIZQT__.TTF",
            FontFlag                = "OUTLINE",
            FontShadowColour        = {0, 0, 0, 1},
            FontShadowXOffset       = 0,
            FontShadowYOffset       = 0,
            ForegroundTexture       = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
            BackgroundTexture       = "Interface\\Buttons\\WHITE8X8",
            BorderTexture           = "Interface\\Buttons\\WHITE8X8",
            BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            ForegroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            BorderColour            = {0 / 255, 0 / 255, 0 / 255, 1},
            BorderSize              = 1,
            BorderInset             = 1,
            ColourByClass           = true,
            ColourByReaction        = true,
            ColourIfDisconnected    = true,
            ColourIfTapped          = true,
            CustomColours = {
                Reaction = {
                    [1] = {255/255, 64/255, 64/255},            -- Hated
                    [2] = {255/255, 64/255, 64/255},            -- Hostile
                    [3] = {255/255, 128/255, 64/255},           -- Unfriendly
                    [4] = {255/255, 255/255, 64/255},           -- Neutral
                    [5] = {64/255, 255/255, 64/255},            -- Friendly
                    [6] = {64/255, 255/255, 64/255},            -- Honored
                    [7] = {64/255, 255/255, 64/255},            -- Revered
                    [8] = {64/255, 255/255, 64/255},            -- Exalted
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
                }
            }
            
        },
        Player = {
            Frame = {
                Width               = 272,
                Height              = 42,
                XPosition           = -425.1,
                YPosition           = -275.1,
                AnchorFrom          = "CENTER",
                AnchorTo            = "CENTER",
                AnchorParent        = "UIParent",
            },
            Portrait = {
                Enabled         = false,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "RIGHT",
                AnchorTo        = "LEFT",
            },
            Health = {
                Direction = "LR",
                Absorbs = {
                    Enabled         = true,
                    Colour          = {255/255, 205/255, 0/255, 1},
                    ColourByType    = true,
                }
            },
            PowerBar = {
                Enabled                 = false,
                Height                  = 3,
                ColourByType            = true,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            },
            Buffs = {
                Enabled             = false,
                Size                = 38,
                Spacing             = 1,
                Num                 = 7,
                AnchorFrom          = "BOTTOMLEFT",
                AnchorTo            = "TOPLEFT",
                XOffset             = 0,
                YOffset             = 1,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            Debuffs = {
                Enabled             = false,
                Size                = 38,
                Spacing             = 1,
                Num                 = 7,
                AnchorFrom          = "BOTTOMLEFT",
                AnchorTo            = "TOPLEFT",
                XOffset             = 0,
                YOffset             = 1,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom      = "BOTTOMRIGHT",
                    AnchorTo        = "BOTTOMRIGHT",
                }
            },
            TargetMarker = {
                Enabled             = true,
                Size                = 24,
                XOffset             = 3,
                YOffset             = 0,
                AnchorFrom          = "LEFT",
                AnchorTo            = "TOPLEFT",
            },
            Texts = {
                Left = {
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "",
                },
                Right = {
                    FontSize        = 12,
                    XOffset         = -3,
                    YOffset         = 0,
                    Tag             = "[Health:CurHPwithPerHP]",
                },
                Center = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 0,
                    Tag             = "",
                },
                AdditionalTexts = {
                    TopLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    TopRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }
            }
        },
        Target = {
            Frame = {
                Width               = 272,
                Height              = 42,
                XPosition           = 425.1,
                YPosition           = -275.1,
                AnchorFrom          = "CENTER",
                AnchorTo            = "CENTER",
                AnchorParent        = "UIParent",
            },
            Portrait = {
                Enabled         = false,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "LEFT",
                AnchorTo        = "RIGHT",
            },
            Health = {
                Direction = "LR",
                Absorbs = {
                    Enabled         = true,
                    Colour          = {255/255, 205/255, 0/255, 1},
                    ColourByType    = true,
                }
            },
            PowerBar = {
                Enabled                 = false,
                Height                  = 3,
                ColourByType            = true,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            },
            Buffs = {
                Enabled             = true,
                Size                = 38,
                Spacing             = 1,
                Num                 = 7,
                AnchorFrom          = "BOTTOMLEFT",
                AnchorTo            = "TOPLEFT",
                XOffset             = 0,
                YOffset             = 1,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            Debuffs = {
                Enabled             = false,
                Size                = 38,
                Spacing             = 1,
                Num                 = 3,
                AnchorFrom          = "BOTTOMRIGHT",
                AnchorTo            = "TOPRIGHT",
                XOffset             = 0,
                YOffset             = 1,
                GrowthX             = "LEFT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            TargetMarker = {
                Enabled             = true,
                Size                = 24,
                XOffset             = -3,
                YOffset             = 0,
                AnchorFrom          = "RIGHT",
                AnchorTo            = "TOPRIGHT",
            },
            Texts = {
                Left = {
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "[Name:NamewithTargetTarget:LastNameOnly]",
                },
                Right = {
                    FontSize        = 12,
                    XOffset         = -3,
                    YOffset         = 0,
                    Tag             = "[Health:CurHPwithPerHP]",
                },
                Center = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 0,
                    Tag             = "",
                },
                AdditionalTexts = {
                    TopLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    TopRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomRight = {
                        FontSize        = 12,
                        XOffset         = -3,
                        YOffset         = -3,
                        Tag             = "[powercolor][Power:CurPP]",
                    },
                }  
            }
        },
        TargetTarget = {
            Frame = {
                Enabled             = false,
                Width               = 100,
                Height              = 42,
                XPosition           = 1.1,
                YPosition           = 0,
                AnchorFrom          = "TOPLEFT",
                AnchorTo            = "TOPRIGHT",
                AnchorParent        = "UUF_Target",
            },
            Portrait = {
                Enabled         = false,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "RIGHT",
                AnchorTo        = "LEFT",
            },
            Health = {
                Absorbs = {
                    Enabled         = false,
                    Colour          = {255/255, 205/255, 0/255, 1},
                    ColourByType    = true,
                }
            },
            PowerBar = {
                Enabled                 = false,
                Height                  = 3,
                ColourByType            = true,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            },
            Buffs = {
                Enabled             = false,
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 1,
                YOffset             = 0,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            Debuffs = {
                Enabled             = false,
                Size                = 38,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 0,
                YOffset             = 0,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            TargetMarker = {
                Enabled             = true,
                Size                = 24,
                XOffset             = -3,
                YOffset             = 0,
                AnchorFrom          = "RIGHT",
                AnchorTo            = "TOPRIGHT",
            },
            Texts = {
                Left = {
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "",
                },
                Right = {
                    FontSize        = 12,
                    XOffset         = -3,
                    YOffset         = 0,
                    Tag             = "",
                },
                Center = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 0,
                    Tag             = "[Name:LastNameOnly]",
                },
                AdditionalTexts = {
                    TopLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    TopRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }  
            }
        },
        Focus = {
            Frame = {
                Enabled             = true,
                Width               = 272,
                Height              = 36,
                XPosition           = 0,
                YPosition           = 40.1,
                AnchorFrom          = "BOTTOMRIGHT",
                AnchorTo            = "TOPRIGHT",
                AnchorParent        = "UUF_Target",
            },
            Portrait = {
                Enabled         = false,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "RIGHT",
                AnchorTo        = "LEFT",
            },
            Health = {
                Direction = "LR",
                Absorbs = {
                    Enabled         = false,
                    Colour          = {255/255, 205/255, 0/255, 1},
                    ColourByType    = true,
                }
            },
            PowerBar = {
                Enabled                 = false,
                Height                  = 3,
                ColourByType            = true,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            },
            Buffs = {
                Enabled             = false,
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 1,
                YOffset             = 0,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            Debuffs = {
                Enabled             = false,
                Size                = 38,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 0,
                YOffset             = 0,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            TargetMarker = {
                Enabled             = true,
                Size                = 24,
                XOffset             = -3,
                YOffset             = 0,
                AnchorFrom          = "RIGHT",
                AnchorTo            = "TOPRIGHT",
            },
            Texts = {
                Left = {
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "[Name:LastNameOnly]",
                },
                Right = {
                    FontSize        = 12,
                    XOffset         = -3,
                    YOffset         = 0,
                    Tag             = "[Health:PerHPwithAbsorbs]",
                },
                Center = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 0,
                    Tag             = "",
                },
                AdditionalTexts = {
                    TopLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    TopRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }  
            }
        },
        Pet = {
            Frame = {
                Enabled             = true,
                Width               = 272,
                Height              = 10,
                XPosition           = 0,
                YPosition           = -1.1,
                AnchorFrom          = "TOPLEFT",
                AnchorTo            = "BOTTOMLEFT",
                AnchorParent        = "UUF_Player",
            },
            Portrait = {
                Enabled         = false,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "RIGHT",
                AnchorTo        = "LEFT",
            },
            Health = {
                Direction = "LR",
                Absorbs = {
                    Enabled         = false,
                    Colour          = {255/255, 205/255, 0/255, 1},
                    ColourByType    = true,
                }
            },
            PowerBar = {
                Enabled                 = false,
                Height                  = 3,
                ColourByType            = true,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            },
            Buffs = {
                Enabled             = false,
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 1,
                YOffset             = 0,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            Debuffs = {
                Enabled             = false,
                Size                = 38,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 0,
                YOffset             = 0,
                GrowthX             = "RIGHT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            TargetMarker = {
                Enabled             = false,
                Size                = 24,
                XOffset             = 0,
                YOffset             = 0,
                AnchorFrom          = "CENTER",
                AnchorTo            = "CENTER",
            },
            Texts = {
                Left = {
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "",
                },
                Right = {
                    FontSize        = 12,
                    XOffset         = -3,
                    YOffset         = 0,
                    Tag             = "",
                },
                Center = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 0,
                    Tag             = "",
                },
                AdditionalTexts = {
                    TopLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    TopRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                }                
            }
        },
        Boss = {
            Frame = {
                Width               = 250,
                Height              = 42,
                XPosition           = 750.1,
                YPosition           = 0.1,
                Spacing             = 1,
                AnchorFrom          = "CENTER",
                AnchorTo            = "CENTER",
                AnchorParent        = "UIParent",
            },
            Portrait = {
                Enabled         = true,
                Size            = 42,
                XOffset         = -1,
                YOffset         = 0,
                AnchorFrom      = "RIGHT",
                AnchorTo        = "LEFT",
            },
            Health = {
                Direction = "LR",
                Absorbs = {
                    Enabled         = true,
                    Colour          = {255/255, 205/255, 0/255, 1},
                    ColourByType    = true,
                }
            },
            PowerBar = {
                Enabled                 = true,
                Height                  = 3,
                ColourByType            = true,
                Colour                  = {0/255, 0/255, 1/255, 1},
                BackgroundColour        = {26 / 255, 26 / 255, 26 / 255, 1},
            },
            Buffs = {
                Enabled             = true,
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "LEFT",
                AnchorTo            = "RIGHT",
                XOffset             = 1,
                YOffset             = 0,
                GrowthX             = "LEFT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            Debuffs = {
                Enabled             = false,
                Size                = 42,
                Spacing             = 1,
                Num                 = 1,
                AnchorFrom          = "RIGHT",
                AnchorTo            = "LEFT",
                XOffset             = -1,
                YOffset             = 0,
                GrowthX             = "LEFT",
                GrowthY             = "UP",
                Count               = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 3,
                    AnchorFrom     = "BOTTOMRIGHT",
                    AnchorTo       = "BOTTOMRIGHT",
                }
            },
            TargetMarker = {
                Enabled             = true,
                Size                = 24,
                XOffset             = -3,
                YOffset             = 0,
                AnchorFrom          = "RIGHT",
                AnchorTo            = "TOPRIGHT",
            },
            Texts = {
                Left = {
                    FontSize        = 12,
                    XOffset         = 3,
                    YOffset         = 0,
                    Tag             = "[Name:LastNameOnly]",
                },
                Right = {
                    FontSize        = 12,
                    XOffset         = -3,
                    YOffset         = 0,
                    Tag             = "[Health:CurHPwithPerHP]",
                },
                Center = {
                    FontSize        = 12,
                    XOffset         = 0,
                    YOffset         = 0,
                    Tag             = "",
                },
                AdditionalTexts = {
                    TopLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    TopRight = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomLeft = {
                        FontSize        = 12,
                        XOffset         = 0,
                        YOffset         = 0,
                        Tag             = "",
                    },
                    BottomRight = {
                        FontSize        = 12,
                        XOffset         = -3,
                        YOffset         = -3,
                        Tag             = "[powercolor][Power:CurPP]",
                    },
                }
            }
        }
    }
}

function UnhaltedUF:OnInitialize()
    UUF.DB = LibStub("AceDB-3.0"):New("UUFDB", UUF.Defaults)
    for k, v in pairs(UUF.Defaults) do
        if UUF.DB.global[k] == nil then
            UUF.DB.global[k] = v
        end
    end
end

function UnhaltedUF:OnEnable()
    UIParent:SetScale(UUF.DB.global.General.UIScale)
    UUF:LoadCustomColours()
    UUF:SpawnUnitFrame("Player")
    UUF:SpawnUnitFrame("Target")
    UUF:SpawnUnitFrame("TargetTarget")
    UUF:SpawnUnitFrame("Focus")
    UUF:SpawnUnitFrame("Pet")
    UUF:SpawnUnitFrame("Boss")
    UUF:SetupSlashCommands()
end