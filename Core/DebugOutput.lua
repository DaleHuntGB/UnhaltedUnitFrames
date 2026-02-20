-- DebugOutput.lua - Unified output system for all addon systems
-- Routes messages to either chat, debug panel, or both based on tier and settings

local TIER_CRITICAL = 1  -- Errors, validation failures - always shown
local TIER_INFO = 2      -- Addon load, settings applied - optional
local TIER_DEBUG = 3     -- Detailed traces, metrics - debug only

local DebugOutput = {}
DebugOutput.__index = DebugOutput

-- Initialize output system
function DebugOutput:Init()
	self.messageBuffer = {}
	
	-- Safe access to debug settings (may not exist on first load)
	if UUF.db and UUF.db.profile and UUF.db.profile.Debug then
		self.maxMessages = UUF.db.profile.Debug.maxMessages or 500
	else
		self.maxMessages = 500
	end
	
	print("|cFF00B0F7UnhaltedUnitFrames|r: Loaded with |cFF00FF0018|r performance enhancements")
	print("|cFF888888Type /uufdebug to enable detailed output|r")
end

-- Main output function - all systems should use this
function DebugOutput:Output(system, message, tier)
	tier = tier or TIER_DEBUG
	
	-- Validate inputs
	if not system or not message then
		return
	end
	
	-- Check database availability for tier filtering (but don't block output)
	local dbReady = UUF.db and UUF.db.profile and UUF.db.profile.Debug
	
	-- Tier filtering (only when database ready)
	if dbReady then
		if tier == TIER_DEBUG then
			-- DEBUG requires enabled flag AND system flag
			if not UUF.db.profile.Debug.enabled then return end
			if not UUF.db.profile.Debug.systems[system] then return end
		end
		-- TIER_INFO and TIER_CRITICAL always pass through
	end
	
	-- Format message (use safe defaults if database not ready)
	local timestamp = ""
	if dbReady and UUF.db.profile.Debug.timestamp then
		timestamp = "[" .. date("%H:%M:%S") .. "] "
	elseif not dbReady then
		timestamp = "[" .. date("%H:%M:%S") .. "] "  -- Always timestamp if DB not ready
	end
	
	local tierName = tier == TIER_CRITICAL and "ERROR" or tier == TIER_INFO and "INFO" or "DEBUG"
	local color = self:GetColorForTier(tier)  -- Has safe defaults
	local formatted = color .. timestamp .. system .. ": " .. message .. "|r"
	
	-- Store in buffer (always, even if DB not ready)
	table.insert(self.messageBuffer, {
		timestamp = time(),
		system = system,
		message = message,
		tier = tier,
		formatted = formatted
	})
	
	-- Enforce max messages (use safe default if DB not ready)
	local maxMessages = (dbReady and UUF.db.profile.Debug.maxMessages) or self.maxMessages or 500
	if #self.messageBuffer > maxMessages then
		table.remove(self.messageBuffer, 1)
	end
	
	-- Route to output channels (always, even if DB not ready)
	if tier == TIER_CRITICAL then
		-- Always show errors in chat
		print(formatted)
		if UUF.DebugPanel then
			UUF.DebugPanel:AddMessage(formatted)
		end
	elseif tier == TIER_INFO then
		-- Always show info in panel (user opened panel to see info)
		if UUF.DebugPanel then
			UUF.DebugPanel:AddMessage(formatted)
		end
	elseif tier == TIER_DEBUG then
		-- Show debug in panel (already filtered above if DB ready)
		if UUF.DebugPanel then
			UUF.DebugPanel:AddMessage(formatted)
		end
	end
end

-- Get color for tier
function DebugOutput:GetColorForTier(tier)
	-- Safe defaults if database not ready
	if not UUF.db or not UUF.db.profile or not UUF.db.profile.Debug or not UUF.db.profile.Debug.colors then
		if tier == TIER_CRITICAL then
			return "|cFFFF0000"
		elseif tier == TIER_INFO then
			return "|cFF00B0F7"
		else
			return "|cFF888888"
		end
	end
	
	if tier == TIER_CRITICAL then
		return UUF.db.profile.Debug.colors.critical or "|cFFFF0000"
	elseif tier == TIER_INFO then
		return UUF.db.profile.Debug.colors.info or "|cFF00B0F7"
	else
		return UUF.db.profile.Debug.colors.debug or "|cFF888888"
	end
end

-- Public tier constants
DebugOutput.TIER_CRITICAL = TIER_CRITICAL
DebugOutput.TIER_INFO = TIER_INFO
DebugOutput.TIER_DEBUG = TIER_DEBUG

-- Get all buffered messages
function DebugOutput:GetAllMessages()
	return self.messageBuffer
end

-- Get messages filtered by system
function DebugOutput:GetMessagesForSystem(system)
	local result = {}
	for _, msg in ipairs(self.messageBuffer) do
		if msg.system == system then
			table.insert(result, msg)
		end
	end
	return result
end

-- Get messages filtered by tier
function DebugOutput:GetMessagesForTier(tier)
	local result = {}
	for _, msg in ipairs(self.messageBuffer) do
		if msg.tier == tier then
			table.insert(result, msg)
		end
	end
	return result
end

-- Clear all messages
function DebugOutput:Clear()
	self.messageBuffer = {}
	if UUF.DebugPanel then
		UUF.DebugPanel:ClearMessages()
	end
end

-- Export messages as formatted text
function DebugOutput:ExportAsText()
	local lines = {}
	for _, msg in ipairs(self.messageBuffer) do
		table.insert(lines, msg.formatted)
	end
	return table.concat(lines, "\n")
end

-- Toggle debug mode
function DebugOutput:SetEnabled(enabled)
	if not UUF.db or not UUF.db.profile or not UUF.db.profile.Debug then
		print("|cFFFF0000UUF: Addon not fully loaded yet. Try again in a moment.|r")
		return false
	end
	
	UUF.db.profile.Debug.enabled = enabled
	if enabled then
		print("|cFF00B0F7Debug Mode: Enabled (DEBUG tier messages will now appear)|r")
	else
		print("|cFF00B0F7Debug Mode: Disabled (only INFO and CRITICAL messages)|r")
	end
	return true
end

-- Get debug mode state
function DebugOutput:GetEnabled()
	if not UUF.db or not UUF.db.profile or not UUF.db.profile.Debug then
		return false  -- Default to disabled if DB not ready
	end
	return UUF.db.profile.Debug.enabled
end

-- Toggle specific system debugging
function DebugOutput:ToggleSystem(system)
	if not UUF.db or not UUF.db.profile or not UUF.db.profile.Debug or not UUF.db.profile.Debug.systems then
		print("|cFFFF0000UUF: Addon not fully loaded yet. Try again in a moment.|r")
		return false
	end
	
	if not UUF.db.profile.Debug.systems[system] then
		UUF.db.profile.Debug.systems[system] = {}
	end
	
	local enabled = not UUF.db.profile.Debug.systems[system]
	UUF.db.profile.Debug.systems[system] = enabled
	
	local status = enabled and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"
	print("|cFF00B0F7" .. system .. ": " .. status .. "|r")
	return true
end

-- Singleton instance
if not UUF.DebugOutput then
	UUF.DebugOutput = DebugOutput
else
	-- Merge methods if already exists
	for k, v in pairs(DebugOutput) do
		if type(v) == "function" then
			UUF.DebugOutput[k] = v
		end
	end
end

return DebugOutput



