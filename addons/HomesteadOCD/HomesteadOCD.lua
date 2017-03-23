-- For some reason, HomesteadOCD doesn't work, has to be MyHomesteadOCD. Bizarre.
MyHomesteadOCD = {}

local selectedFurnitureId = nil
local nudgeMagnitudeX = 10
local nudgeMagnitudeY = 10
local nudgeMagnitudeZ = 10
local nudgeMagnitudeYaw = 15
local nudgeMagnitudePitch = 15
local nudgeMagnitudeRoll = 15

local viewSelectedItemGUI = nil

-- Addon constants
local ADDON_NAME = "HomesteadOCD"

function MyHomesteadOCD:Initialize()
	-- Apply language strings
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_PRECISE_SELECT", "Precise select furniture")
	
	--[[
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_X_POSITIVE", "Nudge +X")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_X_NEGATIVE", "Nudge -X")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_Y_POSITIVE", "Nudge +Y")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_Y_NEGATIVE", "Nudge -Y")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_Z_POSITIVE", "Nudge +Z")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_Z_NEGATIVE", "Nudge -Z")
	
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_PITCH_POSITIVE", "Nudge +Pitch")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_PITCH_NEGATIVE", "Nudge -Pitch")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_YAW_POSITIVE", "Nudge +Yaw")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_YAW_NEGATIVE", "Nudge -Yaw")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_ROLL_POSITIVE", "Nudge +Roll")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_OCD_NUDGE_ROLL_NEGATIVE", "Nudge -Roll")
	]]--
end

function MyHomesteadOCD:AddGUIField(name, fieldTitle, mainWindow, offset)
	local lblTitle = WINDOW_MANAGER:CreateControl("lbl" .. name, mainWindow, CT_LABEL)
	lblTitle:SetColor(1, 1, 1, 1)
	lblTitle:SetFont("ZoFontGameLargeBold")
	lblTitle:SetText(fieldTitle)
	lblTitle:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 15, offset)

	local newBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("bg" .. name, mainWindow, "ZO_SingleLineEditBackdrop_Keyboard")
	newBackdrop:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 65, offset)
	newBackdrop:SetDimensions(115, 20)
	
	local newTextField = WINDOW_MANAGER:CreateControlFromVirtual("txt" .. name, mainWindow, "ZO_DefaultEditForBackdrop") 
	newTextField:SetAnchor(TOPLEFT, newBackdrop, TOPLEFT, 0, 0)
	newTextField:SetAnchor(BOTTOMRIGHT, newBackdrop, BOTTOMRIGHT, 0, 0)
	newTextField:SetFont("ZoFontGameLarge")
	
	return newTextField
end

