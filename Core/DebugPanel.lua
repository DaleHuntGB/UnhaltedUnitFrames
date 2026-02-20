-- DebugPanel.lua - Scrollable debug message panel UI
-- Displays addon debug messages without spamming chat

local DebugPanel = {}
DebugPanel.__index = DebugPanel

function DebugPanel:New()
	local self = setmetatable({}, DebugPanel)
	self.frame = nil
	self.visible = false
	self.messages = {}
	return self
end

function DebugPanel:Create()
	if self.frame then return end
	
	-- Main frame
	local frame = CreateFrame("Frame", "UUFDebugPanel", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(600, 400)
	frame:SetPoint("CENTER", UIParent, "CENTER", 300, -100)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		if UUF.db and UUF.db.profile and UUF.db.profile.Debug then
			UUF.db.profile.Debug.panel = {
				x = self:GetLeft(),
				y = self:GetTop()
			}
		end
	end)
	
	-- Title
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -8)
	frame.title:SetText("|cFF00B0F7UUF Debug Console|r")
	
	-- Note: BasicFrameTemplateWithInset already has close button, don't create duplicate
	
	-- Scroll frame for messages
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 45)
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, 14, function()
			UUF.DebugPanel:Refresh()
		end)
	end)
	
	self.scrollFrame = scrollFrame  -- Store reference for Refresh()
	
	-- Message text frame
	local textFrame = CreateFrame("Frame", nil, scrollFrame)
	textFrame:SetSize(550, 1)
	scrollFrame:SetScrollChild(textFrame)
	
	-- Create font strings for messages
	local function CreateMessageLine()
		local line = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		line:SetJustifyH("LEFT")
		line:SetJustifyV("TOP")
		return line
	end
	
	-- Pre-create message lines
	self.messageLines = {}
	for i = 1, 100 do
		self.messageLines[i] = CreateMessageLine()
		if i == 1 then
			self.messageLines[i]:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 5, 0)
		else
			self.messageLines[i]:SetPoint("TOPLEFT", self.messageLines[i-1], "BOTTOMLEFT", 0, -2)
		end
	end
	
	-- Button row
	local btnFrame = CreateFrame("Frame", nil, frame)
	btnFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
	btnFrame:SetSize(580, 30)
	
	-- Enable/Disable debug toggle
	local debugToggle = CreateFrame("Button", nil, btnFrame, "GameMenuButtonTemplate")
	debugToggle:SetPoint("LEFT", btnFrame, "LEFT", 0, 0)
	debugToggle:SetSize(100, 25)
	local function UpdateToggleText()
		if not UUF.DebugOutput then
			debugToggle:SetText("|cFFFF0000Loading...|r")
			return
		end
		local enabled = UUF.DebugOutput:GetEnabled()
		debugToggle:SetText(enabled and "|cFF00FF00Enabled|r" or "|cFF888888Disabled|r")
	end
	UpdateToggleText()
	debugToggle:SetScript("OnClick", function()
		if UUF.DebugOutput then
			-- Debug: Check database state
			if not UUF.db then
				print("|cFFFF0000DEBUG: UUF.db is nil!|r")
				return
			elseif not UUF.db.global then
				print("|cFFFF0000DEBUG: UUF.db.global is nil!|r")
				return
			elseif not UUF.db.profile.Debug then
				print("|cFFFF0000DEBUG: UUF.db.profile.Debug is nil!|r")
				return
			end
			
			local currentState = UUF.DebugOutput:GetEnabled()
			local success = UUF.DebugOutput:SetEnabled(not currentState)
			if success then
				UpdateToggleText()
			end
		end
	end)
	
	-- Clear button
	local clearBtn = CreateFrame("Button", nil, btnFrame, "GameMenuButtonTemplate")
	clearBtn:SetPoint("LEFT", debugToggle, "RIGHT", 10, 0)
	clearBtn:SetSize(80, 25)
	clearBtn:SetText("Clear")
	clearBtn:SetScript("OnClick", function()
		UUF.DebugOutput:Clear()
		UUF.DebugPanel:Refresh()
	end)
	
	-- Export button
	local exportBtn = CreateFrame("Button", nil, btnFrame, "GameMenuButtonTemplate")
	exportBtn:SetPoint("LEFT", clearBtn, "RIGHT", 10, 0)
	exportBtn:SetSize(80, 25)
	exportBtn:SetText("Export")
	exportBtn:SetScript("OnClick", function()
		UUF.DebugPanel:ShowExportDialog()
	end)
	
	-- Settings button
	local settingsBtn = CreateFrame("Button", nil, btnFrame, "GameMenuButtonTemplate")
	settingsBtn:SetPoint("LEFT", exportBtn, "RIGHT", 10, 0)
	settingsBtn:SetSize(80, 25)
	settingsBtn:SetText("Settings")
	settingsBtn:SetScript("OnClick", function()
		if self.settingsFrame and self.settingsFrame:IsShown() then
			self.settingsFrame:Hide()
		else
			UUF.DebugPanel:ShowSettings()
		end
	end)
	
	frame:Hide()
	self.frame = frame
	self.scrollFrame = scrollFrame
	self.textFrame = textFrame
