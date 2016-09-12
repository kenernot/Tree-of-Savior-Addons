--[[
Excrulon was here
]]

_G["MAP_MON_MINIMAP"] = MAP_MON_MINIMAP_HOOKED;

function MAP_MON_MINIMAP_HOOKED(frame, msg, argStr, argNum, info)
	local isMinimap = false;
	if frame:GetTopParentFrame():GetName() == "minimap" then
		frame = GET_CHILD(frame, 'npclist', 'ui::CGroupBox');
		isMinimap = true;
	end

	local ctrlName = "_MONPOS_" .. info.handle;
	local monPic = frame:GetChild(ctrlName);
	if monPic ~= nil then
		MAP_MON_MINIMAP_SETPOS(frame, info);
		return;
	end

	local mapprop = session.GetCurrentMapProp();

	local isPC = info.type == 0;
	local monCls = nil;
	if false == isPC then
		monCls = GetClassByType("Monster", info.type);
	end

	local width;
	local height;
	if isPC then
		width = 40;
		height = 40;
	else
		if monCls.MonRank == "Boss" then
			width = 200;
			height = 200;
		else
			width = 40;
			height = 40;
		end
	end

	local ctrlName = "_MONPOS_" .. info.handle;
	monPic = frame:CreateOrGetControl('picture', ctrlName, 0, 0, width, height);
	tolua.cast(monPic, "ui::CPicture");
	if false == monPic:HaveUpdateScript("_MONPIC_AUTOUPDATE") then
		monPic:RunUpdateScript("_MONPIC_AUTOUPDATE", 0);
	end

	monPic:SetUserValue("W", width);
	monPic:SetUserValue("H", height);
	monPic:SetUserValue("HANDLE", info.handle);
	monPic:SetUserValue("EXTERN", "YES");
	monPic:SetUserValue("EXTERN_PIC", "YES");

	if isMinimap == true then
		local cursize = GET_MINIMAPSIZE();
		local dd = (100 + cursize) / 100;
		dd = 1 / dd;
		dd = CLAMP(dd, 0.5, 1.5);
		monPic:SetScale(dd, dd);
	end

	if isPC then
		monPic:SetEnableStretch(1);
		monPic:ShowWindow(1);

		local myTeam = GET_MY_TEAMID();
		local outLineColor;
		if myTeam == info.teamID then
			outLineColor = "CCFFFFFF";
		else
			outLineColor = "CCCC0000";
		end

		local imgName = GET_JOB_ICON(info.job);
		monPic:SetImage(imgName);
		monPic:ShowWindow(1);

	else
		if monCls.MonRank == "Boss" then
			--�ʵ庸�� ��ġ �˷��ִ°� �ּ�
			SET_PICTURE_QUESTMAP(monPic, 30);
			ctrlName = "_MONPOS_T_" .. info.handle;
			local textC = frame:CreateOrGetControl('richtext', ctrlName, 0, 0, width, height);
			tolua.cast(textC, "ui::CRichText");
			textC:SetTextAlign("center", "bottom");
			textC:SetText("{@st42_yellow}" .. ClMsg("FieldBossAppeared!") .. "{nl}{@st42}" .. monCls.Name);
			textC:ShowWindow(1);
			textC:SetUserValue("EXTERN", "YES");

			local mapName = mapprop:GetName();
			local currentChannel = session.loginInfo.GetChannel() + 1;

			CHAT_SYSTEM(monCls.Name .. " is in [" .. mapName .. "][" .. currentChannel .. "]");
		else
			local myTeam = GET_MY_TEAMID();
			if info.useIcon == true then
				monPic:SetImage(monCls.Icon);
			else
				if info.teamID == 0 then
					monPic:SetImage("fullyellow");
				elseif info.teamID ~= myTeam then
					monPic:SetImage("fullred");
				else
					monPic:SetImage("fullblue");
				end
			end

			monPic:SetEnableStretch(1);
			monPic:ShowWindow(1);
		end
	end

	MAP_MON_MINIMAP_SETPOS(frame, info);
end