function MyHomesteadOCD:ShowSelectedItemGUI()
	if (viewSelectedItemGUI == nil) then
		viewSelectedItemGUI = {}
	
		-- Create window
		viewSelectedItemGUI.window = WINDOW_MANAGER:CreateTopLevelWindow("viewSelectedItemGUIWindow")	
		viewSelectedItemGUI.window:SetDimensions(200, 215)
		viewSelectedItemGUI.window:SetAnchor(RIGHT, GuiRoot, RIGHT, 0, 0)
		viewSelectedItemGUI.window:SetMovable(true)
		viewSelectedItemGUI.window:SetMouseEnabled(true)
		viewSelectedItemGUI.window:SetClampedToScreen(true)
		
		-- Create backdrop
		viewSelectedItemGUI.bdBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("bdBackdrop", viewSelectedItemGUI.window, "ZO_DefaultBackdrop")
		viewSelectedItemGUI.bdBackdrop:SetAnchor(TOPLEFT, viewSelectedItemGUI.window, TOPLEFT, 4, 4)
		viewSelectedItemGUI.bdBackdrop:SetAnchor(BOTTOMRIGHT, viewSelectedItemGUI.window, BOTTOMRIGHT, -4, -4)
		viewSelectedItemGUI.bdBackdrop:SetAlpha(0.6)
		
		viewSelectedItemGUI.lblSelectedObject = WINDOW_MANAGER:CreateControl("lblSelectedObject", viewSelectedItemGUI.window, CT_LABEL)
		viewSelectedItemGUI.lblSelectedObject:SetColor(1, 1, 1, 1)
		viewSelectedItemGUI.lblSelectedObject:SetFont("ZoFontGameLargeBoldShadow")
		viewSelectedItemGUI.lblSelectedObject:SetText("Selected Object")
		viewSelectedItemGUI.lblSelectedObject:SetAnchor(TOP, viewSelectedItemGUI.window, TOP, 0, 5)
		
		local updateXYZHandler = function(editBox)
			HousingEditorRequestChangePosition(selectedFurnitureId, viewSelectedItemGUI.txtObjectX:GetText(), viewSelectedItemGUI.txtObjectY:GetText(), viewSelectedItemGUI.txtObjectZ:GetText())
		end
		
		local updateOrientationHandler = function(editBox)
			HousingEditorRequestChangeOrientation(selectedFurnitureId, math.rad(viewSelectedItemGUI.txtObjectPitch:GetText()), math.rad(viewSelectedItemGUI.txtObjectYaw:GetText()), math.rad(viewSelectedItemGUI.txtObjectRoll:GetText()))
		end
		
		viewSelectedItemGUI.txtObjectX = MyHomesteadOCD:AddGUIField("ObjectX", "X:", viewSelectedItemGUI.window, 30)
		viewSelectedItemGUI.txtObjectX:SetHandler("OnFocusLost", updateXYZHandler)
		viewSelectedItemGUI.txtObjectY = MyHomesteadOCD:AddGUIField("ObjectY", "Y:", viewSelectedItemGUI.window, 60)
		viewSelectedItemGUI.txtObjectY:SetHandler("OnFocusLost", updateXYZHandler)
		viewSelectedItemGUI.txtObjectZ = MyHomesteadOCD:AddGUIField("ObjectZ", "Z:", viewSelectedItemGUI.window, 90)
		viewSelectedItemGUI.txtObjectZ:SetHandler("OnFocusLost", updateXYZHandler)
		
		viewSelectedItemGUI.txtObjectPitch = MyHomesteadOCD:AddGUIField("ObjectPitch", "Pitch:", viewSelectedItemGUI.window, 120)
		viewSelectedItemGUI.txtObjectPitch:SetHandler("OnFocusLost", updateOrientationHandler)
		viewSelectedItemGUI.txtObjectYaw = MyHomesteadOCD:AddGUIField("ObjectYaw", "Yaw:", viewSelectedItemGUI.window, 150)
		viewSelectedItemGUI.txtObjectYaw:SetHandler("OnFocusLost", updateOrientationHandler)
		viewSelectedItemGUI.txtObjectRoll = MyHomesteadOCD:AddGUIField("ObjectRoll", "Roll:", viewSelectedItemGUI.window, 180)
		viewSelectedItemGUI.txtObjectRoll:SetHandler("OnFocusLost", updateOrientationHandler)
		
		--[[
		viewSelectedItemGUI.lblSelectedObject = WINDOW_MANAGER:CreateControl("lblNudgeControls", viewSelectedItemGUI.window, CT_LABEL)
		viewSelectedItemGUI.lblSelectedObject:SetColor(1, 1, 1, 1)
		viewSelectedItemGUI.lblSelectedObject:SetFont("ZoFontGameLargeBoldShadow")
		viewSelectedItemGUI.lblSelectedObject:SetText("Nudge Configuration")
		viewSelectedItemGUI.lblSelectedObject:SetAnchor(TOP, viewSelectedItemGUI.window, TOP, 0, 215)	
		]]--
	end
	
	local worldX, worldY, worldZ, pitchRad, yawRad, rollRad = 0, 0, 0, 0, 0, 0
	
	worldX, worldY, worldZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
	pitchRad, yawRad, rollRad = HousingEditorGetFurnitureOrientation(selectedFurnitureId)
	
	viewSelectedItemGUI.txtObjectX:SetText(worldX)
	viewSelectedItemGUI.txtObjectY:SetText(worldY)
	viewSelectedItemGUI.txtObjectZ:SetText(worldZ)
	
	viewSelectedItemGUI.txtObjectPitch:SetText(MyHomesteadOCD:Round(math.deg(pitchRad), 2))
	viewSelectedItemGUI.txtObjectYaw:SetText(MyHomesteadOCD:Round(math.deg(yawRad), 2))
	viewSelectedItemGUI.txtObjectRoll:SetText(MyHomesteadOCD:Round(math.deg(rollRad), 2))
	
	viewSelectedItemGUI.window:SetHidden(false)
end

-- you don't need THAT much precision, nerd
function MyHomesteadOCD:Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function MyHomesteadOCD:Select(newSelectedFurnitureId)
	selectedFurnitureId = newSelectedFurnitureId
	MyHomesteadOCD:ShowSelectedItemGUI()
end

function MyHomesteadOCD:Unselect()
	selectedFurnitureId = nil
	if (viewSelectedItemGUI ~= nil) then
		viewSelectedItemGUI.window:SetHidden(true)
	end
end

function HomesteadOCD_PreciseSelect()
	-- Only allow selection in housing editor browse mode
	local editorMode = GetHousingEditorMode()
	if (editorMode ~= HOUSING_EDITOR_MODE_SELECTION) then
		return
	end
	
	-- Unselect if not looking at valid target
	if (not HousingEditorCanSelectTargettedFurniture()) then
		MyHomesteadOCD:Unselect()
		return
	end
	
	-- Get the furniture ID by picking the object up, reading it's ID, then putting it back down immediately.
	-- Stupid hack - I don't think there is a way to get the ID without picking it up.
	-- Can't even "unselect" it.
	local selectAttemptResult = HousingEditorSelectTargettedFurniture()
	local newSelectedFurnitureId = HousingEditorGetSelectedFurnitureId()
	HousingEditorRequestSelectedPlacement()
	
	if (newSelectedFurnitureId == nil) then
		MyHomesteadOCD:Unselect()
	else
		MyHomesteadOCD:Select(newSelectedFurnitureId)
	end
end

function HomesteadOCD_NudgeXPositive()
	
end

function HomesteadOCD_NudgeXNegative()
end

function MyHomesteadOCD.OnAddOnLoaded(event, addonName)
	if (addonName == ADDON_NAME) then
		MyHomesteadOCD:Initialize()
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, MyHomesteadOCD.OnAddOnLoaded)