end

function DebugPanel:AddMessage(message)
	-- Check if user is scrolled to bottom BEFORE modifying messages
	local wasAtBottom = false
	if self.frame and self.scrollFrame then
		local numMessages = #self.messages
		local numDisplayLines = 20
		local maxOffset = math.max(0, numMessages - numDisplayLines)
		local currentOffset = FauxScrollFrame_GetOffset(self.scrollFrame)
		wasAtBottom = (currentOffset >= maxOffset - 1)  -- Within 1 line of bottom
	end
	
	-- Always store messages, even if frame not created yet
	table.insert(self.messages, message)
	
	-- Keep last 500 messages
	if #self.messages > 500 then
		table.remove(self.messages, 1)
	end
	
	-- Refresh display if frame exists
	if self.frame and self.scrollFrame then
		-- Refresh to show new message
		self:Refresh()
		
		-- If user was at bottom, keep them at bottom after new message
		if wasAtBottom then
			local numDisplayLines = 20
			local newMaxOffset = math.max(0, #self.messages - numDisplayLines)
			FauxScrollFrame_SetOffset(self.scrollFrame, newMaxOffset)
			self:Refresh()
		end
	end
end

function DebugPanel:ClearMessages()
	self.messages = {}
	if self.scrollFrame then
		FauxScrollFrame_SetOffset(self.scrollFrame, 0)
	end
	self:Refresh()
end

function DebugPanel:Refresh()
	if not self.frame or not self.scrollFrame then return end
	
	local numMessages = #self.messages
	local numDisplayLines = 20  -- Number of visible lines in the scroll area
	
	-- Update scrollbar
	FauxScrollFrame_Update(self.scrollFrame, numMessages, numDisplayLines, 14)
	
	local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
	
	-- Update message display (oldest to newest, top to bottom)
	for i = 1, numDisplayLines do
		local messageIndex = offset + i
		if messageIndex > 0 and messageIndex <= numMessages then
			self.messageLines[i]:SetText(self.messages[messageIndex])
			self.messageLines[i]:Show()
		else
			self.messageLines[i]:SetText("")
			self.messageLines[i]:Hide()
		end
	end
	
	-- Hide remaining pre-created lines
	for i = numDisplayLines + 1, 100 do
		self.messageLines[i]:SetText("")
		self.messageLines[i]:Hide()
	end
end

function DebugPanel:ExportAsText()
	-- Export messages in chronological order (oldest first)
	local lines = {}
	for i = 1, #self.messages do
		table.insert(lines, self.messages[i])
	end
	return table.concat(lines, "\n")
end

function DebugPanel:ShowExportDialog()
	local text = self:ExportAsText()
	
	if text == "" then
		print("|cFFFF0000UUF: No debug messages to export|r")
		return
	end
	
	-- Create or reuse export frame
	if not self.exportFrame then
		local frame = CreateFrame("Frame", "UUFDebugExportFrame", UIParent, "BasicFrameTemplateWithInset")
		frame:SetSize(500, 400)
		frame:SetPoint("CENTER", UIParent, "CENTER")
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", frame.StartMoving)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:SetFrameStrata("DIALOG")
		frame:Hide()
		
		-- Title
		frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -8)
		frame.title:SetText("|cFF00B0F7Export Debug Log|r")
		
		-- Instructions
		frame.instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.instructions:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
		frame.instructions:SetText("|cFF888888Press Ctrl+A to select all, then Ctrl+C to copy|r")
		
		-- Scroll frame
		local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
		scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
		
		-- EditBox (scrollable)
		local editBox = CreateFrame("EditBox", nil, scrollFrame)
		editBox:SetMultiLine(true)
		editBox:SetFontObject(GameFontNormal)
		editBox:SetWidth(450)
		editBox:SetAutoFocus(false)
		editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
		
		scrollFrame:SetScrollChild(editBox)
		
		frame.editBox = editBox
		self.exportFrame = frame
	end
	
	-- Populate and show
	self.exportFrame.editBox:SetText(text)
	self.exportFrame.editBox:SetCursorPosition(0)
	self.exportFrame.editBox:HighlightText()
	self.exportFrame:Show()
end

