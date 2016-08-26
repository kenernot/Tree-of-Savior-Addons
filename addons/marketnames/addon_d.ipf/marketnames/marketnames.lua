--dofile("../data/addon_d/marketnames/marketnames.lua");

function MARKETNAMES_ON_INIT(addon, frame)
	local acutil = require("acutil");
	acutil.setupHook(ON_MARKET_ITEM_LIST_SELLER_HOOKED, "ON_MARKET_ITEM_LIST");

	addon:RegisterMsg("GAME_START_3SEC", "MARKETNAMES_LOAD");
	addon:RegisterMsg("FPS_UPDATE", "MARKETNAMES_UPDATE");
end

function MARKETNAMES_LOAD()
	_G["MARKETNAMES_PREVIOUS_SERVER_ID"] = _G["MARKETNAMES_CURRENT_SERVER_ID"];
	_G["MARKETNAMES_CURRENT_SERVER_ID"] = MARKETNAMES_GET_SERVER_ID();

	if _G["MARKETNAMES_CURRENT_SERVER_ID"] ~= _G["MARKETNAMES_PREVIOUS_SERVER_ID"] then
		_G["MARKETNAMES"] = nil;
	end

	if _G["MARKETNAMES"] ~= nil then
		return;
	end

	_G["MARKETNAMES"] = {};

	for line in io.lines(MARKETNAMES_GET_FILENAME()) do
		local cid, fullName = line:match("([^=]+)=([^=]+)");

		local marketName = _G["MARKETNAMES"][cid];

		if marketName == nil then
			local characterName, familyName = MARKETNAMES_SPLIT_NAME(fullName);

			marketName = {};
			marketName.characterName = characterName;
			marketName.familyName = familyName;

			_G["MARKETNAMES"][cid] = marketName;
		end
	end
end

function MARKETNAMES_SAVE()
	local file, error = io.open(MARKETNAMES_GET_FILENAME(), "w");

	if error then
		CHAT_SYSTEM("Failed to write marketnames file!");
		return;
	end

	for k,v in pairs(_G["MARKETNAMES"]) do
		file:write(k .. "=" .. v.characterName .. " " .. v.familyName .. "\n");
	end

	file:flush();
	file:close();
end

function MARKETNAMES_SPLIT_NAME(fullName)
	local characterName, familyName = "";
	local tokenCount = 1;

	for token in string.gmatch(fullName, "%S+") do
		if tokenCount == 1 then
			characterName = token;
		elseif tokenCount == 2 then
			familyName = token;
		end

		tokenCount = tokenCount + 1;
	end

	return characterName, familyName;
end

function MARKETNAMES_UPDATE(frame, msg, argStr, argNum)
	MARKETNAMES_LOAD();

	local addedName = false;
	local selectedObjects, selectedObjectsCount = SelectObject(GetMyPCObject(), 1000000, 'ALL');

	for i = 1, selectedObjectsCount do
		local handle = GetHandle(selectedObjects[i]);

		if handle ~= nil then
			if info.IsPC(handle) == 1 then
				local cid = info.GetCID(handle);
				local marketName = _G["MARKETNAMES"][cid];
				local characterName = info.GetName(handle);
				local familyName = info.GetFamilyName(handle);

				if marketName == nil then
					marketName = {};
					marketName.characterName = characterName;
					marketName.familyName = familyName;
					_G["MARKETNAMES"][cid] = marketName;
					addedName = true;
				end
			end
		end
	end

	if addedName then
		MARKETNAMES_SAVE();
	end
end

function MARKETNAMES_GET_SERVER_ID()
	local f = io.open('../release/user.xml', "rb");
	local content = f:read("*all");
	f:close();
	return content:match('RecentServer="(.-)"');
end

function MARKETNAMES_GET_FILENAME()
	return "../addons/marketnames/marketnames-" .. MARKETNAMES_GET_SERVER_ID() .. ".txt";
end

function MARKETNAMES_PRINT()
	local total = 0;

	for k,v in pairs(_G["MARKETNAMES"]) do
		print(k .. "=" .. v.characterName .. " " .. v.familyName);
		total = total + 1;
	end

	print(total);
end

