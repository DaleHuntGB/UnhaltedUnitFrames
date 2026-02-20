-- ===================================================================
-- DIAGNOSTIC: Player Frame Portrait Distortion Analysis
-- Issue: Player unitframe is distorted/oversized 3D model after Phase 5b
-- ===================================================================

-- DIAGNOSTIC 1: Element visibility and basic structure
local function DiagnosticElementVisibility()
    local f = UUF.PLAYER
    if not f then
        print("ERROR: UUF.PLAYER not found!")
        return
    end
    
    print("\n========== DIAGNOSTIC 1: Element Visibility & Structure ==========")
    print("Player Frame:", f and "EXISTS" or "MISSING")
    print("  Frame Level:", f:GetFrameLevel())
    print("  Frame Size:", f:GetWidth(), "x", f:GetHeight())
    print("  Is Visible:", f:IsVisible())
    
    print("\nContainer:")
    print("  Container exists:", f.Container and "YES" or "NO")
    if f.Container then
        print("    Size:", f.Container:GetWidth(), "x", f.Container:GetHeight())
        print("    Visible:", f.Container:IsVisible())
        print("    Frame Level:", f.Container:GetFrameLevel())
    end
    
    print("\nHighLevelContainer:")
    print("  HighLevelContainer exists:", f.HighLevelContainer and "YES" or "NO")
    if f.HighLevelContainer then
        print("    Size:", f.HighLevelContainer:GetWidth(), "x", f.HighLevelContainer:GetHeight())
        print("    Visible:", f.HighLevelContainer:IsVisible())
        print("    Frame Level:", f.HighLevelContainer:GetFrameLevel())
        print("    Strata:", f.HighLevelContainer:GetFrameStrata())
    end
    
    print("\nHealth Bar:")
    print("  Health exists:", f.Health and "YES" or "NO")
    if f.Health then
        print("    Size:", f.Health:GetWidth(), "x", f.Health:GetHeight())
        print("    Visible:", f.Health:IsVisible())
        print("    Frame Level:", f.Health:GetFrameLevel())
    end
    
    print("\nPower Bar:")
    print("  PowerBar exists:", f.PowerBar and "YES" or "NO")
    if f.PowerBar then
        print("    Size:", f.PowerBar:GetWidth(), "x", f.PowerBar:GetHeight())
        print("    Visible:", f.PowerBar:IsVisible())
        print("    Frame Level:", f.PowerBar:GetFrameLevel())
    end
    
    print("\nPortrait:")
    print("  Portrait exists:", f.Portrait and "YES" or "NO")
    if f.Portrait then
        local isModelFrame = f.Portrait:IsObjectType("PlayerModel")
        print("    Is 3D (PlayerModel):", isModelFrame and "YES" or "NO")
        print("    Is Texture:", f.Portrait:IsObjectType("Texture") and "YES" or "NO")
        print("    Size:", f.Portrait:GetWidth(), "x", f.Portrait:GetHeight())
        print("    Visible:", f.Portrait:IsVisible())
        if f.Portrait.Backdrop then
            print("    Backdrop exists:", "YES")
            print("      Backdrop Size:", f.Portrait.Backdrop:GetWidth(), "x", f.Portrait.Backdrop:GetHeight())
            print("      Backdrop Visible:", f.Portrait.Backdrop:IsVisible())
        end
        if f.Portrait.Border then
            print("    Border exists:", "YES")
            print("      Border Visible:", f.Portrait.Border:IsVisible())
        end
    end
    
    print("\nName:")
    print("  Name exists:", f.Name and "YES" or "NO")
    if f.Name then
        print("    Visible:", f.Name:IsVisible())
        print("    Text:", f.Name:GetText())
    end
end

-- DIAGNOSTIC 2: Frame hierarchy
local function DiagnosticFrameHierarchy()
    print("\n========== DIAGNOSTIC 2: Frame Hierarchy ==========")
    local f = UUF.PLAYER
    
    if not f then
        print("ERROR: UUF.PLAYER not found!")
        return
    end
    
    print("Root Container (UUF.PLAYER):")
    print("  Parent:", f:GetParent() and f:GetParent():GetName() or "NONE")
    print("  Children count:", f:GetNumChildren())
    
    -- List direct children
    local children = { f:GetChildren() }
    print("\n  Direct Children:")
    for i, child in ipairs(children) do
        local name = child:GetName() or "(unnamed)"
        local objType = child:GetObjectType()
        print(string.format("    [%d] %s (%s) - Level: %d, Visible: %s", 
            i, name, objType, child:GetFrameLevel(), child:IsVisible() and "YES" or "NO"))
    end
    
    -- Analyze HighLevelContainer children
    if f.HighLevelContainer then
        print("\nHighLevelContainer Children count:", f.HighLevelContainer:GetNumChildren())
        local hlcChildren = { f.HighLevelContainer:GetChildren() }
        print("  HighLevelContainer Children:")
        for i, child in ipairs(hlcChildren) do
            local name = child:GetName() or "(unnamed)"
            local objType = child:GetObjectType()
            print(string.format("    [%d] %s (%s) - Level: %d, Size: %sx%s, Visible: %s", 
                i, name, objType, child:GetFrameLevel(), child:GetWidth() or "?", child:GetHeight() or "?", 
                child:IsVisible() and "YES" or "NO"))
        end
    end
