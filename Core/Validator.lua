local _, UUF = ...

-- PERF LOCALS: Localize frequently-called globals for faster access
local GetTime = GetTime
local type, pairs, ipairs = type, pairs, ipairs

-- Validation & Testing System for Architecture Implementation
-- Provides sanity checks, performance monitoring, and integration validation

local Validator = {}
UUF.Validator = Validator

-- Validation checklist
Validator.CHECKS = {
    -- Core Systems
    "EventBusLoaded",
    "ArchitectureLoaded",
    "ConfigResolverLoaded",
    "FramePoolManagerLoaded",
    
    -- UI Systems
    "GUILayoutLoaded",
    "FramesSpawning",
    
    -- Integration Points
    "EventBusDispatchWorks",
    "FramePoolAcquisition",
    "ConfigResolution",
    "GuiBuilderWorks",
    
    -- Performance
    "NoMemoryLeaks",
    "EventHandlingEfficient",
}

Validator._results = {}
Validator._timestamps = {}

-- Register validation result
function Validator:RecordCheck(checkName, passed, details)
	self._results[checkName] = {
		passed = passed,
		details = details,
		timestamp = GetTime(),
	}
	
	if passed then
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("Validator", "✓ " .. checkName .. " PASSED", UUF.DebugOutput.TIER_INFO)
		end
	else
		if UUF.DebugOutput then
			UUF.DebugOutput:Output("Validator", "✗ " .. checkName .. " FAILED - " .. (details or "See logs"), UUF.DebugOutput.TIER_CRITICAL)
		end
	end
end

-- Validate all core systems are loaded
function Validator:CheckCoreSystemsLoaded()
    local ok = true
    
    if not UUF.Architecture then
        self:RecordCheck("ArchitectureLoaded", false, "Architecture.lua not loaded")
        ok = false
    else
        self:RecordCheck("ArchitectureLoaded", true)
    end
    
    if not UUF._eventBus then
        self:RecordCheck("EventBusLoaded", false, "EventBus not initialized")
        ok = false
    else
        self:RecordCheck("EventBusLoaded", true)
    end
    
    if not UUF.ConfigResolver then
        self:RecordCheck("ConfigResolverLoaded", false, "ConfigResolver.lua not loaded")
        ok = false
    else
        self:RecordCheck("ConfigResolverLoaded", true)
    end
    
    if not UUF.FramePoolManager then
        self:RecordCheck("FramePoolManagerLoaded", false, "FramePoolManager.lua not loaded")
        ok = false
    else
        self:RecordCheck("FramePoolManagerLoaded", true)
    end
    
    if not UUF.GUILayout then
        self:RecordCheck("GUILayoutLoaded", false, "GUILayout.lua not loaded")
        ok = false
    else
        self:RecordCheck("GUILayoutLoaded", true)
    end
    
    if not UUF.MLOptimizer then
        self:RecordCheck("MLOptimizerLoaded", false, "MLOptimizer.lua not loaded")
        ok = false
    else
        -- Validate neural network initialized
        local mlOk, mlMsg = UUF.MLOptimizer:Validate()
        self:RecordCheck("MLOptimizerLoaded", mlOk, mlMsg)
        if not mlOk then
            ok = false
        end
    end
    
    return ok
end