function ON_MARKET_ITEM_LIST_SELLER_HOOKED(frame, msg, argStr, argNum)
	if frame:IsVisible() == 0 then
		return;
	end

	local itemlist = GET_CHILD(frame, "itemlist", "ui::CDetailListBox");
	itemlist:RemoveAllChild();
	local mySession = session.GetMySession();
	local cid = mySession:GetCID();

	local count = session.market.GetItemCount();
	for i = 0 , count - 1 do
		local marketItem = session.market.GetItemByIndex(i);
		local itemObj = GetIES(marketItem:GetObject());
		local refreshScp = itemObj.RefreshScp;
		if refreshScp ~= "None" then
			refreshScp = _G[refreshScp];
			refreshScp(itemObj);
		end

		local ctrlSet = INSERT_CONTROLSET_DETAIL_LIST(itemlist, i, 0, "market_item_detail");
		ctrlSet = tolua.cast(ctrlSet, "ui::CControlSet");
		ctrlSet:EnableHitTestSet(1);
		ctrlSet:SetUserValue("DETAIL_ROW", i);

		SET_ITEM_TOOLTIP_ALL_TYPE(ctrlSet, marketItem, itemObj.ClassName, "market", marketItem.itemType, marketItem:GetMarketGuid());

		local pic = GET_CHILD(ctrlSet, "pic", "ui::CPicture");
		pic:SetImage(itemObj.Icon);

		local name = ctrlSet:GetChild("name");
		name:SetTextByKey("value", GET_FULL_NAME(itemObj));

		local count = ctrlSet:GetChild("count");
		count:SetTextByKey("value", marketItem.count);

		local level = ctrlSet:GetChild("level");
		level:SetTextByKey("value", itemObj.UseLv);

		local price = ctrlSet:GetChild("price");
		price:SetTextByKey("value", GetCommaedText(marketItem.sellPrice));
		price:SetUserValue("Price", marketItem.sellPrice);

		if marketItem ~= nil then
			if _G["MARKETNAMES"] ~= nil then
				local marketName = _G["MARKETNAMES"][marketItem:GetSellerCID()];

				if marketName ~= nil then
					local buyButton = ctrlSet:GetChild("button_1");

					if buyButton ~= nil then
						buyButton:SetTextTooltip("Buy from " .. marketName.characterName .. " " .. marketName.familyName .. "!");
					end
				end
			end
		end

		if cid == marketItem:GetSellerCID() then
			local button_1 = ctrlSet:GetChild("button_1");
			button_1:SetEnable(0);

			local btnmargin = 639
			if USE_MARKET_REPORT == 1 then
				local button_report = ctrlSet:GetChild("button_report");
				button_report:SetEnable(0);
				btnmargin = 720
			end

			local btn = ctrlSet:CreateControl("button", "DETAIL_ITEM_" .. i, btnmargin, 8, 100, 50);
			btn = tolua.cast(btn, "ui::CButton");
			btn:ShowWindow(1);
			btn:SetText("{@st41b}" .. ClMsg("Cancel"));
			btn:SetTextAlign("center", "center");

			if notUseAnim ~= true then
				btn:SetAnimation("MouseOnAnim", "btn_mouseover");
				btn:SetAnimation("MouseOffAnim", "btn_mouseoff");
			end
			btn:UseOrifaceRectTextpack(true)
			btn:SetEventScript(ui.LBUTTONUP, "CANCEL_MARKET_ITEM");
			btn:SetEventScriptArgString(ui.LBUTTONUP,marketItem:GetMarketGuid());
			btn:SetSkinName("test_pvp_btn");
			local totalPrice = ctrlSet:GetChild("totalPrice");
			totalPrice:SetTextByKey("value", 0);
		else
			local btnmargin = 639
			if USE_MARKET_REPORT == 1 then
				btnmargin = 560
			end
			local numUpDown = ctrlSet:CreateControl("numupdown", "DETAIL_ITEM_" .. i, btnmargin, 20, 100, 30);
			numUpDown = tolua.cast(numUpDown, "ui::CNumUpDown");
			numUpDown:SetFontName("white_18_ol");
			numUpDown:MakeButtons("btn_numdown", "btn_numup", "editbox");
			numUpDown:ShowWindow(1);
			numUpDown:SetMaxValue(marketItem.count);
			numUpDown:SetMinValue(1);
			numUpDown:SetNumChangeScp("MARKET_CHANGE_COUNT");
			numUpDown:SetClickSound('button_click_chat');
			numUpDown:SetNumberValue(1)

			local totalPrice = ctrlSet:GetChild("totalPrice");
				totalPrice:SetTextByKey("value", GetCommaedText(marketItem.sellPrice));
				totalPrice:SetUserValue("Price", marketItem.sellPrice);
		end
	end

	itemlist:RealignItems();
	GBOX_AUTO_ALIGN(itemlist, 10, 0, 0, false, true);

	local maxPage = math.ceil(session.market.GetTotalCount() / MARKET_ITEM_PER_PAGE);
	local curPage = session.market.GetCurPage();
	local pagecontrol = GET_CHILD(frame, 'pagecontrol', 'ui::CPageController')
	pagecontrol:SetMaxPage(maxPage);
	pagecontrol:SetCurPage(curPage);

	if nil ~= argNum and  argNum == 1 then
		MARGET_FIND_PAGE(frame, session.market.GetCurPage());
	end
end
