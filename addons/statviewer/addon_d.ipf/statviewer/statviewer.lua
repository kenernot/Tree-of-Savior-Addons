--dofile("../data/addon_d/statviewer/statviewer.lua");

function STATVIEWER_ON_INIT(addon, frame)
	STATVIEWER_LOAD_SETTINGS();
	STATVIEWER_UPDATE(frame);

	addon:RegisterMsg("PC_PROPERTY_UPDATE", "STATVIEWER_UPDATE");

	_G["STATVIEWER"].isDragging = false;
	frame:SetEventScript(ui.LBUTTONDOWN, "STATVIEWER_START_DRAG");
	frame:SetEventScript(ui.LBUTTONUP, "STATVIEWER_END_DRAG");

	STATVIEWER_UPDATE_POSITION();
end

function STATVIEWER_START_DRAG()
	_G["STATVIEWER"].isDragging = true;
end

function STATVIEWER_END_DRAG()
	_G["STATVIEWER"].isDragging = false;
	STATVIEWER_SAVE_SETTINGS();
end

function STATVIEWER_LOAD_SETTINGS()
	_G["STATVIEWER"] = _G["STATVIEWER"] or {};
	local acutil = require("acutil");
	local settings, error = acutil.loadJSON("../addons/statviewer/settings.json");

	if error then
		STATVIEWER_SAVE_SETTINGS();
	else
		_G["STATVIEWER"]["settings"] = settings;
	end
end

function STATVIEWER_SAVE_SETTINGS()
	_G["STATVIEWER"] = _G["STATVIEWER"] or {};

	if _G["STATVIEWER"]["settings"] == nil then
		_G["STATVIEWER"]["settings"] = {
			x = STATVIEWER_GET_DEFAULT_X();
			y = STATVIEWER_GET_DEFAULT_Y()
		};
	else
		local frame = ui.GetFrame("statviewer");
		_G["STATVIEWER"]["settings"].x = frame:GetX();
		_G["STATVIEWER"]["settings"].y = frame:GetY();
	end

	local acutil = require("acutil");
	acutil.saveJSON("../addons/statviewer/settings.json", _G["STATVIEWER"]["settings"]);
end

function STATVIEWER_GET_DEFAULT_X()
	local frame = ui.GetFrame("statviewer");

	return (option.GetClientWidth() / 2);
end

function STATVIEWER_GET_DEFAULT_Y()
	local frame = ui.GetFrame("statviewer");

	return (option.GetClientHeight() / 2);
end

function STATVIEWER_UPDATE_POSITION()
	local frame = ui.GetFrame("statviewer");

	if frame ~= nil and not _G["STATVIEWER"].isDragging then
		frame:SetOffset(_G["STATVIEWER"]["settings"].x, _G["STATVIEWER"]["settings"].y);
	end
end

function STATVIEWER_UPDATE(frame)
	local pc = GetMyPCObject();

	local elementalAttack = STATVIEWER_CALCULATE_ELEMENTAL_ATTACK(pc);

	local dimensions = STATVIEWER_GET_DIMENSIONS();

	--frame, statName, statString, yPosition
	STATVIEWER_UPDATE_STAT(frame, "PATK", "PATK: " .. pc["MINPATK"] .. "~" .. pc["MAXPATK"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "MATK", "MATK: " .. pc["MINMATK"] .. "~" .. pc["MAXMATK"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "MHR", "MAMP: " .. pc["MHR"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "EATK", "EATK: " .. elementalAttack, dimensions);
	STATVIEWER_UPDATE_STAT(frame, "DEF", "PDEF: " .. pc["DEF"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "MDEF", "MDEF: " .. pc["MDEF"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "MSPD", "MSPD: " .. pc["MSPD"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "RHP", "HP REC: " .. pc["RHP"], dimensions);
	STATVIEWER_UPDATE_STAT(frame, "RSP", "SP REC: " .. pc["RSP"], dimensions);

	frame:Resize(dimensions.width, dimensions.height);
	STATVIEWER_UPDATE_POSITION();
end

function STATVIEWER_GET_DIMENSIONS()
	local dimensions = {};

	dimensions.x = 5;
	dimensions.y = 5;
	dimensions.width = 0;
	dimensions.height = 0;

	return dimensions;
end

function STATVIEWER_CALCULATE_ELEMENTAL_ATTACK(pc)
	local elementalAttack = 0;

	elementalAttack = elementalAttack + pc["Fire_Atk"];
	elementalAttack = elementalAttack + pc["Ice_Atk"];
	elementalAttack = elementalAttack + pc["Lightning_Atk"];
	elementalAttack = elementalAttack + pc["Earth_Atk"];
	elementalAttack = elementalAttack + pc["Poison_Atk"];
	elementalAttack = elementalAttack + pc["Holy_Atk"];
	elementalAttack = elementalAttack + pc["Dark_Atk"];

	return elementalAttack;
end

function STATVIEWER_UPDATE_STAT(frame, statName, statString, dimensions)
	local statRichText = frame:CreateOrGetControl("richtext", statName .. "_text", dimensions.x, dimensions.y, 100, 25);
	tolua.cast(statRichText, "ui::CRichText");
	statRichText:SetGravity(ui.LEFT, ui.TOP);
	statRichText:SetTextAlign("left", "center");
	statRichText:SetText(statString);
	statRichText:SetFontName("white_16_ol");
	statRichText:EnableHitTest(0);
	statRichText:ShowWindow(1);

	dimensions.y = dimensions.y + (statRichText:GetHeight() - 7);

	if statRichText:GetWidth() > dimensions.width then
		dimensions.width = statRichText:GetWidth();
	end

	dimensions.height = dimensions.height + statRichText:GetHeight();
end
