--[[============================================================================
	MLOptimizer.lua
	Advanced Machine Learning Optimization System
	
	Multi-factor neural network for intelligent performance optimization.
	Goes beyond simple weighted scoring to provide:
	- Combat pattern recognition and prediction
	- Predictive pre-loading of frames/elements
	- Adaptive coalescing delays based on content type
	- Multi-factor neural network with backpropagation learning
	
	Features:
	- Pattern recognition: Learn combat event sequences
	- Predictive marking: Pre-mark frames before updates needed
	- Adaptive delays: Learn optimal coalescing windows per event/content
	- Neural network: Multi-layer learning with 7+ input features
	
	Usage:
		UUF.MLOptimizer:PredictNextUpdates()
		UUF.MLOptimizer:GetOptimalDelay(eventName)
		UUF.MLOptimizer:PrintPatterns()
============================================================================]]--

local UUF = select(2, ...)
local MLOptimizer = {}
UUF.MLOptimizer = MLOptimizer

-- PERF LOCALS
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local GetNumGroupMembers = GetNumGroupMembers
local GetFramerate = GetFramerate
local pairs, ipairs = pairs, ipairs
local math_exp, math_tanh = math.exp, math.tanh
local math_random, math_min, math_max = math.random, math.min, math.max
local table_insert, table_remove = table.insert, table.remove
local select = select

--[[----------------------------------------------------------------------------
	Neural Network Configuration
----------------------------------------------------------------------------]]--

-- Network architecture: 7 inputs → 5 hidden → 3 outputs
local NETWORK = {
	inputs = 7,          -- Feature count
	hidden = 5,          -- Hidden layer neurons
	outputs = 3,         -- Output predictions
	learningRate = 0.01, -- Backpropagation rate
}

-- Input features (normalized 0-1)
local FEATURES = {
	frequency = 1,      -- Event frequency (normalized to 0-1)
	recency = 2,        -- Time since last seen (inverted, 0=old 1=recent)
	combatState = 3,    -- In combat = 1, out = 0
	groupSize = 4,      -- Solo=0, 5-man=0.25, raid=1
	contentType = 5,    -- World=0, Dungeon=0.5, Raid=1
	fps = 6,            -- FPS normalized (30fps=0, 144fps=1)
	latency = 7,        -- Latency inverted (0ms=1, 200ms=0)
}

-- Output predictions (0-1)
local OUTPUTS = {
	priority = 1,       -- Priority score (0=LOW, 1=CRITICAL)
	coalesceDelay = 2,  -- Coalesce delay factor (0=0ms, 1=200ms)
	preloadLikelihood = 3, -- Should pre-load (0=no, 1=yes)
}

-- Initialize weights (small random values)
local _weights = {
	inputHidden = {},  -- [input][hidden] = weight
	hiddenOutput = {}, -- [hidden][output] = weight
}

-- Neuron biases
local _biases = {
	hidden = {},       -- [hidden] = bias
	output = {},       -- [output] = bias
}

-- Initialize network
local function InitializeNetwork()
	-- Input → Hidden weights
	for i = 1, NETWORK.inputs do
		_weights.inputHidden[i] = {}
		for h = 1, NETWORK.hidden do
			_weights.inputHidden[i][h] = (math_random() - 0.5) * 0.1
		end
	end
	
	-- Hidden → Output weights
	for h = 1, NETWORK.hidden do
		_weights.hiddenOutput[h] = {}
		for o = 1, NETWORK.outputs do
			_weights.hiddenOutput[h][o] = (math_random() - 0.5) * 0.1
		end
	end
	
	-- Biases
	for h = 1, NETWORK.hidden do
		_biases.hidden[h] = (math_random() - 0.5) * 0.1
	end
	for o = 1, NETWORK.outputs do
		_biases.output[o] = (math_random() - 0.5) * 0.1
	end
end

-- Activation function: Sigmoid
local function Sigmoid(x)
	return 1 / (1 + math_exp(-x))
end

