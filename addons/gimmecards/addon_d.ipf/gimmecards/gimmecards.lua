function GIMMECARDS_ON_INIT(addon, frame)
	local acutil = require("acutil");

	acutil.slashCommand("/removecard", GIMMECARDS_REMOVE_CARD);
	acutil.slashCommand("/unequipcard", GIMMECARDS_REMOVE_CARD);

	acutil.slashCommand("/removecardtp", GIMMECARDS_REMOVE_CARD_TP);
	acutil.slashCommand("/unequipcardtp", GIMMECARDS_REMOVE_CARD_TP);
end

function GIMMECARDS_REMOVE_CARD(arg, useTP)
	local cardSlot = tonumber(table.remove(arg, 1));

	if cardSlot == nil or cardSlot < 1 or cardSlot > session.GetPcTotalJobGrade() then
		CHAT_SYSTEM("Invalid card slot! Please enter a value between 1 and " .. session.GetPcTotalJobGrade() .. ".");
		return;
	end

	if useTP ~= "1" then
		useTP = "0";
	end

	local removeCardFunction = string.format("_GIMMECARDS_REMOVE_CARD(%d, %d)", cardSlot - 1, useTP);

	if useTP == "0" then
		ui.MsgBox("Your card will lose experience! Are you sure you want to remove it?", removeCardFunction, "None");
	elseif useTP == "1" then
		ui.MsgBox("Your card will not lose experience at the cost of 5 TP! Are you sure you want to remove it?", removeCardFunction, "None");
	end
end

function GIMMECARDS_REMOVE_CARD_TP(arg)
	GIMMECARDS_REMOVE_CARD(arg, "1");
end

function _GIMMECARDS_REMOVE_CARD(cardSlot, useTP)
	local unequipParams = string.format("%s %s", cardSlot, useTP);
	pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", unequipParams);
end
