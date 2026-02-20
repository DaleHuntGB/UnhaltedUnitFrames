-- ═══════════════════════════════════════════════════════════════════════════════
-- Core/FrameTimeBudget.lua
-- Frame Time Budgeting System - Prevents frame spikes by spreading updates
-- ═══════════════════════════════════════════════════════════════════════════════

local AddonName, UUF = ...

-- PERF LOCALS
local GetTime, debugprofilestop = GetTime, debugprofilestop
local C_Timer, math_max, math_min = C_Timer, math.max, math.min
local tinsert, tremove, sort = table.insert, table.remove, table.sort

-- ═══════════════════════════════════════════════════════════════════════════════
-- FRAME TIME BUDGET SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local FrameTimeBudget = {
    -- Configuration
    TARGET_FPS = 60,                    -- Target 60 FPS
    TARGET_FRAME_TIME = 16.67,          -- ~16.67ms per frame at 60 FPS
    CRITICAL_THRESHOLD = 14.0,          -- Reserve 2.67ms for critical updates
    WARNING_THRESHOLD = 12.0,           -- Start throttling at 12ms
    SAMPLES_COUNT = 120,                -- Track 120 frames (~2 seconds at 60 FPS)
    MAX_DEFERRED_QUEUE = 200,           -- Max deferred callbacks to prevent unbounded growth
    
    -- Priority levels
    PRIORITY_CRITICAL = 1,              -- Health/Power bars (always run)
    PRIORITY_HIGH = 2,                  -- Aura updates, cast bars
    PRIORITY_MEDIUM = 3,                -- Tags, name updates
    PRIORITY_LOW = 4,                   -- Cosmetic updates, indicators
    
    -- State
    frameStartTime = 0,                 -- Start time of current frame (ms)
    frameHistory = {},                  -- Rolling history of frame times
    currentIndex = 1,                   -- Current position in history buffer
    averageFrameTime = 0,               -- Rolling average frame time (incremental)
    runningTotal = 0,                   -- Running sum for incremental average
    deferredQueue = {},                 -- Queue for deferred updates
    
    -- Percentile tracking
    sortedFrameTimes = {},              -- Sorted frame times for percentiles
    percentilesDirty = false,           -- Flag to recalculate percentiles
    
    -- Statistics
    stats = {
        totalFrames = 0,
        budgetExceeded = 0,
        deferredUpdates = 0,
        processedDeferred = 0,
        droppedDeferred = 0,            -- Callbacks dropped due to queue overflow
        avgFrameTime = 0,
        maxFrameTime = 0,
        p50FrameTime = 0,               -- Median
        p95FrameTime = 0,               -- 95th percentile
        p99FrameTime = 0,               -- 99th percentile
        histogram = {},                 -- Frame time histogram buckets
    },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

function FrameTimeBudget:Initialize()
    -- Initialize frame history buffer
    for i = 1, self.SAMPLES_COUNT do
        self.frameHistory[i] = self.TARGET_FRAME_TIME
    end
    
    -- Initialize running total for incremental averaging
    self.runningTotal = self.TARGET_FRAME_TIME * self.SAMPLES_COUNT
    self.averageFrameTime = self.TARGET_FRAME_TIME
    
    -- Initialize sorted frame times for percentiles
    for i = 1, self.SAMPLES_COUNT do
        self.sortedFrameTimes[i] = self.TARGET_FRAME_TIME
    end
    
    -- Initialize histogram buckets (0-5ms, 5-10ms, 10-15ms, 15-20ms, 20-30ms, 30+ms)
    self.stats.histogram = {0, 0, 0, 0, 0, 0}
    
    -- Create frame time tracker
    self.tracker = CreateFrame("Frame")
    self.tracker:SetScript("OnUpdate", function()
        self:OnFrameUpdate()
    end)
    
    -- Start first frame measurement
    self.frameStartTime = debugprofilestop()
    
    if UUF.DebugOutput then
        UUF.DebugOutput:Output("FrameTimeBudget", string.format("Frame time budgeting system initialized (Target: %.2fms)", self.TARGET_FRAME_TIME), UUF.DebugOutput.TIER_INFO)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FRAME TIME TRACKING
-- ═══════════════════════════════════════════════════════════════════════════════

function FrameTimeBudget:OnFrameUpdate()
    local currentTime = debugprofilestop()
    local frameTime = currentTime - self.frameStartTime
    
    -- Get old value being replaced
    local oldValue = self.frameHistory[self.currentIndex]
    
    -- Record frame time in history
    self.frameHistory[self.currentIndex] = frameTime
    self.currentIndex = (self.currentIndex % self.SAMPLES_COUNT) + 1
    
    -- Update running total and average incrementally (O(1) instead of O(n))
    self.runningTotal = self.runningTotal - oldValue + frameTime
    self.averageFrameTime = self.runningTotal / self.SAMPLES_COUNT
    
    -- Update sorted frame times for percentile calculation
    self.sortedFrameTimes[self.currentIndex] = frameTime
    self.percentilesDirty = true
    
    -- Update statistics
    self.stats.totalFrames = self.stats.totalFrames + 1
    self.stats.avgFrameTime = self.averageFrameTime
    self.stats.maxFrameTime = math_max(self.stats.maxFrameTime, frameTime)
    
    if frameTime > self.TARGET_FRAME_TIME then
        self.stats.budgetExceeded = self.stats.budgetExceeded + 1
    end
    
    -- Update histogram
    local bucket
    if frameTime < 5 then
        bucket = 1
    elseif frameTime < 10 then
        bucket = 2
    elseif frameTime < 15 then
        bucket = 3
    elseif frameTime < 20 then
        bucket = 4
    elseif frameTime < 30 then
        bucket = 5
    else
        bucket = 6
    end
    self.stats.histogram[bucket] = self.stats.histogram[bucket] + 1
    
    -- Process deferred queue if we have budget
    self:ProcessDeferredQueue()
    
    -- Start measurement for next frame
    self.frameStartTime = debugprofilestop()
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- BUDGET CHECKING
-- ═══════════════════════════════════════════════════════════════════════════════

-- Check if we can afford to run an update based on priority
function FrameTimeBudget:CanAfford(priority, estimatedCost)
    local elapsed = debugprofilestop() - self.frameStartTime
    estimatedCost = estimatedCost or 0.5  -- Default 0.5ms estimate
    
    -- Critical updates always run
    if priority == self.PRIORITY_CRITICAL then
        return true
    end
    
    -- If we're under warning threshold, allow all updates
    if elapsed < self.WARNING_THRESHOLD then
        return true
    end
    
    -- If we're over critical threshold, only allow critical
    if elapsed > self.CRITICAL_THRESHOLD then
        return false
    end
    
    -- Check if we have room for this update
    local remaining = self.TARGET_FRAME_TIME - elapsed
    return remaining >= (estimatedCost + 1.0)  -- Leave 1ms safety margin
end

-- Get current frame time budget status
function FrameTimeBudget:GetBudgetStatus()
    local elapsed = debugprofilestop() - self.frameStartTime
    local remaining = math_max(0, self.TARGET_FRAME_TIME - elapsed)
    local utilization = (elapsed / self.TARGET_FRAME_TIME) * 100
    
    return {
        elapsed = elapsed,
        remaining = remaining,
        utilization = utilization,
        isOverBudget = elapsed > self.TARGET_FRAME_TIME,
        isNearLimit = elapsed > self.WARNING_THRESHOLD,
    }
end

-- Reserve time for an operation (returns success boolean)
function FrameTimeBudget:ReserveTime(priority, estimatedCost)
    if not self:CanAfford(priority, estimatedCost) then
        return false
    end
    -- Time is implicitly reserved by running the operation
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DEFERRED QUEUE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════════

-- Defer an update to a later frame
function FrameTimeBudget:DeferUpdate(callback, priority, context)
    priority = priority or self.PRIORITY_MEDIUM

    if context ~= nil then
        for i = 1, #self.deferredQueue do
            local item = self.deferredQueue[i]
            if item.context == context then
                item.callback = callback
                item.priority = math_min(item.priority, priority)
                item.queuedAt = GetTime()

                -- Keep queue ordering consistent after priority update
                sort(self.deferredQueue, function(a, b)
                    if a.priority ~= b.priority then
                        return a.priority < b.priority
                    end
                    return a.queuedAt < b.queuedAt
                end)
                return
            end
        end
    end
    
    -- Check queue overflow
    if #self.deferredQueue >= self.MAX_DEFERRED_QUEUE then
        self.stats.droppedDeferred = self.stats.droppedDeferred + 1
        
        -- Emergency: drop lowest priority items
        local removed = false
        for i = #self.deferredQueue, 1, -1 do
            if self.deferredQueue[i].priority == self.PRIORITY_LOW then
                tremove(self.deferredQueue, i)
                removed = true
                break
            end
        end
        
        -- If still full and this is low priority, drop it
        if not removed and priority == self.PRIORITY_LOW then
            if UUF.DebugOutput then
                UUF.DebugOutput:Output("FrameTimeBudget", "Dropped low-priority deferred update (queue full)", UUF.DebugOutput.TIER_DEBUG)
            end
            return
        end
    end
    
    -- Validate callback is still valid
    if type(callback) ~= "function" then
        return
    end
    
    tinsert(self.deferredQueue, {
        callback = callback,
        priority = priority,
        context = context,
        queuedAt = GetTime(),
    })
    
    self.stats.deferredUpdates = self.stats.deferredUpdates + 1
    
    -- Sort queue by priority (lower number = higher priority)
    sort(self.deferredQueue, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return a.queuedAt < b.queuedAt
    end)
end

-- Process deferred updates when we have budget
function FrameTimeBudget:ProcessDeferredQueue()
    if #self.deferredQueue == 0 then
        return
    end
    
    local processed = 0
    local startTime = debugprofilestop()
    
    while #self.deferredQueue > 0 do
        local item = self.deferredQueue[1]
        
        -- Check if we have budget for this priority
        if not self:CanAfford(item.priority, 1.0) then
            break
        end
        
        -- Remove from queue and execute
        tremove(self.deferredQueue, 1)
        
        local success, err = pcall(item.callback, item.context)
        if not success and UUF.DebugOutput then
            UUF.DebugOutput:Error("FrameTimeBudget", "Deferred callback error: %s", tostring(err))
        end
        
        processed = processed + 1
        self.stats.processedDeferred = self.stats.processedDeferred + 1
        
        -- Safety: Don't process deferred for more than 5ms total
        if (debugprofilestop() - startTime) > 5.0 then
            break
        end
    end
    
    return processed
end

-- Clear the deferred queue (used on combat state changes, etc.)
function FrameTimeBudget:FlushDeferredQueue()
    local flushed = 0
    
    while #self.deferredQueue > 0 do
        local item = tremove(self.deferredQueue, 1)
        
        local success, err = pcall(item.callback, item.context)
        if not success and UUF.DebugOutput then
            UUF.DebugOutput:Error("FrameTimeBudget", "Flush callback error: %s", tostring(err))
        end
        
        flushed = flushed + 1
    end
    
    return flushed
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ADAPTIVE THROTTLING
-- ═══════════════════════════════════════════════════════════════════════════════

-- Get recommended batch size based on current frame time
function FrameTimeBudget:GetAdaptiveBatchSize(baseBatchSize)
    baseBatchSize = baseBatchSize or 10
    
    -- If we're consistently under budget, allow larger batches
    if self.averageFrameTime < self.WARNING_THRESHOLD then
        return math_max(baseBatchSize, baseBatchSize * 2)
    end
    
    -- If we're near the limit, reduce batch size
    if self.averageFrameTime > self.CRITICAL_THRESHOLD then
        return math_max(1, baseBatchSize / 4)
    end
    
    -- If we're over budget, significantly reduce batch size
    if self.averageFrameTime > self.TARGET_FRAME_TIME then
        return math_max(1, baseBatchSize / 2)
    end
    
    return baseBatchSize
end

-- Get recommended batch interval based on current frame time
function FrameTimeBudget:GetAdaptiveBatchInterval(baseInterval)
    baseInterval = baseInterval or 0.1
    
    -- If we're under budget, batch more frequently
    if self.averageFrameTime < self.WARNING_THRESHOLD then
        return math_max(0.05, baseInterval / 2)
    end
    
    -- If we're over budget, reduce batch frequency
    if self.averageFrameTime > self.TARGET_FRAME_TIME then
        return baseInterval * 2
    end
    
    return baseInterval
end

-- Check if we should throttle updates based on recent frame times
function FrameTimeBudget:ShouldThrottle()
    return self.averageFrameTime > self.CRITICAL_THRESHOLD
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- STATISTICS AND REPORTING
-- ═══════════════════════════════════════════════════════════════════════════════

-- Calculate percentiles (P50, P95, P99)
function FrameTimeBudget:CalculatePercentiles()
    if not self.percentilesDirty then
        return
    end
    
    -- Copy and sort frame times
    local sorted = {}
    for i = 1, #self.sortedFrameTimes do
        sorted[i] = self.sortedFrameTimes[i]
    end
    sort(sorted)
    
    -- Calculate percentiles
    local count = #sorted
    self.stats.p50FrameTime = sorted[math.floor(count * 0.50)] or 0
    self.stats.p95FrameTime = sorted[math.floor(count * 0.95)] or 0
    self.stats.p99FrameTime = sorted[math.floor(count * 0.99)] or 0
    
    self.percentilesDirty = false
end

function FrameTimeBudget:GetStatistics()
    -- Update percentiles if dirty
    self:CalculatePercentiles()
    
    return {
        totalFrames = self.stats.totalFrames,
        budgetExceeded = self.stats.budgetExceeded,
        budgetExceededPercent = (self.stats.budgetExceeded / math_max(1, self.stats.totalFrames)) * 100,
        deferredUpdates = self.stats.deferredUpdates,
        processedDeferred = self.stats.processedDeferred,
        droppedDeferred = self.stats.droppedDeferred,
        pendingDeferred = #self.deferredQueue,
        avgFrameTime = self.stats.avgFrameTime,
        maxFrameTime = self.stats.maxFrameTime,
        p50FrameTime = self.stats.p50FrameTime,
        p95FrameTime = self.stats.p95FrameTime,
        p99FrameTime = self.stats.p99FrameTime,
        currentFrameTime = debugprofilestop() - self.frameStartTime,
        targetFrameTime = self.TARGET_FRAME_TIME,
        histogram = self.stats.histogram,
    }
end

function FrameTimeBudget:ResetStatistics()
    self.stats.totalFrames = 0
    self.stats.budgetExceeded = 0
    self.stats.deferredUpdates = 0
    self.stats.processedDeferred = 0
    self.stats.avgFrameTime = 0
    self.stats.maxFrameTime = 0
end

function FrameTimeBudget:PrintStatistics()
    local stats = self:GetStatistics()
    
    print("|cFF00FF96[UUF Frame Time Budget]|r")
    print(string.format("  Frames Tracked: %d", stats.totalFrames))
    print(string.format("  Budget Exceeded: %d (%.1f%%)", stats.budgetExceeded, stats.budgetExceededPercent))
    print(string.format("  Avg Frame Time: %.2fms (Target: %.2fms)", stats.avgFrameTime, stats.targetFrameTime))
    print(string.format("  Max Frame Time: %.2fms", stats.maxFrameTime))
    print(string.format("  Percentiles: P50=%.2fms P95=%.2fms P99=%.2fms", stats.p50FrameTime, stats.p95FrameTime, stats.p99FrameTime))
    print(string.format("  Deferred Updates: %d queued, %d processed, %d dropped, %d pending", 
        stats.deferredUpdates, stats.processedDeferred, stats.droppedDeferred, stats.pendingDeferred))
    
    -- Print histogram
    print("|cFF00B0F7Frame Time Distribution:|r")
    print(string.format("  0-5ms:   %d frames", stats.histogram[1]))
    print(string.format("  5-10ms:  %d frames", stats.histogram[2]))
    print(string.format("  10-15ms: %d frames", stats.histogram[3]))
    print(string.format("  15-20ms: %d frames", stats.histogram[4]))
    print(string.format("  20-30ms: %d frames", stats.histogram[5]))
    print(string.format("  30+ms:   %d frames", stats.histogram[6]))
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- INTEGRATION HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Wrap a function with budget checking and deferrment
function FrameTimeBudget:WrapWithBudget(func, priority, estimatedCost)
    return function(...)
        if self:CanAfford(priority, estimatedCost) then
            return func(...)
        else
            -- Defer to next frame
            local args = {...}
            self:DeferUpdate(function()
                func(unpack(args))
            end, priority)
            return nil
        end
    end
end

-- Run a batch of operations with budget awareness
function FrameTimeBudget:BatchProcess(items, processor, priority, maxTime)
    maxTime = maxTime or 5.0
    local startTime = debugprofilestop()
    local processed = 0
    
    for i = 1, #items do
        if not self:CanAfford(priority, 0.5) then
            -- Defer remaining items
            for j = i, #items do
                self:DeferUpdate(function()
                    processor(items[j])
                end, priority)
            end
            break
        end
        
        processor(items[i])
        processed = processed + 1
        
        -- Safety: don't exceed maxTime
        if (debugprofilestop() - startTime) > maxTime then
            -- Defer remaining
            for j = i + 1, #items do
                self:DeferUpdate(function()
                    processor(items[j])
                end, priority)
            end
            break
        end
    end
    
    return processed
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MODULE REGISTRATION
-- ═══════════════════════════════════════════════════════════════════════════════

UUF.FrameTimeBudget = FrameTimeBudget

-- Initialize on addon load
if UUF.Core then
    C_Timer.After(0, function()
        FrameTimeBudget:Initialize()
    end)
end
