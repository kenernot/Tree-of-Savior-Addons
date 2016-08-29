function COMBATTIMER_ON_INIT(addon, frame)
	local acutil = require("acutil");
	acutil.setupHook(ON_GAMEEXIT_TIMER_START_HOOKED, "ON_GAMEEXIT_TIMER_START");

	addon:RegisterMsg("FPS_UPDATE", "COMBATTIMER_START_UPDATE");
 	addon:RegisterMsg("GAMEEXIT_TIMER_START", "COMBATTIMER_START");
	addon:RegisterMsg("GAMEEXIT_TIMER_UPDATE", "COMBATTIMER_UPDATE");
	addon:RegisterMsg("GAMEEXIT_TIMER_END", "COMBATTIMER_END");

	COMBATTIMER_UPDATE_TEXT(0);
end

function ON_GAMEEXIT_TIMER_START_HOOKED(frame, msg, time)
	local type = frame:GetUserValue("EXIT_TYPE");
	if type == "Exit"
		or type == "Logout"
		or type == "Barrack"
		or type == "Channel"
	then
		ON_GAMEEXIT_TIMER_START_OLD(frame, msg, time);
	else
		COMBATTIMER_UPDATE(frame, msg, time);
	end
end

function COMBATTIMER_START_UPDATE(frame, msg, argStr, argNum)
	RunGameExitTimer();
end

function COMBATTIMER_START(frame, msg, time)
	COMBATTIMER_UPDATE(frame, msg, time);
end

function COMBATTIMER_UPDATE(frame, msg, time)
	COMBATTIMER_UPDATE_TEXT(time);
end

function COMBATTIMER_END(frame, msg)
	COMBATTIMER_UPDATE_TEXT(0);
end

function COMBATTIMER_UPDATE_TEXT(time)
	local combatString = time;

	if tonumber(time) > 0 then
		combatString = string.format("{%s}{ol}%s{/}{/}", "#FF0000", "IN COMBAT! " .. time);
	else
		combatString = string.format("{%s}{ol}%s{/}{/}", "#00FF00", "NOT IN COMBAT!");
	end

	local combatTimerFrame = ui.GetFrame("combattimer");

	if combatTimerFrame ~= nil then

		local combatTimerRichText = combatTimerFrame:CreateOrGetControl("richtext", "combatTimerRichText", 5, 5, 100, 25);
		tolua.cast(combatTimerRichText, "ui::CRichText");

		if combatTimerRichText ~= nil then
			combatTimerRichText:SetGravity(ui.LEFT, ui.TOP);
			combatTimerRichText:SetTextAlign("left", "center");
			combatTimerRichText:SetText(combatString);
			combatTimerRichText:EnableHitTest(0);
			combatTimerRichText:ShowWindow(1);

			combatTimerFrame:Resize(combatTimerRichText:GetWidth() + 5, combatTimerRichText:GetHeight() + 5);
		end

		combatTimerFrame:ShowWindow(1);
	end
end
