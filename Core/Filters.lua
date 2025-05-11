local _, UUF = ...

local DebuffBlacklist = {
}

local BuffBlacklist = {
    [440837] = true, -- "Fury of Xuen"
    [415603] = true, -- "Encapsulated Destiny"
    [404468] = true, -- "Flight Style: Steady"    
}

function UUF:FetchDebuffBlacklist()
    return DebuffBlacklist
end

function UUF:FetchBuffBlacklist()
    return BuffBlacklist
end