-- Validate frames are spawning correctly
function Validator:CheckFrameSpawning()
    -- Check mandatory frame (PLAYER always exists)
    if not UUF.PLAYER then
        self:RecordCheck("FramesSpawning", false, "PLAYER frame missing")
        return false
    end
    
    -- Check conditional frames are registered in config and UUF.Units (but don't require visibility)
    local conditionalFrames = {"TARGET", "TARGETTARGET", "FOCUS", "FOCUSTARGET", "PET"}
    local notRegistered = {}
    
    for _, frameName in ipairs(conditionalFrames) do
        local unitToken = frameName:lower()
        -- Check if enabled in config and registered in UUF.Units
        local unitDB = UUF.db and UUF.db.profile and UUF.db.profile.Units and UUF.db.profile.Units[unitToken]
        if unitDB and unitDB.Enabled then
            -- Frame is enabled, check if it was registered during spawn
            -- Frame may not be visible if unit doesn't exist, but UUF[frameName] should exist
            if not UUF[frameName] then
                table.insert(notRegistered, frameName)
            end
        end
    end
    
    if #notRegistered > 0 then
        local details = "Enabled but not spawned: " .. table.concat(notRegistered, ", ")
        self:RecordCheck("FramesSpawning", false, details)
        return false
    end
    
    self:RecordCheck("FramesSpawning", true, "PLAYER frame present, conditional frames registered")
    return true
end

-- Validate EventBus dispatch works
function Validator:CheckEventBusDispatch()
    if not UUF._eventBus then
        self:RecordCheck("EventBusDispatchWorks", false, "EventBus not initialized")
        return false
    end
    
    local testFlag = false
    UUF._eventBus:Register("TEST_EVENT", "UUF_Validator_Test", function()
        testFlag = true
    end)
    
    UUF._eventBus:Dispatch("TEST_EVENT")
    
    if testFlag then
        self:RecordCheck("EventBusDispatchWorks", true)
        UUF._eventBus:Unregister("TEST_EVENT", "UUF_Validator_Test")
        return true
    else
        self:RecordCheck("EventBusDispatchWorks", false, "Dispatch call did not trigger handler")
        return false
    end
end

-- Validate frame pooling works
function Validator:CheckFramePooling()
    if not UUF.FramePoolManager then
        self:RecordCheck("FramePoolAcquisition", false, "FramePoolManager not loaded")
        return false
    end
    
    -- Create test pool
    local testPool = UUF.FramePoolManager:GetOrCreatePool("TEST_POOL", "Frame", UIParent, nil, 5)
    
    if not testPool then
        self:RecordCheck("FramePoolAcquisition", false, "Could not create test pool")
        return false
    end
    
    -- Test acquire/release
    local frame = UUF.FramePoolManager:Acquire("TEST_POOL")
    local ok = frame ~= nil
    
    if ok then
        UUF.FramePoolManager:Release("TEST_POOL", frame)
        self:RecordCheck("FramePoolAcquisition", true)
    else
        self:RecordCheck("FramePoolAcquisition", false, "Could not acquire frame from pool")
    end
    
    -- Cleanup
    UUF.FramePoolManager:ClearPool("TEST_POOL")
    
    return ok
end

-- Validate config resolution works
function Validator:CheckConfigResolution()
    if not UUF.ConfigResolver then
        self:RecordCheck("ConfigResolution", false, "ConfigResolver not loaded")
        return false
    end
    
    -- Test that we can resolve a known config path
    -- (The HealthBar.Height should exist in defaults)
    local ok = true
    local errorMsg = nil
    
    if not pcall(function()
        UUF.ConfigResolver:Resolve("HealthBar.Height", "player", 25)
    end) then
        ok = false
        errorMsg = "Resolve() threw error"
    end
    
    if ok then
        self:RecordCheck("ConfigResolution", true)
    else
        self:RecordCheck("ConfigResolution", false, errorMsg)
    end
    
    return ok
end

-- Validate GUI builder works
function Validator:CheckGuiBuilder()
    if not UUF.GUILayout then
        self:RecordCheck("GuiBuilderWorks", false, "GUILayout not loaded")
        return false
    end
    
    local ok = true
    local errorMsg = nil
    
    -- Test StackBuilder creation
    if not pcall(function()
        local mockContainer = {AddChild = function() end}
        local builder = UUF.GUILayout:CreateStackBuilder(mockContainer)
        if not builder or not builder.Add then
            ok = false
            errorMsg = "Invalid builder structure"
        end
    end) then
        ok = false
        errorMsg = "CreateStackBuilder threw error"
    end
    
    if ok then
        self:RecordCheck("GuiBuilderWorks", true)
    else
        self:RecordCheck("GuiBuilderWorks", false, errorMsg)
    end
    
    return ok
end

-- Run all validation checks
function Validator:RunFullValidation()
    if UUF.DebugOutput then
        UUF.DebugOutput:Output("Validator", "=== UnhaltedUnitFrames Architecture Validation ===", UUF.DebugOutput.TIER_INFO)
    end
    
    self:CheckCoreSystemsLoaded()
    self:CheckFrameSpawning()
    self:CheckEventBusDispatch()
    self:CheckFramePooling()
    self:CheckConfigResolution()
    self:CheckGuiBuilder()
    
    self:PrintSummary()
end

-- Print validation summary
function Validator:PrintSummary()
    local passed = 0
    local failed = 0
    
    for checkName, result in pairs(self._results) do
        if result.passed then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end
    
    if UUF.DebugOutput then
        UUF.DebugOutput:Output("Validator", "\n=== Validation Summary ===", UUF.DebugOutput.TIER_INFO)
        UUF.DebugOutput:Output("Validator", "Passed: " .. passed, UUF.DebugOutput.TIER_INFO)
        UUF.DebugOutput:Output("Validator", "Failed: " .. failed, UUF.DebugOutput.TIER_INFO)
        UUF.DebugOutput:Output("Validator", "Total:  " .. (passed + failed), UUF.DebugOutput.TIER_INFO)
        
        if failed == 0 then
            UUF.DebugOutput:Output("Validator", "✓ All systems operational!", UUF.DebugOutput.TIER_INFO)
        else
            UUF.DebugOutput:Output("Validator", "✗ Some systems failed validation. Check logs above.", UUF.DebugOutput.TIER_CRITICAL)
        end
    end
end

-- Get validation report as table
function Validator:GetReport()
    local report = {
        timestamp = GetTime(),
        passed = 0,
        failed = 0,
        results = {},
    }
    
    for checkName, result in pairs(self._results) do
        if result.passed then
            report.passed = report.passed + 1
        else
            report.failed = report.failed + 1
        end
        report.results[checkName] = result
    end
    
    return report
end

-- Performance monitoring
Validator._perfMetrics = {}

function Validator:StartPerfMeasure(label)
    self._perfMetrics[label] = {
        startTime = GetTime(),
        startMemory = collectgarbage("count"),
    }
end

function Validator:EndPerfMeasure(label)
    if not self._perfMetrics[label] then
        if UUF.DebugOutput then
            UUF.DebugOutput:Output("Validator", "Perf measure '" .. label .. "' not started", UUF.DebugOutput.TIER_DEBUG)
        end
        return nil
    end
    
    local metric = self._perfMetrics[label]
    metric.endTime = GetTime()
    metric.endMemory = collectgarbage("count")
    metric.elapsed = metric.endTime - metric.startTime
    metric.memoryDelta = metric.endMemory - metric.startMemory
    
    return metric
end

function Validator:PrintPerfMetrics()
    if UUF.DebugOutput then
        UUF.DebugOutput:Output("Validator", "=== Performance Metrics ===", UUF.DebugOutput.TIER_INFO)
        for label, metric in pairs(self._perfMetrics) do
            if metric.elapsed then
                UUF.DebugOutput:Output("Validator", string.format("%s: %.3fms (Memory Δ: %.1fKB)", label, metric.elapsed * 1000, metric.memoryDelta), UUF.DebugOutput.TIER_INFO)
            end
        end
    end
end

-- Helper for integration tests
function Validator:IntegrationTest_EventBusToElements()
    -- Test that EventBus events propagate to elements
    -- This validates the full pipeline
    
    if not UUF._eventBus or not UUF.PLAYER then
        return false
    end
    
    local testPassed = false
    local originalUpdate = UUF.UpdateUnitFrame
    
    -- Hook frame update
    UUF.UpdateUnitFrame = function(frame, unit)
        testPassed = true
        UUF.UpdateUnitFrame = originalUpdate
    end
    
    -- Dispatch test event
    UUF._eventBus:Dispatch("PLAYER_SPECIALIZATION_CHANGED", "player")
    
    -- Check if update was called
    UUF.UpdateUnitFrame = originalUpdate
    
    return testPassed
end

return Validator
