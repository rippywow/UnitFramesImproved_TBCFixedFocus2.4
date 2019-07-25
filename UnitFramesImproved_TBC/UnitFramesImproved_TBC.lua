-- Credits to stassart on curse.com for suggesting to use InCombatLockdown() checks in the code

-- Debug function. Adds message to the chatbox (only visible to the loacl player)
function dout(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

-- Additional debug info can be found on http://www.wowwiki.com/Blizzard_DebugTools
-- /framestack [showhidden]
--		showhidden - if "true" then will also display information about hidden frames
-- /eventtrace [command]
-- 		start - enables event capturing to the EventTrace frame
--		stop - disables event capturing
--		number - captures the provided number of events and then stops
--		If no command is given the EventTrace frame visibility is toggled. The first time the frame is displayed, event tracing is automatically started.
-- /dump expression
--		expression can be any valid lua expression that results in a value. So variable names, function calls, frames or tables can all be dumped.

UNITFRAMESIMPROVED_UI_COLOR = {r = .3, g = .3, b = .3}
FLAT_TEXTURE   = [[Interface\AddOns\UnitFramesImproved_TBC\Textures\flat.tga]]
ORIG_TEXTURE   = [[Interface\TargetingFrame\UI-StatusBar.blp]]

function tokenize(str)
	local tbl = {};
	for v in string.gmatch(str, "[^ ]+") do
		tinsert(tbl, v);
	end
	return tbl;
end

-- Create the addon main instance
local UnitFramesImproved = CreateFrame('Button', 'UnitFramesImproved');

-- Event listener to make sure we enable the addon at the right time
function UnitFramesImproved:PLAYER_ENTERING_WORLD()
	-- Set some default settings
	if (characterSettings == nil) then
		UnitFramesImproved_LoadDefaultSettings();
	end
	
	EnableUnitFramesImproved();
end

-- Event listener to make sure we've loaded our settings and thta we apply them
function UnitFramesImproved:VARIABLES_LOADED()
	dout("UnitFramesImproved settings loaded!");
	
	-- Set some default settings
	if (characterSettings == nil) then
		UnitFramesImproved_LoadDefaultSettings();
	end
	
	if (not (characterSettings["PlayerFrameAnchor"] == nil)) then
		StaticPopup_Show("LAYOUT_RESETDEFAULT");
		characterSettings["PlayerFrameX"] = nil;
		characterSettings["PlayerFrameY"] = nil;
		characterSettings["PlayerFrameMoved"] = nil;
		characterSettings["PlayerFrameAnchor"] = nil;
	end
	
	UnitFramesImproved_ApplySettings(characterSettings);
end

function UnitFramesImproved_ApplySettings(settings)
	UnitFramesImproved_SetFrameScale(settings["FrameScale"])
end

function UnitFramesImproved_LoadDefaultSettings()
	characterSettings = {}
	characterSettings["FrameScale"] = "1.0";
	
	if not TargetFrame:IsUserPlaced() then
		TargetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPRIGHT", 36, 0);
	end
end

function EnableUnitFramesImproved()
	-- Generic status text hook
	--hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", UnitFramesImproved_TextStatusBar_UpdateTextStringWithValues);
	--hooksecurefunc("TextStatusBar_UpdateTextString", UnitFramesImproved_TextStatusBar_UpdateTextStringWithValues);
	
	-- Hook PlayerFrame functions
	--hooksecurefunc("PlayerFrame_ToPlayerArt", UnitFramesImproved_PlayerFrame_ToPlayerArt);
	--hooksecurefunc("PlayerFrame_OnUpdate", UnitFramesImproved_PlayerFrame_ToPlayerArt);
	hooksecurefunc("HealthBar_OnValueChanged", UnitFramesImproved_ColorUpdate);
	hooksecurefunc("PlayerFrame_OnUpdate", UnitFramesImproved_ColorUpdate);
	--HealthBar_OnValueChanged = UnitFramesImproved_ColorUpdate;
	--hooksecurefunc("PlayerFrame_ToVehicleArt", UnitFramesImproved_PlayerFrame_ToVehicleArt);
	
	-- Hook TargetFrame functions
	hooksecurefunc("TargetFrame_CheckDead", UnitFramesImproved_TargetFrame_Update);
	hooksecurefunc("TargetFrame_Update", UnitFramesImproved_TargetFrame_Update);
	hooksecurefunc("TargetFrame_OnUpdate", UnitFramesImproved_TargetFrame_Update);
	--hooksecurefunc("TargetFrame_OnUpdate", UnitFramesImproved_TargetFrame_Update);
	hooksecurefunc("TargetFrame_CheckFaction", UnitFramesImproved_TargetFrame_CheckFaction);
	hooksecurefunc("TargetFrame_CheckClassification", UnitFramesImproved_TargetFrame_CheckClassification);
	hooksecurefunc("TargetofTarget_Update", UnitFramesImproved_TargetFrame_Update);
	-- Hook FocusFrame functions
	hooksecurefunc("FocusFrame_CheckDead", UnitFramesImproved_FocusFrame_Update);
	hooksecurefunc("FocusFrame_Update", UnitFramesImproved_FocusFrame_Update);
	hooksecurefunc("FocusFrame_OnUpdate", UnitFramesImproved_FocusFrame_Update);
	--hooksecurefunc("FocusFrame_OnUpdate", UnitFramesImproved_FocusFrame_Update);
	hooksecurefunc("FocusFrame_CheckFaction", UnitFramesImproved_FocusFrame_CheckFaction);
	hooksecurefunc("FocusFrame_CheckClassification", UnitFramesImproved_FocusFrame_CheckClassification);
	--hooksecurefunc("FocusofTarget_Update", UnitFramesImproved_FocusFrame_Update);
	
	-- BossFrame hooks
	--hooksecurefunc("BossTargetFrame_OnLoad", UnitFramesImproved_BossTargetFrame_Style);

	-- Setup relative layout for targetframe compared to PlayerFrame
	if not TargetFrame:IsUserPlaced() then
		if not InCombatLockdown() then 
			TargetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPRIGHT", 36, 0);
		end
	end
	
	-- Set up some stylings
	UnitFramesImproved_Style_PlayerFrame();
	--UnitFramesImproved_BossTargetFrame_Style(Boss1TargetFrame);
	--UnitFramesImproved_BossTargetFrame_Style(Boss2TargetFrame);
	--UnitFramesImproved_BossTargetFrame_Style(Boss3TargetFrame);
	--UnitFramesImproved_BossTargetFrame_Style(Boss4TargetFrame);
	UnitFramesImproved_Style_TargetFrame(TargetFrame);
	UnitFramesImproved_Style_TargetFrame(FocusFrame);
	UnitFramesImproved_Style_TargetOfTargetFrame();
	UnitFramesImproved_Style_TargetOfFocusFrame();
	-- Update some values
	TextStatusBar_UpdateTextString(PlayerFrame.healthbar);
	TextStatusBar_UpdateTextString(PlayerFrame.manabar);

	-- Dark mode and flat textures
	UnitFramesImproved_DarkMode();
	--UnitFramesImproved_HealthBarTexture(FLAT_TEXTURE);

	PlayerName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
	TargetName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
	FocusName:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");

	--PlayerFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE');
	--PlayerFrameManaBarText:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE');
	--PetFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE');
	--PetFrameManaBarText:SetFont(STANDARD_TEXT_FONT, 11, 'OUTLINE');

end

function UnitFramesImproved_Style_TargetOfTargetFrame()
	if not InCombatLockdown() then 
		TargetofTargetHealthBar.lockColor = true;
		TargetofTargetFrame.portrait:SetPoint("CENTER",20,0);
	end
end

function UnitFramesImproved_Style_TargetOfFocusFrame()
	if not InCombatLockdown() then 
		TargetofFocusHealthBar.lockColor = true;
		TargetofFocusFrame.portrait:SetPoint("CENTER",20,0);
	end
end

function UnitFramesImproved_ColorUpdate(self)
	--if this == PlayerFrameHealthBar then
		PlayerFrameHealthBar:SetStatusBarColor(UnitColor("player"));
	--else
	--	this.healthbar:SetStatusBarColor(UnitColor(this.healthbar.unit));
	--end
end

function UnitFramesImproved_Style_PlayerFrame()
	if not InCombatLockdown() then 
		PlayerFrameHealthBar.lockColor = true;
		PlayerFrameHealthBar.capNumericDisplay = true;
		PlayerFrameHealthBar:SetWidth(119);
		PlayerFrameHealthBar:SetHeight(29);
		PlayerFrameHealthBar:SetPoint("TOPLEFT",106,-22);
		PlayerFrameHealthBarText:SetPoint("CENTER",50,6);
	end
	
	PlayerFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame");
	PlayerStatusTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-Player-Status");
	PlayerFrameHealthBar:SetStatusBarColor(UnitColor("player"));
end

function UnitFramesImproved_Style_TargetFrame(self)
	--if not InCombatLockdown() then
		local classification = UnitClassification("target");
		if (classification == "minus") then
			TargetFrameHealthBar:SetHeight(12);
			TargetFrameHealthBar:SetPoint("TOPLEFT",6,-41); -- 7

			TargetFrameManaBar:SetPoint("TOPLEFT",6,-51);

			TargetFrameHealthBar.TextString:SetPoint("CENTER",-50,4);
			TargetDeadText:SetPoint("CENTER",-50,4);
			--TargetFrameNameBackground:SetPoint("TOPLEFT",7,-41);
			TargetFrameNameBackground:Hide();
		else
			TargetFrameHealthBar:SetHeight(29);
			TargetFrameHealthBar:SetPoint("TOPLEFT",6,-22);

			TargetFrameManaBar:SetPoint("TOPLEFT",6,-51);

			TargetFrameHealthBar.TextString:SetPoint("CENTER",-50,6);
			TargetDeadText:SetPoint("CENTER",-50,6);
			TargetFrameNameBackground:Hide();
			--TargetFrameNameBackground:SetPoint("TOPLEFT",7,-22);
		end
		
		TargetFrameHealthBar:SetWidth(119);
		TargetFrameHealthBar.lockColor = true;
	--end
end

function UnitFramesImproved_Style_FocusFrame(self)
	--if not InCombatLockdown() then
		local classification = UnitClassification("focus");
		if (classification == "minus") then
			FocusFrameHealthBar:SetHeight(12);
			FocusFrameHealthBar:SetPoint("TOPLEFT",6,-41); -- 7

			FocusFrameManaBar:SetPoint("TOPLEFT",6,-51);

			FocusFrameHealthBar.TextString:SetPoint("CENTER",-50,4);
			FocusDeadText:SetPoint("CENTER",-50,4);
			--FocusFrameNameBackground:SetPoint("TOPLEFT",7,-41);
			FocusFrameNameBackground:Hide();
		else
			FocusFrameHealthBar:SetHeight(29);
			FocusFrameHealthBar:SetPoint("TOPLEFT",6,-22);

			FocusFrameManaBar:SetPoint("TOPLEFT",6,-51);

			FocusFrameHealthBar.TextString:SetPoint("CENTER",-50,6);
			FocusDeadText:SetPoint("CENTER",-50,6);
			FocusFrameNameBackground:Hide();
			--FocusFrameNameBackground:SetPoint("TOPLEFT",7,-22);
		end
		
		FocusFrameHealthBar:SetWidth(119);
		FocusFrameHealthBar.lockColor = true;
	--end
end

function UnitFramesImproved_BossTargetFrame_Style(self)
	self.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-UnitFrame-Boss");

	UnitFramesImproved_Style_TargetFrame(self);
	if (not (characterSettings["FrameScale"] == nil)) then
		if not InCombatLockdown() then 
			self:SetScale(characterSettings["FrameScale"] * 0.9);
		end
	end
end

function UnitFramesImproved_SetFrameScale(scale)
	if not InCombatLockdown() then 
		-- Scale the main frames
		PlayerFrame:SetScale(scale);
		TargetFrame:SetScale(scale);
		FocusFrame:SetScale(scale);
		
		-- Scale sub-frames
		ComboFrame:SetScale(scale); -- Still needed
		--RuneFrame:SetScale(scale); -- Can't do this as it messes up the scale horribly
		--RuneButtonIndividual1:SetScale(scale); -- No point in doing these either as the runeframes are now sacled to parent
		--RuneButtonIndividual2:SetScale(scale); -- No point in doing these either as the runeframes are now sacled to parent
		--RuneButtonIndividual3:SetScale(scale); -- No point in doing these either as the runeframes are now sacled to parent
		--RuneButtonIndividual4:SetScale(scale); -- No point in doing these either as the runeframes are now sacled to parent
		--RuneButtonIndividual5:SetScale(scale); -- No point in doing these either as the runeframes are now sacled to parent
		--RuneButtonIndividual6:SetScale(scale); -- No point in doing these either as the runeframes are now sacled to parent
		
		-- Scale the BossFrames, skip now as this seems to break
		-- Boss1TargetFrame:SetScale(scale*0.9);
		-- Boss2TargetFrame:SetScale(scale*0.9);
		-- Boss3TargetFrame:SetScale(scale*0.9);
		-- Boss4TargetFrame:SetScale(scale*0.9);
		
		characterSettings["FrameScale"] = scale;
	end
end

-- Slashcommand stuff
SLASH_UNITFRAMESIMPROVED1 = "/unitframesimproved";
SLASH_UNITFRAMESIMPROVED2 = "/ufi";
SlashCmdList["UNITFRAMESIMPROVED"] = function(msg, editBox)
	local tokens = tokenize(msg);
	if(table.getn(tokens) > 0 and strlower(tokens[1]) == "reset") then
		StaticPopup_Show("LAYOUT_RESET");
	elseif(table.getn(tokens) > 0 and strlower(tokens[1]) == "settings") then
		InterfaceOptionsFrame_OpenToCategory(UnitFramesImproved.panelSettings);
	elseif(table.getn(tokens) > 0 and strlower(tokens[1]) == "scale") then
		if(table.getn(tokens) > 1) then
			UnitFramesImproved_SetFrameScale(tokens[2]);
		else
			dout("Please supply a number, between 0.0 and 10.0 as the second parameter.");
		end
	else
		dout("Valid commands for UnitFramesImproved are:")
		dout("    help    (shows this message)");
		dout("    scale # (scales the player frames)");
		dout("    reset   (resets the scale of the player frames)");
		dout("");
	end
end

-- Setup the static popup dialog for resetting the UI
StaticPopupDialogs["LAYOUT_RESET"] = {
	text = "Are you sure you want to reset your scale?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		UnitFramesImproved_LoadDefaultSettings();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

StaticPopupDialogs["LAYOUT_RESETDEFAULT"] = {
	text = "In order for UnitFramesImproved to work properly,\nyour old layout settings need to be reset.\nThis will reload your UI.",
	button1 = "Reset",
	button2 = "Ignore",
	OnAccept = function()
		PlayerFrame:SetUserPlaced(false);
		ReloadUI();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true
}

function UnitFramesImproved_TextStatusBar_UpdateTextStringWithValues(textStatusBar)
	if ( not textStatusBar ) then
		textStatusBar = this;
	end
	local textString = textStatusBar.TextString;
	if(textString) then
		local value = textStatusBar:GetValue();
		local valueMin, valueMax = textStatusBar:GetMinMaxValues();

		if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( textStatusBar.pauseUpdates ) ) then
			textStatusBar:Show();
			if ( value and valueMax > 0 and ( GetCVar("statusTextPercentage") == "1" or textStatusBar.showPercentage ) ) then
				if ( value == 0 and textStatusBar.zeroText ) then
					textString:SetText(textStatusBar.zeroText);
					textStatusBar.isZero = 1;
					textString:Show();
					return;
				end
				value = tostring(math.ceil((value / valueMax) * 100)) .. "%";
				if ( textStatusBar.prefix and (textStatusBar.alwaysPrefix or not (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) ) ) then
					textString:SetText(textStatusBar.prefix .. " " .. value);
				else
					textString:SetText(value);
				end
			elseif ( value == 0 and textStatusBar.zeroText ) then
				textString:SetText(textStatusBar.zeroText);
				textStatusBar.isZero = 1;
				textString:Show();
				return;
			else
				textStatusBar.isZero = nil;
				if ( textStatusBar.prefix and (textStatusBar.alwaysPrefix or not (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) ) ) then
					textString:SetText(textStatusBar.prefix.." "..value.." / "..valueMax);
				else
					textString:SetText(value.." / "..valueMax);
				end
			end
			
			if ( (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) or textStatusBar.forceShow ) then
				textString:Show();
			elseif ( textStatusBar.lockShow > 0 ) then
				textString:Show();
			else
				textString:Hide();
			end
		else
			textString:Hide();
			textStatusBar:Hide();
		end
	end
end

function UnitFramesImproved_PlayerFrame_ToPlayerArt(self)
	if not InCombatLockdown() then
		UnitFramesImproved_Style_PlayerFrame();
	end
end

function UnitFramesImproved_PlayerFrame_ToVehicleArt(self)
	if not InCombatLockdown() then
		PlayerFrameHealthBar:SetHeight(12);
		PlayerFrameHealthBarText:SetPoint("CENTER",50,3);
	end
end

function UnitFramesImproved_TargetFrame_Update(self)
	-- Set back color of health bar
	if ( not UnitPlayerControlled("target") and UnitIsTapped("target") and not UnitIsTappedByPlayer("target") ) then
		-- Gray if npc is tapped by other player
		this.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
	else
		-- Standard by class etc if not
		this.healthbar:SetStatusBarColor(UnitColor(this.healthbar.unit));
	end
end

function UnitFramesImproved_FocusFrame_Update(self)
	-- Set back color of health bar
	if ( not UnitPlayerControlled("focus") and UnitIsTapped("focus") and not UnitIsTappedByPlayer("focus") ) then
		-- Gray if npc is tapped by other player
		this.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
	else
		-- Standard by class etc if not
		this.healthbar:SetStatusBarColor(UnitColor(this.healthbar.unit));
	end
end

function UnitFramesImproved_TargetFrame_CheckClassification()

	local classification = UnitClassification("target");
		if ( classification == "worldboss" ) then
			TargetFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Elite");
		elseif ( classification == "rareelite"  ) then
			TargetFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Rare-Elite");
		elseif ( classification == "elite"  ) then
			TargetFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Elite");
		elseif ( classification == "rare"  ) then
			TargetFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Rare");
		else
			TargetFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame");
		end
end

function UnitFramesImproved_FocusFrame_CheckClassification()

	local classification = UnitClassification("focus");
		if ( classification == "worldboss" ) then
			FocusFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Elite");
		elseif ( classification == "rareelite"  ) then
			FocusFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Rare-Elite");
		elseif ( classification == "elite"  ) then
			FocusFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Elite");
		elseif ( classification == "rare"  ) then
			FocusFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame-Rare");
		else
			FocusFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved_TBC\\Textures\\UI-TargetingFrame");
		end
end

function UnitFramesImproved_TargetFrame_CheckFaction(self)
	local factionGroup = UnitFactionGroup("target");
	--dout(UnitClass("target")); -- For debug purpose
	if ( UnitIsPVPFreeForAll("target") ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		TargetPVPIcon:Show();
	elseif ( factionGroup and UnitIsPVP(this.unit) and UnitIsEnemy("player", this.unit) ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		TargetPVPIcon:Show();
	elseif ( factionGroup == "Alliance" or factionGroup == "Horde" ) then
		TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		TargetPVPIcon:Show();
	else
		TargetPVPIcon:Hide();
	end
	
	UnitFramesImproved_Style_TargetFrame(this.unit);
end

function UnitFramesImproved_FocusFrame_CheckFaction(self)
	local factionGroup = UnitFactionGroup("focus");
	--dout(UnitClass("focus")); -- For debug purpose
	if ( UnitIsPVPFreeForAll("focus") ) then
		FocusPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		FocusPVPIcon:Show();
	elseif ( factionGroup and UnitIsPVP(this.unit) and UnitIsEnemy("player", this.unit) ) then
		FocusPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
		FocusPVPIcon:Show();
	elseif ( factionGroup == "Alliance" or factionGroup == "Horde" ) then
		FocusPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
		FocusPVPIcon:Show();
	else
		FocusPVPIcon:Hide();
	end
	
	UnitFramesImproved_Style_FocusFrame(this.unit);
end

-- Utility functions
function UnitColor(unit)
	local r, g, b;
	local sr, sg, sb = TargetFrameNameBackground:GetVertexColor();

	local localizedClass, englishClass = UnitClass(unit);
	local classColor = RAID_CLASS_COLORS[englishClass];

	--DEBUG MSG
	--DEFAULT_CHAT_FRAME:AddMessage(UnitClass(unit));

	if ( ( not UnitIsPlayer(unit) ) and ( ( not UnitIsConnected(unit) ) or ( UnitIsDeadOrGhost(unit) ) ) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	elseif ( UnitIsPlayer(unit) ) then
		--Try to color it by class.
		
		if ( classColor ) then
			r, g, b = classColor.r, classColor.g, classColor.b;
		else
			if ( UnitIsFriend("player", unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
				--DEFAULT_CHAT_FRAME:AddMessage(UnitClass("I PUT GREEN"));
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	else -- IF NPC COLOR IT HERE!
		--if ( classColor ) then
		--	r, g, b = classColor.r, classColor.g, classColor.b;
		--else 
		--	r, g, b = 0, 1, 0;
		--end

		r, g, b = sr, sg, sb;
	end
	
	return r, g, b;
end

function FocusColor(unit)
	local r, g, b;
	local sr, sg, sb = FocusFrameNameBackground:GetVertexColor();

	local localizedClass, englishClass = UnitClass(unit);
	local classColor = RAID_CLASS_COLORS[englishClass];

	--DEBUG MSG
	--DEFAULT_CHAT_FRAME:AddMessage(UnitClass(unit));

	if ( ( not UnitIsPlayer(unit) ) and ( ( not UnitIsConnected(unit) ) or ( UnitIsDeadOrGhost(unit) ) ) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	elseif ( UnitIsPlayer(unit) ) then
		--Try to color it by class.
		
		if ( classColor ) then
			r, g, b = classColor.r, classColor.g, classColor.b;
		else
			if ( UnitIsFriend("player", unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
				--DEFAULT_CHAT_FRAME:AddMessage(UnitClass("I PUT GREEN"));
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	else -- IF NPC COLOR IT HERE!
		--if ( classColor ) then
		--	r, g, b = classColor.r, classColor.g, classColor.b;
		--else 
		--	r, g, b = 0, 1, 0;
		--end

		r, g, b = sr, sg, sb;
	end
	
	return r, g, b;
end

--------------------------------------------------------------------
-- Not being used but left it for future purposes
function UnitFramesImproved_AbbreviateLargeNumbers(value)
	local strLen = strlen(value);
	local retString = value;
	if (true) then
		if ( strLen >= 10 ) then
			retString = string.sub(value, 1, -10).."."..string.sub(value, -9, -9).."G";
		elseif ( strLen >= 7 ) then
			retString = string.sub(value, 1, -7).."."..string.sub(value, -6, -6).."M";
		elseif ( strLen >= 4 ) then
			retString = string.sub(value, 1, -4).."."..string.sub(value, -3, -3).."k";
		end
	else
		if ( strLen >= 10 ) then
			retString = string.sub(value, 1, -10).."G";
		elseif ( strLen >= 7 ) then
			retString = string.sub(value, 1, -7).."M";
		elseif ( strLen >= 4 ) then
			retString = string.sub(value, 1, -4).."k";
		end
	end
	return retString;
end

-- Bootstrap
function UnitFramesImproved_StartUp(self) 
	self:SetScript('OnEvent', function(self, event) self[event](self) end);
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
	self:RegisterEvent('VARIABLES_LOADED');
end

UnitFramesImproved_StartUp(UnitFramesImproved);

-- Table Dump Functions -- http://lua-users.org/wiki/TableSerialization
function print_r (t, indent, done)
  done = done or {}
  indent = indent or ''
  local nextIndent -- Storage for next indentation value
  for key, value in pairs (t) do
    if type (value) == "table" and not done [value] then
      nextIndent = nextIndent or
          (indent .. string.rep(' ',string.len(tostring (key))+2))
          -- Shortcut conditional allocation
      done [value] = true
      print (indent .. "[" .. tostring (key) .. "] => Table {");
      print  (nextIndent .. "{");
      print_r (value, nextIndent .. string.rep(' ',2), done)
      print  (nextIndent .. "}");
    else
      print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
    end
  end
end

function UnitFramesImproved_DarkMode()
	-- Dark borders UI, code from modUI
	for _, v in pairs({
			-- MINIMAP CLUSTER
		--MinimapBorder,
		--MiniMapMailBorder,
		--MiniMapTrackingBorder,
		--MiniMapMeetingStoneBorder,
		--MiniMapMailBorder,
		--MiniMapBattlefieldBorder,
			-- UNIT & CASTBAR
		--PlayerFrameTexture,
		--TargetFrameTexture,
		PetFrameTexture,
		PartyMemberFrame1Texture,
		PartyMemberFrame2Texture,
		PartyMemberFrame3Texture,
		PartyMemberFrame4Texture,
		PartyMemberFrame1PetFrameTexture,
		PartyMemberFrame2PetFrameTexture,
		PartyMemberFrame3PetFrameTexture,
		PartyMemberFrame4PetFrameTexture,
		TargetofTargetTexture,
		TargetofFocusTexture,
		--CastingBarBorder,

		--[[
			-- MAIN MENU BAR
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuMaxLevelBar0,
		MainMenuMaxLevelBar1,
		MainMenuMaxLevelBar2,
		MainMenuMaxLevelBar3,
		MainMenuXPBarTextureLeftCap,
		MainMenuXPBarTextureRightCap,
		MainMenuXPBarTextureMid,
		BonusActionBarTexture0,
		BonusActionBarTexture1,
		ReputationWatchBarTexture0,
		ReputationWatchBarTexture1,
		ReputationWatchBarTexture2,
		ReputationWatchBarTexture3,
		ReputationXPBarTexture0,
		ReputationXPBarTexture1,
		ReputationXPBarTexture2,
		ReputationXPBarTexture3,
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		MainMenuBarLeftEndCap,
		MainMenuBarRightEndCap,
		ExhaustionTick:GetNormalTexture(),
		]]

	})	do 
		v:SetVertexColor(UNITFRAMESIMPROVED_UI_COLOR.r, UNITFRAMESIMPROVED_UI_COLOR.g, UNITFRAMESIMPROVED_UI_COLOR.b)
	end
end

function UnitFramesImproved_HealthBarTexture(NAME_TEXTURE)
	PlayerFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
	PlayerFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
	TargetFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
	TargetFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
	FocusFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
	FocusFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
	PetFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
	PetFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
	TargetofTargetHealthBar:SetStatusBarTexture(NAME_TEXTURE)
	TargetofTargetManaBar:SetStatusBarTexture(NAME_TEXTURE)
	TargetofFocusHealthBar:SetStatusBarTexture(NAME_TEXTURE)
	TargetofFocusManaBar:SetStatusBarTexture(NAME_TEXTURE)
	--Add party frames
end
