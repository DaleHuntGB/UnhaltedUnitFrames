local _, UUF = ...
local Arch = UUF.Architecture

-- Frame Pool Manager: Manages reusable frame pools for high-frequency elements
-- Reduces GC pressure by reusing frames instead of creating/destroying

local FramePoolManager = {}
UUF.FramePoolManager = FramePoolManager

-- Pool registry
FramePoolManager._pools = {}
FramePoolManager._poolStats = {}

-- Create a new pool or get existing one
function FramePoolManager:GetOrCreatePool(poolName, frameType, parent, template, initialSize)
    if self._pools[poolName] then
        return self._pools[poolName]
    end
    
    local pool = Arch.CreateFramePool(frameType, parent, template)
    self._pools[poolName] = pool
    self._poolStats[poolName] = {
        created = 0,
        acquired = 0,
        released = 0,
        maxActive = 0,
        initialSize = initialSize or 0,
        avgFrameSize = 0 -- Approximate memory usage
    }
    
    -- Pre-allocate if requested
    if initialSize and initialSize > 0 then
        for i = 1, initialSize do
            local frame = pool:Acquire()
            pool:Release(frame)
        end
        self._poolStats[poolName].created = initialSize
    end
    
    return pool
end

-- Get pool statistics
function FramePoolManager:GetPoolStats(poolName)
    return self._poolStats[poolName] or {}
end

-- Get all pools statistics
function FramePoolManager:GetAllPoolStats()
    local report = {}
    for poolName, stats in pairs(self._poolStats) do
		local pool = self._pools[poolName]
		if pool then
			-- GetCount returns: total, available (inactive), active
			local total, inactive, active = pool:GetCount()
			report[poolName] = {
				active = active or 0,
				inactive = inactive or 0,
				total = total or 0,
				acquired = stats.acquired or 0,
				released = stats.released or 0,
				maxActive = stats.maxActive or 0,
			}
		else
			report[poolName] = {
				active = 0,
				inactive = 0,
				total = 0,
				acquired = stats.acquired or 0,
				released = stats.released or 0,
				maxActive = stats.maxActive or 0,
			}
		end
	end
	return report
end

-- Acquire frame from pool with tracking
function FramePoolManager:Acquire(poolName)
    if not self._pools[poolName] then
        print("FramePoolManager: Pool '" .. poolName .. "' not found")
        return nil
    end
    
    local frame = self._pools[poolName]:Acquire()
    if frame then
        local stats = self._poolStats[poolName]
        stats.acquired = (stats.acquired or 0) + 1
        local active = (stats.acquired or 0) - (stats.released or 0)
        stats.maxActive = math.max(stats.maxActive or 0, active)
    end
    return frame
end

-- Release frame back to pool with tracking
function FramePoolManager:Release(poolName, frame)
    if not self._pools[poolName] then
        print("FramePoolManager: Pool '" .. poolName .. "' not found")
        return false
    end
    
    self._pools[poolName]:Release(frame)
    local stats = self._poolStats[poolName]
    stats.released = (stats.released or 0) + 1
    return true
end

-- Release all frames in a pool
function FramePoolManager:ReleaseAll(poolName)
    if not self._pools[poolName] then
        print("FramePoolManager: Pool '" .. poolName .. "' not found")
        return false
    end
    
    self._pools[poolName]:ReleaseAll()
    local stats = self._poolStats[poolName]
    stats.released = stats.acquired
    return true
end

-- Clear and destroy a pool
function FramePoolManager:ClearPool(poolName)
    if self._pools[poolName] then
        self._pools[poolName]:ReleaseAll()
        self._pools[poolName] = nil
        self._poolStats[poolName] = nil
    end
end

-- Clear all pools
function FramePoolManager:ClearAllPools()
    for poolName in pairs(self._pools) do
        self:ClearPool(poolName)
    end
end

-- Compact pools (cleanup unused frames)
function FramePoolManager:CompactPools()
    local cleanedCount = 0
    for poolName, pool in pairs(self._pools) do
        if pool.compact then
            pool:compact()
            cleanedCount = cleanedCount + 1
        end
    end
    return cleanedCount
end

-- Performance helper: Get suggested pool size
function FramePoolManager:CalcSuggestedPoolSize(element, maxItems)
    -- Calculate based on number of items typically shown
    -- Conservative estimate: 1.5x max items to account for reuse
    return math.ceil((maxItems or 20) * 1.5)
end

-- Monitoring: Print pool statistics
function FramePoolManager:PrintStats()
    print("|cFF8080FFFramePool Statistics:|r")
    for poolName, stats in pairs(self._poolStats) do
        local pool = self._pools[poolName]
        local active = pool and pool:GetCount() or 0
        print(string.format("  %s: Active=%d, Total Acquired=%d, Max Active=%d", poolName, active, stats.acquired or 0, stats.maxActive or 0))
    end
end

-- Logging for debugging
function FramePoolManager:DebugPool(poolName)
    if not self._pools[poolName] then
        print("Pool '" .. poolName .. "' not found")
        return
    end
    
    local stats = self._poolStats[poolName]
    print("|cFF8080FFPool Debug: " .. poolName .. "|r")
    print("  Acquired: " .. (stats.acquired or 0))
    print("  Released: " .. (stats.released or 0))
    print("  Max Active: " .. (stats.maxActive or 0))
    print("  Initial Size: " .. (stats.initialSize or 0))
    
    if self._pools[poolName].GetCount then
        print("  Currently Active: " .. self._pools[poolName]:GetCount())
    end
end

--- Get pool diagnostic information
function FramePoolManager:GetDiagnostics()
	local report = {
		poolCount = 0,
		totalFrames = 0,
		totalActive = 0,
		pools = {}
	}
	
	for poolName, stat in pairs(self:GetAllPoolStats()) do
		report.poolCount = report.poolCount + 1
		report.totalFrames = report.totalFrames + stat.total
		report.totalActive = report.totalActive + stat.active
		table.insert(report.pools, {
			name = poolName,
			active = stat.active,
			inactive = stat.inactive,
			total = stat.total,
		})
	end
	
	return report
end

--- Test pool functionality
function FramePoolManager:TestPool()
	local testPool = self:GetOrCreatePool("TEST_POOL_DIAG", "Frame", UIParent, nil, 3)
	if not testPool then
		return false, "Failed to create test pool"
	end
	
	-- Acquire a frame
	local frame = self:Acquire("TEST_POOL_DIAG")
	if not frame then
		return false, "Failed to acquire frame from test pool"
	end
	
	-- Release it
	self:Release("TEST_POOL_DIAG", frame)
	
	-- Cleanup
	self._pools["TEST_POOL_DIAG"] = nil
	self._poolStats["TEST_POOL_DIAG"] = nil
	
	return true, "Test pool working correctly"
end

--- Initialize frame pool manager
function FramePoolManager:Init()
	if UUF.DebugOutput then
		UUF.DebugOutput:Output("FramePoolManager", "Initialized", UUF.DebugOutput.TIER_INFO)
	else
		print("|cFF00B0F7FramePoolManager: Initialized|r")
	end
end
return FramePoolManager
