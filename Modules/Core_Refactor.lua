local _, UUF = ...
local oUF = UUF.oUF
-- Event Frames
local uiScaleFrame = CreateFrame("Frame")
local rangeEventFrames = {}
local combatEventFrame = CreateFrame("Frame")

-- Configuration
local UUF_CONFIG = {
    General = {
        UIScale = 0.5333333333333,
        FrameStrata = "BACKGROUND",
        FrameLevel = 1,
        Font = "Fonts\\FRIZQT__.TTF",
        BarTexture = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
        FrameBG = "Interface\\Buttons\\WHITE8X8",
        FrameBGColour = {8/255, 8/255, 8/255, 0.75},
        FrameBorderColour = {0, 0, 0, 1},
        FrameBorderSize = 1,
        UseClassColours = true,
        UseReactionColours = true,
    },
    Player = {
        -- Frame Config
        FrameW = 200,
        FrameH = 50,
        FrameX = 0,
        FrameY = 0,
        -- Health Bar Config
        HealthBar = {
            SetFrameW = function(self) return self.FrameW - 2 end,
            SetFrameH = function(self) return self.FrameH - 2 end,
            Anchor = "TOPLEFT",
            XPos = 1,
            YPos = -1,
            Colour = {26/255, 26/255, 26/255, 1},
            -- Incoming Heals / Absorbs Bar Config
            ShowIncomingHeals = true,
            ShowAbsorbs = true,
            ShowHealAbsorbs = true,
            -- Incoming Heals
            SetIncomingHealsBarW = function(self) return self.FrameW - 2 end,
            SetIncomingHealsBarH = function(self) return self.FrameH - 2 end,
            IncomingHealsColour = {64/255, 255/255, 64/255, 1},
            -- Absorbs
            SetAbsorbsBarW = function(self) return self.FrameW - 2 end,
            SetAbsorbsBarH = function(self) return self.FrameH - 2 end,
            AbsorbsColour = {255/255, 205/255, 0/255, 1},
            -- Heal Absorbs
            SetHealAbsorbsBarW = function(self) return self.FrameW - 2 end,
            SetHealAbsorbsBarH = function(self) return self.FrameH - 2 end,
            HealAbsorbsColour = {128/255, 64/255, 255/255, 1},
        },
        NameText = {
            Anchor = "LEFT",
            XPos = 1,
            YPos = 0,
            FontSize = 12,
            Colour = {1, 1, 1, 1},
            Justify = "LEFT",
            Tag = "[name]",
        },
        -- Health Tag Config
        HealthText = {
            Anchor = "RIGHT",
            XPos = -1,
            YPos = 0,
            FontSize = 12,
            Colour = {1, 1, 1, 1},
            Justify = "RIGHT",
            Tag = "[curhp]",
        },
        -- Buffs Config
        Buffs =  {
            SetFrameW = function(self) return self.FrameW end,
            AnchorFrom = "BOTTOMLEFT",
            AnchorTo = "TOPLEFT",
            XPos = 0,
            YPos = 1,
            Size = 38,
            Limit = 4,
            Spacing = 1,
            GrowthX = "RIGHT",
            GrowthY = "UP",
        },
        Indicators = {
            RaidTarget = {
                Show = true,
                Anchor = "CENTER",
                XPos = 0,
                YPos = 0,
                Size = 24,
            },
            SummonIndicator = {
                Show = true,
                Anchor = "CENTER",
                XPos = 0,
                YPos = 0,
                Size = 24,
            },
            ReadyCheck = {
                Show = true,
                Anchor = "CENTER",
                XPos = 0,
                YPos = 0,
                Size = 24,
            },
            Combat = {
                Show = true,
                Anchor = "CENTER",
                XPos = 0,
                YPos = 0,
                Size = 24,
            },
        }
    },
}
-- End Configuration