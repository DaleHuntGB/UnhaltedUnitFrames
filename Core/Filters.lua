local _, UUF = ...

local DebuffBlacklist = {
    [57723] = true, -- Exhaustion
    [390435] = true, -- Exhaustion
    [264689] = true, -- Fatigued
    [57724] = true, -- Sated
    [95809] = true, -- Sated
    [206151] = true, -- Challenger's Burden
    [113942] = true, -- Demonic Gateway
}

local BuffBlacklist = {
    [440837] = true, -- Fury of Xuen
    [440839] = true, -- Kindness of Chi-Ji
    [440836] = true, -- Essence of Yu'lon
    [440838] = true, -- Fortitude of Niuzao
    [415603] = true, -- Encapsulated Destiny
    [404468] = true, -- Flight Style: Steady
    [404464] = true, -- Flight Style: Skyriding
    [341770] = true, -- Accursed
    [245686] = true, -- Fashionable!
}

function UUF:FetchDebuffBlacklist()
    return DebuffBlacklist
end

function UUF:FetchBuffBlacklist()
    return BuffBlacklist
end