function DebugPanel:ShowSettings()
	if self.settingsFrame then
		self.settingsFrame:Show()
		return
	end
	
	local frame = CreateFrame("Frame", "UUFDebugSettings", UIParent, "BasicFrameTemplateWithInset")
	frame:SetSize(300, 400)
	frame:SetPoint("CENTER", UIParent, "CENTER", -350, -100)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	
	-- Title
	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -8)
	title:SetText("Debug Settings")
	
	-- Note: BasicFrameTemplateWithInset already has close button, don't create duplicate
	
	-- Help text
	local helpText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	helpText:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
	helpText:SetText("|cFF888888Enable systems to see DEBUG tier messages:|r")
	helpText:SetJustifyH("LEFT")
	
	-- Enable All / Disable All buttons
	local enableAllBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
	enableAllBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
	enableAllBtn:SetSize(90, 25)
	enableAllBtn:SetText("Enable All")
	enableAllBtn:SetScript("OnClick", function()
		if UUF.db and UUF.db.profile and UUF.db.profile.Debug and UUF.db.profile.Debug.systems then
			for system in pairs(UUF.db.profile.Debug.systems) do
				UUF.db.profile.Debug.systems[system] = true
			end
			print("|cFF00B0F7UUF: All debug systems enabled|r")
			-- Refresh settings panel to update checkboxes
			self.settingsFrame:Hide()
			self.settingsFrame = nil
			self:ShowSettings()
		else
			print("|cFFFF0000UUF: Addon not fully loaded yet. Try again in a moment.|r")
		end
	end)
	
	local disableAllBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
	disableAllBtn:SetPoint("LEFT", enableAllBtn, "RIGHT", 10, 0)
	disableAllBtn:SetSize(90, 25)
	disableAllBtn:SetText("Disable All")
	disableAllBtn:SetScript("OnClick", function()
		if UUF.db and UUF.db.profile and UUF.db.profile.Debug and UUF.db.profile.Debug.systems then
			for system in pairs(UUF.db.profile.Debug.systems) do
				UUF.db.profile.Debug.systems[system] = false
			end
			print("|cFF00B0F7UUF: All debug systems disabled|r")
			-- Refresh settings panel to update checkboxes
			self.settingsFrame:Hide()
			self.settingsFrame = nil
			self:ShowSettings()
		else
			print("|cFFFF0000UUF: Addon not fully loaded yet. Try again in a moment.|r")
		end
	end)
	
	-- Scroll frame for system checkboxes
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -95)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
	
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(250, 1)
	scrollFrame:SetScrollChild(scrollChild)
	
	-- Create checkboxes for each system
	local y = 0
	if UUF.db and UUF.db.profile and UUF.db.profile.Debug and UUF.db.profile.Debug.systems then
		for system in pairs(UUF.db.profile.Debug.systems) do
			local checkbox = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
			checkbox:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, y)
			checkbox:SetChecked(UUF.db.profile.Debug.systems[system])
			checkbox:SetScript("OnClick", function(self)
				UUF.db.profile.Debug.systems[system] = self:GetChecked()
			end)
			
			local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
			label:SetText(system)
			
			y = y - 25
		end
	end
	
	scrollChild:SetHeight(math.abs(y) + 20)
	
	self.settingsFrame = frame
end

function DebugPanel:Show()
	if not self.frame then
		self:Create()
		-- Add welcome message explaining what appears in the console
		self:AddMessage("|cFF00B0F7=== UUF Debug Console ===|r")
		self:AddMessage("|cFF888888INFO and CRITICAL messages appear automatically.|r")
		self:AddMessage("|cFF888888Enable debug mode to see DEBUG tier messages.|r")
		self:AddMessage(" ")
	end
	
	-- Ensure scroll is at bottom (newest messages) when opening panel
	if self.scrollFrame then
		local numMessages = #self.messages
		local numDisplayLines = 20
		local maxOffset = math.max(0, numMessages - numDisplayLines)
		FauxScrollFrame_SetOffset(self.scrollFrame, maxOffset)
		self:Refresh()
	end
	
	self.frame:Show()
	self.visible = true
	if UUF.db and UUF.db.profile and UUF.db.profile.Debug then
		UUF.db.profile.Debug.showPanel = true
	end
end

function DebugPanel:Hide()
	if self.frame then
		self.frame:Hide()
	end
	self.visible = false
	if UUF.db and UUF.db.profile and UUF.db.profile.Debug then
		UUF.db.profile.Debug.showPanel = false
	end
end

function DebugPanel:Toggle()
	if self.visible then
		self:Hide()
	else
		self:Show()
	end
end

function DebugPanel:SetVisible(visible)
	if visible then
		self:Show()
	else
		self:Hide()
	end
end

function DebugPanel:IsVisible()
	return self.visible
end

-- Singleton instance
if not UUF.DebugPanel then
	UUF.DebugPanel = DebugPanel:New()
end

return DebugPanel



