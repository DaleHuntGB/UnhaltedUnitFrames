--[[
LibPlayerSpells-1.0 - Additional information about player spells.
(c) 2023 Rainrider (rainrider.wow@gmail.com)

This file is part of LibPlayerSpells-1.0.

LibPlayerSpells-1.0 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibPlayerSpells-1.0 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibPlayerSpells-1.0. If not, see <http://www.gnu.org/licenses/>.
--]]

local lib = LibStub('LibPlayerSpells-1.0')
if not lib then
	return
end
lib:__RegisterSpells('EVOKER', 100005, 1, {
	COOLDOWN = {
		[351338] = 'INTERRUPT', -- Quell
		AURA = {
			HARMFUL = {
				357209, -- Fire Breath
				CROWD_CTRL = {
					[355689] = 'ROOT', -- Landslide (talent)
				},
			},
			HELPFUL = {
				RAIDBUFF = {
					 381748, -- Blessing of the Bronze
					 390386, -- Fury of the Aspects
					[390435] = 'INVERT_AURA', -- Exhaustion
				},
			},
			PERSONAL = {
				357210, -- Deep Breath
				358267, -- Hover
				370553, -- Tip the Scales (talent)
				370901, -- Leaping Flames (talent)
				371807, -- Recall
				BURST = {
					375087, -- Dragonrage (Devastation talent)
				},
				SURVIVAL = {
					363916, -- Obsidian Scales (talent)
					374348, -- Renewing Blaze (talent)
				},
			},
		},
	},
	AURA = {
		HARMFUL = {
			356995, -- Disintegrate
			361500, -- Living Flame
		},
		HELPFUL = {
			361509, -- Living Flame
		},
		PERSONAL = {
			359618, -- Essence Burst (Devastation)
			370454, -- Charged Blast (Devastation talent)
		}
	},
	DISPEL = {
		COOLDOWN = {
			HARMFUL = {
				[372048] = 'ENRAGE', -- Oppressing Roar (talent; only with Overawe)
			},
			HELPFUL = {
				[360823] = 'MAGIC POISON', -- Naturalize
				[365585] = 'POISON', -- Expunge (talent)
				[374251] = 'CURSE DISEASE POISON', -- Cauterizing Flame (talent) -- TODO: Bleed
			},
		},
	},
}, {
	-- map aura to provider(s)
	[355689] = 358385, -- Landslide
	[357209] = 382266, -- Fire Breath
	[359618] = 359565, -- Essence Burst (Devastation)
	[361500] = 365937, -- Living Flame <- Ruby Embers (Devastation talent)
	[361509] = 365937, -- Living Flame <- Ruby Embers (Devastation talent)
	[370454] = 370455, -- Charged Blast (Devastation talent)
	[370901] = 369939, -- Leaping Flames (talent)
	[371807] = 357210, -- Recall
	[381748] = 364342, -- Blessing of the Bronze
}, {
	-- map aura to modified spell(s)
	[359618] = { -- Essence Burst (Devastation)
		356995, -- Desintegrate
		357211, -- Pyre
	},
	[361500] = 361469, -- Living Flame
	[361509] = 361469, -- Living Flame
	[370454] = 357211, -- Charged Blast (Devastation talent) -> Pyre
	[370901] = 361469, -- Leaping Flames (talent) -> Living Flame
})