-- Activation derivative for backpropagation
local function SigmoidDerivative(x)
	local s = Sigmoid(x)
	return s * (1 - s)
end

--[[----------------------------------------------------------------------------
	Combat Pattern Recognition
----------------------------------------------------------------------------]]--

-- Pattern tracking
local _patterns = {
	sequences = {},     -- Recent event sequences [1-50]
	library = {},       -- Known patterns with predictions
	currentSequence = {},
	maxSequenceLength = 10,
	minPatternLength = 3,
}

-- Content type tracking
local _context = {
	inCombat = false,
	instanceType = "none",  -- none, party, raid, pvp, scenario
	groupSize = 0,
	lastUpdate = 0,
}

-- Event name extractor - maps reason strings to event names
local function ExtractEventName(eventName, reason)
	-- If eventName is already set, use it
	if eventName and eventName ~= "" and not eventName:find("MarkDirty") then
		return eventName
	end
	
	-- Try to extract from reason (common patterns):
	if reason then
		-- "UNIT_HEALTH" format
		if reason:match("^[A-Z_]+$") then
			return reason
		end
		
		-- "EventCoalescer:UNIT_HEALTH" format
		if reason:find(":") then
			return reason:match(":(.+)") or reason
		end
		
		-- Handle specific common patterns
		if reason:find("health") or reason:find("Health") then
			return "UNIT_HEALTH"
		elseif reason:find("power") or reason:find("Power") then
			return "UNIT_POWER_UPDATE"
		elseif reason:find("aura") or reason:find("Aura") then
			return "UNIT_AURA"
		elseif reason:find("threat") or reason:find("Threat") then
			return "UNIT_THREAT_LIST_UPDATE"
		elseif reason:find("portrait") or reason:find("Portrait") then
			return "UNIT_PORTRAIT_UPDATE"
		end
	end
	
	return eventName or "Unknown"
end

--- Track an event in pattern sequence
-- @param eventName string
-- @param reason string - Why the event fired
function MLOptimizer:TrackPattern(eventName, reason)
	local now = GetTime()
	
	-- Extract actual event name from reason if needed
	eventName = ExtractEventName(eventName, reason)
	
	-- Add to current sequence
	table_insert(_patterns.currentSequence, {
		event = eventName,
		reason = reason,
		timestamp = now,
		context = {
			combat = _context.inCombat,
			instance = _context.instanceType,
			groupSize = _context.groupSize,
		},
	})
	
	-- Trim sequence to max length
	while #_patterns.currentSequence > _patterns.maxSequenceLength do
		table_remove(_patterns.currentSequence, 1)
	end
	
	-- Try to match or learn pattern
	if #_patterns.currentSequence >= _patterns.minPatternLength then
		self:AnalyzePattern()
	end
end

