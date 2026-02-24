local _, UUF = ...

local Pixel = UUF.Pixel

-- Function to get Pixel unit equivalent on WoW virtual space
function UUF:PixelGet()
	local scale = UIParent:GetEffectiveScale()
	local _, screenHeight = GetPhysicalScreenSize()
	local pixel = 1 / (screenHeight * scale)

    return math.max(pixel, 768.0 / screenHeight)
end

-- Function to round values
local function NumRound(num, dp)
	local mult = 10^(dp or 0)
	return math.floor(num * mult + 0.5)/mult
end

-- Round value to integer Pixel Perfect value
function UUF:PixelRound(value, parent, minValue)
	if value == 0 and (not minValue or MinValue == 0) then return 0 end
	if parent == nil then parent = UIParent end
	
	local pixelUnit = self:PixelGet()
	local scale = parent:GetEffectiveScale()
	local pixelNum = NumRound((value * scale) / pixelUnit)
	
	if minValue then
		if value < 0.0 then
			if pixelNum > -minValue then
				pixelNum = -minValue
			end
		else
			if pixelNum < minValue then
				pixelNum = minValue
			end
		end
	end
	
	return pixelNum * pixelUnit / scale
end

-- Function to set frame size at Pixel Perfection proportions
function UUF:PixelSize(frame, width, height, minWidthPixel, minHeightPixel)
	frame:SetSize(
		self:PixelRound(width, frame, minWidthPixel),
		self:PixelRound(height, frame, minHeightPixel)
	)
end

-- Function to set frame width at Pixel Perfection proportions
function UUF:PixelWidth(frame, width, minWidthPixel)
	frame:SetWidth(
		self:PixelRound(width, frame, minWidthPixel)
	)
end

-- Function to set frame height at Pixel Perfection proportions
function UUF:PixelHeight(frame, height, minHeightPixel)
	frame:SetHeight(
		self:PixelRound(height, frame, minHeightPixel)
	)
end

-- Function to set points at Pixel Perfect location
function UUF:PixelPoint(frame, point, relativeTo, relativePoint, x, y, minX, minY)
	frame:ClearAllPoints()
	frame:SetPoint(
		point,
		relativeTo,
		relativePoint,
		self:PixelRound(x, frame, minX),
		self:PixelRound(y, frame, minY)
	)
end

-- Function to make crisp Border
function UUF:PixelBorder(thickness, frame)
	return self:PixelRound(thickness or 1, frame)
end

-- Function to make a frame pixel perfect
function UUF:FramePixelPerfect(frame)
	local pmult = self:PixelGet()
	if frame == nil then
		return
	else
		local scale = frame:GetEffectiveScale()
		local p = pmult / scale
		
		-- Force to pixel integer if frame has valid points
		if not (frame:GetLeft() == nil) then
			local x = frame:GetLeft()
			local y = frame:GetTop()
			
			frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor(x / p + 0.5) * p, math.floor(y / p + 0.5) * p)
		elseif not (frame:GetParent() == nil) then
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", -pmult, pmult)
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", pmult, -pmult)
		end
		
		-- Ensure size is a multiple of pixel
		local width = frame:GetWidth()
		local height = frame:GetHeight()
		frame:SetSize(math.floor(width / p + 0.5) * p, math.floor(height / p + 0.5) * p)
	end
end