end

-- DIAGNOSTIC 3: Portrait-specific details
local function DiagnosticPortraitDetails()
    print("\n========== DIAGNOSTIC 3: Portrait Configuration Details ==========")
    local f = UUF.PLAYER
    
    if not f or not f.Portrait then
        print("ERROR: UUF.PLAYER or Portrait not found!")
        return
    end
    
    print("Portrait DB Configuration:")
    local PortraitDB = UUF.db.profile.Units.player.Portrait
    if PortraitDB then
        print("  Enabled:", PortraitDB.Enabled and "YES" or "NO")
        print("  Style:", PortraitDB.Style or "UNKNOWN")
        print("  Width:", PortraitDB.Width or "?")
        print("  Height:", PortraitDB.Height or "?")
        print("  Layout: ", PortraitDB.Layout[1], PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
        print("  UseClassPortrait:", PortraitDB.UseClassPortrait and "YES" or "NO")
        print("  Zoom:", PortraitDB.Zoom or "UNKNOWN")
    end
    
    print("\nPortrait Runtime State:")
    print("  Type:", f.Portrait:IsObjectType("PlayerModel") and "3D (PlayerModel)" or "2D (Texture)")
    print("  Size:", f.Portrait:GetWidth(), "x", f.Portrait:GetHeight())
    print("  Frame Level:", f.Portrait:GetFrameLevel())
    print("  Visible:", f.Portrait:IsVisible())
    
    if f.Portrait:IsObjectType("PlayerModel") then
        print("  3D Model Properties:")
        -- These are readonly getters, but let's see if we can get info
        print("    CamDistanceScale: (runtime value)")
        print("    PortraitZoom: (runtime value)")
        
        if f.Portrait.Backdrop then
            print("\n  Backdrop (Parent of 3D Model):")
            print("    Size:", f.Portrait.Backdrop:GetWidth(), "x", f.Portrait.Backdrop:GetHeight())
            print("    Position: ", f.Portrait.Backdrop:GetPoint())
            print("    Visible:", f.Portrait.Backdrop:IsVisible())
            print("    NumChildren:", f.Portrait.Backdrop:GetNumChildren())
        else
            print("\n  ERROR: Backdrop not found! PlayerModel should have Backdrop parent")
        end
    else
        print("\n  2D Texture Properties:")
        print("    TexCoord: (runtime)")
        print("    showClass: ", f.Portrait.showClass)
    end
end

-- DIAGNOSTIC 4: Frame anchoring
local function DiagnosticFrameAnchoring()
    print("\n========== DIAGNOSTIC 4: Frame Anchoring Points ==========")
    local f = UUF.PLAYER
    
    if not f then
        print("ERROR: UUF.PLAYER not found!")
        return
    end
    
    print("Main Frame (UUF.PLAYER):")
    for i = 1, f:GetNumPoints() do
        local point, relFrame, relPoint, x, y = f:GetPoint(i)
        local relName = relFrame and relFrame:GetName() or "UIParent"
        print(string.format("  Point %d: %s anchored to %s %s at (%d, %d)", 
            i, point, relName, relPoint, x, y))
    end
    
    if f.HighLevelContainer then
        print("\nHighLevelContainer:")
        for i = 1, f.HighLevelContainer:GetNumPoints() do
            local point, relFrame, relPoint, x, y = f.HighLevelContainer:GetPoint(i)
            local relName = relFrame and relFrame:GetName() or "UIParent"
            print(string.format("  Point %d: %s anchored to %s %s at (%d, %d)", 
                i, point, relName, relPoint, x, y))
        end
    end
    
    if f.Portrait then
        print("\nPortrait:")
        for i = 1, f.Portrait:GetNumPoints() do
            local point, relFrame, relPoint, x, y = f.Portrait:GetPoint(i)
            local relName = relFrame and relFrame:GetName() or "UIParent"
            print(string.format("  Point %d: %s anchored to %s %s at (%d, %d)", 
                i, point, relName, relPoint, x, y))
        end
    end
    
    if f.Portrait and f.Portrait.Backdrop then
        print("\nPortrait Backdrop:")
        for i = 1, f.Portrait.Backdrop:GetNumPoints() do
            local point, relFrame, relPoint, x, y = f.Portrait.Backdrop:GetPoint(i)
            local relName = relFrame and relFrame:GetName() or "UIParent"
            print(string.format("  Point %d: %s anchored to %s %s at (%d, %d)", 
                i, point, relName, relPoint, x, y))
        end
    end
end

-- DIAGNOSTIC 5: Check for frame validation issues
local function DiagnosticFrameValidation()
    print("\n========== DIAGNOSTIC 5: Frame Validation ==========")
    local f = UUF.PLAYER
    
    if not f then
        print("ERROR: UUF.PLAYER not found!")
        return
    end
    
    print("Frame Type Checks:")
    print("  Is Table:", type(f) == "table" and "YES" or "NO")
    print("  Has GetWidth:", type(f.GetWidth) == "function" and "YES" or "NO")
    print("  Has GetHeight:", type(f.GetHeight) == "function" and "YES" or "NO")
    print("  Has SetAllPoints:", type(f.SetAllPoints) == "function" and "YES" or "NO")
    print("  GetObjectType:", f:GetObjectType())
    
    print("\nPortrait Type Checks:")
    if f.Portrait then
        print("  Is Table:", type(f.Portrait) == "table" and "YES" or "NO")
        print("  Has GetWidth:", type(f.Portrait.GetWidth) == "function" and "YES" or "NO")
        print("  Has SetAllPoints:", type(f.Portrait.SetAllPoints) == "function" and "YES" or "NO")
        print("  GetObjectType:", f.Portrait:GetObjectType())
    end
    
    print("\nHighLevelContainer Type Checks:")
    if f.HighLevelContainer then
        print("  Is Table:", type(f.HighLevelContainer) == "table" and "YES" or "NO")
        print("  Has GetWidth:", type(f.HighLevelContainer.GetWidth) == "function" and "YES" or "NO")
        print("  GetObjectType:", f.HighLevelContainer:GetObjectType())
    end
end

-- DIAGNOSTIC 6: Check ML system interference
local function DiagnosticMLSystemState()
    print("\n========== DIAGNOSTIC 6: ML System State ==========")
    
    if UUF.MLOptimizer then
        print("MLOptimizer Status:")
        print("  Loaded: YES")
        if UUF.MLOptimizer._networkInitialized then
            print("  Neural Network: INITIALIZED")
        else
            print("  Neural Network: NOT INITIALIZED")
        end
        if UUF.MLOptimizer._preloadMarkers then
            print("  Preload Markers count:", #UUF.MLOptimizer._preloadMarkers or 0)
            local playerPreload = UUF.MLOptimizer._preloadMarkers["PLAYER"]
            if playerPreload then
                print("  PLAYER preload marker: EXISTS")
                print("    Confidence:", playerPreload.confidence or "?")
            end
        end
    else
        print("MLOptimizer: NOT LOADED")
    end
    
    if UUF.DirtyFlagManager then
        print("\nDirtyFlagManager Status:")
        print("  Loaded: YES")
        print("  Framework available: YES")
    else
        print("\nDirtyFlagManager: NOT LOADED")
    end
    
    print("\nReactive Config:")
    if UUF.ReactiveConfig then
        print("  Loaded: YES")
    else
        print("  Loaded: NO")
    end
end

-- Run all diagnostics
local function RunAllDiagnostics()
    print("\n\n╔════════════════════════════════════════════════════════════════╗")
    print("║   PLAYER FRAME PORTRAIT DISTORTION DIAGNOSTIC SUITE            ║")
    print("║   Issue: Player unitframe oversized/distorted 3D model         ║")
    print("║   Date: 2026-02-19 (Phase 5b ML Changes)                       ║")
    print("╚════════════════════════════════════════════════════════════════╝")
    
    DiagnosticElementVisibility()
    DiagnosticFrameHierarchy()
    DiagnosticPortraitDetails()
    DiagnosticFrameAnchoring()
    DiagnosticFrameValidation()
    DiagnosticMLSystemState()
    
    print("\n\n" .. string.rep("=", 70))
    print("DIAGNOSTICS COMPLETE - Check output above for issues")
    print(string.rep("=", 70) .. "\n")
end

-- Execute or register for later
if type(UUF) == "table" then
    RunAllDiagnostics()
else
    print("WARNING: UUF not loaded yet. Run this after addon loads:")
    print('  /run RunAllDiagnostics()')
end
