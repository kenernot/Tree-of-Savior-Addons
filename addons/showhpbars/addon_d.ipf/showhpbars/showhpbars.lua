function SHOWHPBARS_ON_INIT(addon, frame)
	local acutil = require("acutil");

	acutil.slashCommand("/!showhpbars", SHOW_HP_BARS);
end

function SHOW_HP_BARS()
	local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 100000, 'ALL');

	for i = 1, selectedObjectsCount do
		local handle = GetHandle(selectedObjects[i]);

		local frame = ui.GetFrame("monb_" .. handle);

		if frame ~= nil then
			frame:ShowWindow(1);

			local hpGauge = GET_CHILD(frame, "hp", "ui::CGauge");

			if hpGauge ~= nil then
				hpGauge:ShowWindow(1);

				local targetInfo = info.GetTargetInfo(handle);

				if targetInfo ~= nil then
					local stat = targetInfo.stat;

					if stat ~= nil then
						if stat.HP ~= hpGauge:GetCurPoint() or stat.maxHP ~= hpGauge:GetMaxPoint() then
							hpGauge:SetPoint(stat.HP, stat.maxHP);
							hpGauge:StopTimeProcess();
						else
							hpGauge:SetMaxPointWithTime(stat.HP, stat.maxHP, 0.2, 0.4);
						end
					end
				end
			end
		end
	end
end