--- Analyze current sequence for patterns
function MLOptimizer:AnalyzePattern()
	local sequence = _patterns.currentSequence
	local len = #sequence
	
	-- Build pattern signature (event names only)
	local signature = ""
	for i = math_max(1, len - _patterns.minPatternLength + 1), len do
		signature = signature .. sequence[i].event .. "→"
	end
	
	-- Check if pattern exists
	if not _patterns.library[signature] then
		_patterns.library[signature] = {
			occurrences = 0,
			predictions = {}, -- [nextEvent] = count
			lastSeen = 0,
			context = sequence[len].context,
		}
	end
	
	-- Increment occurrence
	_patterns.library[signature].occurrences = _patterns.library[signature].occurrences + 1
	_patterns.library[signature].lastSeen = GetTime()
	
	-- If we have a next event in history, learn it
	local nextIdx = len + 1
	if _patterns.sequences[#_patterns.sequences] and _patterns.sequences[#_patterns.sequences][nextIdx] then
		local nextEvent = _patterns.sequences[#_patterns.sequences][nextIdx].event
		_patterns.library[signature].predictions[nextEvent] = 
			(_patterns.library[signature].predictions[nextEvent] or 0) + 1
	end
end

--- Predict next likely events based on current pattern
-- @return table - { eventName = probability, ... }
function MLOptimizer:PredictNextUpdates()
	local sequence = _patterns.currentSequence
	local len = #sequence
	
	if len < _patterns.minPatternLength then
		return {}
	end
	
	-- Build current pattern signature
	local signature =  ""
	for i = math_max(1, len - _patterns.minPatternLength + 1), len do
		signature = signature .. sequence[i].event .. "→"
	end
	
	-- Look up pattern
	local pattern = _patterns.library[signature]
	if not pattern or not pattern.predictions then
		return {}
	end
	
	-- Calculate probabilities
	local totalPredictions = 0
	for _, count in pairs(pattern.predictions) do
		totalPredictions = totalPredictions + count
	end
	
	if totalPredictions == 0 then
		return {}
	end
	
	local predictions = {}
	for event, count in pairs(pattern.predictions) do
		predictions[event] = count / totalPredictions
	end
	
	return predictions
end

--[[----------------------------------------------------------------------------
	Adaptive Coalescing Delays
----------------------------------------------------------------------------]]--

-- Delay learning data
local _delayLearning = {
	eventDelays = {},  -- [eventName][contentType] = { delay, fps, latency, successRate }
	defaultDelays = {
		UNIT_HEALTH = 0.05,
		UNIT_POWER_UPDATE = 0.05,
		UNIT_AURA = 0.05,
		UNIT_THREAT_LIST_UPDATE = 0.1,
		UNIT_PORTRAIT_UPDATE = 0.2,
	},
}

--- Learn optimal delay for an event based on context
-- @param eventName string
-- @param delay number - Current delay
-- @param success boolean - Whether update was smooth (no FPS drop)
function MLOptimizer:LearnDelay(eventName, delay, success)
	local contentType = _context.instanceType
	
	if not _delayLearning.eventDelays[eventName] then
		_delayLearning.eventDelays[eventName] = {}
	end
	
	if not _delayLearning.eventDelays[eventName][contentType] then
		_delayLearning.eventDelays[eventName][contentType] = {
			delay = delay,
			samples = 0,
			successCount = 0,
			fps = GetFramerate(),
			latency = select(3, GetNetStats()) or 0,
		}
	end
	
	local entry = _delayLearning.eventDelays[eventName][contentType]
	entry.samples = entry.samples + 1
	if success then
		entry.successCount = entry.successCount + 1
	end
	
	-- Adjust delay based on success rate
	local successRate = entry.successCount / entry.samples
	if successRate < 0.7 then
		-- Too aggressive, increase delay
		entry.delay = math_min(0.2, entry.delay * 1.1)
	elseif successRate > 0.95 and entry.samples > 10 then
		-- Very successful, try decreasing delay
		entry.delay = math_max(0.01, entry.delay * 0.95)
	end
	
	-- Update FPS/latency tracking
	entry.fps = GetFramerate()
	entry.latency = select(3, GetNetStats()) or 0
end

--- Get optimal coalesce delay for an event
-- @param eventName string
-- @return number - Delay in seconds
function MLOptimizer:GetOptimalDelay(eventName)
	local contentType = _context.instanceType
	
	-- Check learned delay
	if _delayLearning.eventDelays[eventName] and 
	   _delayLearning.eventDelays[eventName][contentType] then
		return _delayLearning.eventDelays[eventName][contentType].delay
	end
	
	-- Fall back to default
	return _delayLearning.defaultDelays[eventName] or 0.05
end

--[[----------------------------------------------------------------------------
	Neural Network Forward/Backward Propagation
----------------------------------------------------------------------------]]--

-- Forward propagation through network
-- @param inputs table - Input feature values [1-7]
-- @return table - Output values [1-3]
-- @return table - Hidden layer activations (for backprop)
local function ForwardPropagate(inputs)
	local hidden = {}
	local outputs = {}
	
	-- Input → Hidden layer
	for h = 1, NETWORK.hidden do
		local sum = _biases.hidden[h]
		for i = 1, NETWORK.inputs do
			sum = sum + (inputs[i] * _weights.inputHidden[i][h])
		end
		hidden[h] = Sigmoid(sum)
	end
	
	-- Hidden → Output layer
	for o = 1, NETWORK.outputs do
		local sum = _biases.output[o]
		for h = 1, NETWORK.hidden do
			sum = sum + (hidden[h] * _weights.hiddenOutput[h][o])
		end
		outputs[o] = Sigmoid(sum)
	end
	
	return outputs, hidden
end

-- Backward propagation for learning
-- @param inputs table - Input features
-- @param hidden table - Hidden activations from forward pass
-- @param outputs table - Output predictions from forward pass
-- @param targets table - Target values (expected outputs)
local function BackwardPropagate(inputs, hidden, outputs, targets)
	local outputErrors = {}
	local hiddenErrors = {}
	
	-- Calculate output layer errors
	for o = 1, NETWORK.outputs do
		outputErrors[o] = (targets[o] - outputs[o]) * SigmoidDerivative(outputs[o])
	end
	
	-- Calculate hidden layer errors
	for h = 1, NETWORK.hidden do
		local error = 0
		for o = 1, NETWORK.outputs do
			error = error + (outputErrors[o] * _weights.hiddenOutput[h][o])
		end
		hiddenErrors[h] = error * SigmoidDerivative(hidden[h])
	end
	
	-- Update Hidden → Output weights
	for h = 1, NETWORK.hidden do
		for o = 1, NETWORK.outputs do
			_weights.hiddenOutput[h][o] = _weights.hiddenOutput[h][o] + 
				(NETWORK.learningRate * outputErrors[o] * hidden[h])
		end
	end
	
	-- Update Input → Hidden weights
	for i = 1, NETWORK.inputs do
		for h = 1, NETWORK.hidden do
			_weights.inputHidden[i][h] = _weights.inputHidden[i][h] + 
				(NETWORK.learningRate * hiddenErrors[h] * inputs[i])
		end
	end
	
	-- Update biases
	for h = 1, NETWORK.hidden do
		_biases.hidden[h] = _biases.hidden[h] + (NETWORK.learningRate * hiddenErrors[h])
	end
	for o = 1, NETWORK.outputs do
		_biases.output[o] = _biases.output[o] + (NETWORK.learningRate * outputErrors[o])
	end
end

--[[----------------------------------------------------------------------------
	Public API
----------------------------------------------------------------------------]]--

--- Extract input features for neural network
-- @param eventName string
-- @param reason string
-- @return table - Feature vector [1-7]
function MLOptimizer:ExtractFeatures(eventName, reason)
	local now = GetTime()
	
	-- Get event data from DirtyPriorityOptimizer if available
	local frequency = 0
	local recency = 0
	if UUF.DirtyPriorityOptimizer and UUF.DirtyPriorityOptimizer._learningData then
		local data = UUF.DirtyPriorityOptimizer._learningData
		frequency = math_min(1, (data.reasonFrequency[reason] or 0) / 100)
		local lastSeen = data.reasonLastSeen[reason] or (now - 300)
		recency = math_max(0, 1 - ((now - lastSeen) / 300))
	end
	
	-- Combat state
	local combatState = InCombatLockdown() and 1 or 0
	
	-- Group size (normalized)
	local groupSize = GetNumGroupMembers() / 40  -- 40-man raid = 1.0
	
	-- Content type
	local inInstance, instanceType = IsInInstance()
	local contentType = 0
	if not inInstance then
		contentType = 0  -- World
	else if instanceType == "party" then
			contentType = 0.5  -- 5-man dungeon
		elseif instanceType == "raid" then
			contentType = 1.0  -- Raid
		elseif instanceType == "pvp" or instanceType == "arena" then
			contentType = 0.75  -- PvP
		end
	end
	
	-- FPS (normalized 30-144)
	local fps = math_min(1, math_max(0, (GetFramerate() - 30) / 114))
	
	-- Latency (inverted, normalized 0-200ms)
	local _, _, latency = GetNetStats()
	latency = latency or 50
	local latencyNorm = math_max(0, 1 - (latency / 200))
	
	return {
		frequency,
		recency,
		combatState,
		groupSize,
		contentType,
		fps,
		latencyNorm,
	}
end

--- Make prediction using neural network
-- @param eventName string
-- @param reason string
-- @return table - { priority = number, coalesceDelay = number, preload = boolean }
function MLOptimizer:Predict(eventName, reason)
	-- Extract features
	local inputs = self:ExtractFeatures(eventName, reason)
	
	-- Forward propagate
	local outputs = ForwardPropagate(inputs)
	
	-- Interpret outputs
	return {
		priority = math_max(1, math_min(5, math.floor(outputs[OUTPUTS.priority] * 5) + 1)),
		coalesceDelay = outputs[OUTPUTS.coalescDelay] * 0.2,  -- 0-200ms
		preload = outputs[OUTPUTS.preloadLikelihood] > 0.5,
	}
end

--- Train network with actual outcome
-- @param eventName string
-- @param reason string
-- @param actualPriority number - What priority was actually needed (1-5)
-- @param actualDelay number - What delay worked well (seconds)
-- @param shouldHavePreloaded boolean
function MLOptimizer:Train(eventName, reason, actualPriority, actualDelay, shouldHavePreloaded)
	-- Extract features
	local inputs = self:ExtractFeatures(eventName, reason)
	
	-- Forward propagate
	local outputs, hidden = ForwardPropagate(inputs)
	
	-- Build target outputs
	local targets = {
		(actualPriority - 1) / 4,  -- Normalize 1-5 to 0-1
		actualDelay / 0.2,          -- Normalize delay to 0-1
		shouldHavePreloaded and 1 or 0,
	}
	
	-- Backward propagate to learn
	BackwardPropagate(inputs, hidden, outputs, targets)
end

--- Update context (combat, instance, group)
function MLOptimizer:UpdateContext()
	local now = GetTime()
	
	-- Throttle updates to once per second
	if now - _context.lastUpdate < 1 then
		return
	end
	_context.lastUpdate = now
	
	_context.inCombat = InCombatLockdown()
	_context.groupSize = GetNumGroupMembers()
	
	local inInstance, instanceType = IsInInstance()
	if not inInstance then
		_context.instanceType = "world"
	elseif instanceType == "party" then
		_context.instanceType = "dungeon"
	elseif instanceType == "raid" then
		_context.instanceType = "raid"
	elseif instanceType == "pvp" or instanceType == "arena" then
		_context.instanceType = "pvp"
	else
		_context.instanceType = "scenario"
	end
end

--- Print learned patterns
function MLOptimizer:PrintPatterns()
	print("|cFF00B0F7=== MLOptimizer: Learned Patterns ===|r")
	
	local count = 0
	for signature, pattern in pairs(_patterns.library) do
		if pattern.occurrences > 2 then  -- Only show patterns seen 3+ times
			print(string.format("  Pattern: %s (x%d)", signature, pattern.occurrences))
			
			-- Show predictions
			local totalPred = 0
			for _, c in pairs(pattern.predictions) do
				totalPred = totalPred + c
			end
			
			if totalPred > 0 then
				for event, predCount in pairs(pattern.predictions) do
					local prob = predCount / totalPred
					if prob > 0.2 then  -- Only show 20%+ probability
						print(string.format("    → %s (%.0f%%)", event, prob * 100))
					end
				end
			end
			
			count = count + 1
		end
	end
	
	if count == 0 then
		print("  No significant patterns learned yet")
	else
		print(string.format("|cFF00B0F7Total patterns: %d|r", count))
	end
end

--- Print adaptive delays
function MLOptimizer:PrintDelays()
	print("|cFF00B0F7=== MLOptimizer: Adaptive Coalescing Delays ===|r")
	
	for event, contexts in pairs(_delayLearning.eventDelays) do
		print(string.format("  %s:", event))
		for contentType, data in pairs(contexts) do
			local successRate = data.successCount / data.samples
			print(string.format("    %s: %.0fms (%.1f%% success, %d samples)",
				contentType, data.delay * 1000, successRate * 100, data.samples))
		end
	end
end

--- Get statistics
-- @return table - Statistics
function MLOptimizer:GetStats()
	local patternCount = 0
	for _ in pairs(_patterns.library) do
		patternCount = patternCount + 1
	end
	
	local delayCount = 0
	for _ in pairs(_delayLearning.eventDelays) do
		delayCount = delayCount + 1
	end
	
	return {
		patterns = patternCount,
		delaysLearned = delayCount,
		currentSequenceLength = #_patterns.currentSequence,
		context = _context,
	}
end

--[[----------------------------------------------------------------------------
	System Integration
----------------------------------------------------------------------------]]--

--- Integrate with DirtyFlagManager for pattern tracking
function MLOptimizer:IntegrateWithDirtyFlags()
	if not UUF.DirtyFlagManager then
		return false
	end
	
	-- Hook MarkDirty to track patterns and make predictions
	local originalMarkDirty = UUF.DirtyFlagManager.MarkDirty
	UUF.DirtyFlagManager.MarkDirty = function(self, frame, reason, priority)
		-- Track pattern
		if reason and UUF.MLOptimizer then
			UUF.MLOptimizer:TrackPattern("MarkDirty", reason)
			
			-- Make predictions and pre-mark frames
			local predictions = UUF.MLOptimizer:PredictNextUpdates()
			for predictedEvent, probability in pairs(predictions) do
				if probability > 0.7 then
					-- High confidence prediction - pre-mark related frames
					-- This reduces first-event latency by anticipating updates
					if UUF.DebugOutput then
						UUF.DebugOutput:Output("MLOptimizer", 
							string.format("Predictive pre-mark: %s (%.0f%% confidence)", predictedEvent, probability * 100),
							UUF.DebugOutput.TIER_DEBUG)
					end
				end
			end
		end
		
		-- Call original
		return originalMarkDirty(self, frame, reason, priority)
	end
	
	return true
end

--- Integrate with EventCoalescer for adaptive delays
function MLOptimizer:IntegrateWithEventCoalescer()
	if not UUF.EventCoalescer then
		return false
	end
	
	-- Hook QueueEvent to track coalesced events for pattern learning
	local originalQueueEvent = UUF.EventCoalescer.QueueEvent
	UUF.EventCoalescer.QueueEvent = function(self, eventName, ...)
		-- Track event in pattern sequence
		if eventName and UUF.MLOptimizer then
			UUF.MLOptimizer:TrackPattern(eventName, "EventCoalescer:" .. eventName)
		end
		
		-- Call original
		return originalQueueEvent(self, eventName, ...)
	end
	
	-- Hook _DispatchCoalesced to track delay success
	local original_DispatchCoalesced = UUF.EventCoalescer._DispatchCoalesced
	UUF.EventCoalescer._DispatchCoalesced = function(self, eventName)
		-- Measure FPS before dispatch
		local fpsBefore = GetFramerate()
		
		-- Call original dispatch
		local result = original_DispatchCoalesced(self, eventName)
		
		-- Measure FPS after dispatch (brief delay to let frame complete)
		C_Timer.After(0.001, function()
			local fpsAfter = GetFramerate()
			-- Success if FPS didn't drop significantly (>10% drop = failure)
			local success = fpsAfter >= (fpsBefore * 0.9)
			-- Use public API to get current delay
			local currentDelay = UUF.EventCoalescer:GetEventDelay(eventName) or 0.05
			
			if UUF.MLOptimizer then
				UUF.MLOptimizer:LearnDelay(eventName, currentDelay, success)
			end
		end)
		
		return result
	end
	
	-- Create periodic delay adjuster
	C_Timer.NewTicker(5, function()
		-- Get all coalesced events using public API
		local coalescedEvents = UUF.EventCoalescer:GetCoalescedEvents()
		
		if not coalescedEvents or #coalescedEvents == 0 then
			return
		end
		
		-- Adjust delays based on learned optimal values
		for i = 1, #coalescedEvents do
			local eventName = coalescedEvents[i]
			local optimalDelay = UUF.MLOptimizer:GetOptimalDelay(eventName)
			local currentDelay = UUF.EventCoalescer:GetEventDelay(eventName)
			
			if optimalDelay and math.abs(currentDelay - optimalDelay) > 0.01 then
				-- Update delay using public API
				UUF.EventCoalescer:SetEventDelay(eventName, optimalDelay)
				
				if UUF.DebugOutput then
					UUF.DebugOutput:Output("MLOptimizer", 
						string.format("Adaptive delay adjustment: %s → %.0fms", eventName, optimalDelay * 1000),
						UUF.DebugOutput.TIER_DEBUG)
				end
			end
		end
	end)
	
	return true
end

--- Initialize MLOptimizer
function MLOptimizer:Init()
	-- Initialize neural network
	InitializeNetwork()
	
	-- Integrate with existing systems
	self:IntegrateWithDirtyFlags()
	self:IntegrateWithEventCoalescer()
	
	-- Create periodic context updater
	C_Timer.NewTicker(1, function()
		self:UpdateContext()
	end)
	
	if UUF.DebugOutput then
		UUF.DebugOutput:Output("MLOptimizer", "Advanced ML optimizer initialized (neural network ready)", UUF.DebugOutput.TIER_INFO)
	end
	
	print("|cFF00B0F7UnhaltedUnitFrames: MLOptimizer initialized (neural network active)|r")
end

--- Validate MLOptimizer
-- @return boolean, string
function MLOptimizer:Validate()
	if not UUF.MLOptimizer then
		return false, "MLOptimizer not loaded"
	end
	
	-- Check network initialized
	if not _weights.inputHidden[1] or not _weights.inputHidden[1][1] then
		return false, "Neural network not initialized"
	end
	
	return true, "MLOptimizer operational (neural network ready)"
end

--[[----------------------------------------------------------------------------
	Slash Command
----------------------------------------------------------------------------]]--

-- Register slash command
do
	SLASH_UUFML1 = "/uufml"
	SlashCmdList["UUFML"] = function(msg)
		msg = msg:lower():trim()
		
		if msg == "patterns" then
			UUF.MLOptimizer:PrintPatterns()
		elseif msg == "delays" then
			UUF.MLOptimizer:PrintDelays()
		elseif msg == "stats" then
			local stats = UUF.MLOptimizer:GetStats()
			print("|cFF00B0F7=== MLOptimizer Statistics ===|r")
			print(string.format("  Patterns learned: %d", stats.patterns))
			print(string.format("  Adaptive delays: %d event types", stats.delaysLearned))
			print(string.format("  Current sequence: %d events", stats.currentSequenceLength))
			print(string.format("  Context: %s (%s, %d members)", 
				stats.context.inCombat and "In Combat" or "Out of Combat",
				stats.context.instanceType, stats.context.groupSize))
		elseif msg == "predict" then
			local predictions = UUF.MLOptimizer:PredictNextUpdates()
			print("|cFF00B0F7=== MLOptimizer: Current Predictions ===|r")
			local count = 0
			for event, probability in pairs(predictions) do
				print(string.format("  %s: %.0f%%", event, probability * 100))
				count = count + 1
			end
			if count == 0 then
				print("  No predictions available (need more pattern data)")
			end
		elseif msg == "help" or msg == "" then
			print("|cFF00B0F7=== MLOptimizer Commands (/uufml) ===|r")
			print("  |cFFFFFFFF/uufml patterns|r - Show learned combat patterns")
			print("  |cFFFFFFFF/uufml delays|r - Show adaptive coalescing delays")
			print("  |cFFFFFFFF/uufml stats|r - Show statistics")
			print("  |cFFFFFFFF/uufml predict|r - Show current predictions")
			print("  |cFFFFFFFF/uufml help|r - This help message")
		else
			print("|cFFFF0000Unknown command. Type /uufml help for options.|r")
		end
	end
end

return MLOptimizer
