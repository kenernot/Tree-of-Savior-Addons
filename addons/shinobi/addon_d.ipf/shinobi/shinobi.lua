function SHINOBI_ON_INIT(addon, frame)
	_G["SHINOBI_STARTED"] = false;

	local acutil = require("acutil");

	acutil.slashCommand("/!shinobistart", SHINOBI_START);
	acutil.slashCommand("/!shinobistop", SHINOBI_STOP);
	acutil.slashCommand("/!shinobisetsms", SHINOBI_SET_SMS_NUMBER);
	acutil.slashCommand("/!shinobitest", SHINOBI_TEST_SMS);

	addon:RegisterMsg("FPS_UPDATE", "SHINOBI_UPDATE");

	CHAT_SYSTEM("Shinobi loaded!");
end

function SHINOBI_START()
	_G["SHINOBI_STARTED"] = true;
	CHAT_SYSTEM("Shinobi started!");
end

function SHINOBI_STOP()
	_G["SHINOBI_STARTED"] = false;
	CHAT_SYSTEM("Shinobi stopped!");
end

function SHINOBI_UPDATE(frame, msg, argStr, argNum)
	if not _G["SHINOBI_STARTED"] then
		return;
	end

	local mapClassName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapClassName);
	local mapName = dictionary.ReplaceDicIDInCompStr(mapprop:GetName());
	local currentChannel = session.loginInfo.GetChannel() + 1;

	if mapClassName ~= "f_orchard_34_1" then
		return;
	end

	local fndList, fndCount = SelectObject(GetMyPCObject(), 5000, 'ALL');

	for i = 1, fndCount do
		local className = fndList[i].ClassName;
		local classId = fndList[i].ClassID;

		if classId == 156040 or className == "npc_orchard_flower" then
			SHINOBI_SEND_SMS(mapName, currentChannel, fndList[i].ClassID, fndList[i].ClassName, fndList[i].Name);
			ui.Chat("/w PGN Found on channel " .. currentChannel .. "!");
		end
	end

	CHAT_SYSTEM("update!");
end

function SHINOBI_SEND_SMS(mapName, channel, classId, className, name)
	local smsNumber = _G["SHINOBI_SMS_NUMBER"];

	if smsNumber == nil or smsNumber == "" then
		return;
	end

	local socket = require("socket");

	if socket ~= nil then
		local message = string.format("number=%s&message=Found classId=[%s] className=[%s] name=[%s] on map=[%s] in channel=[%s]!",
			smsNumber,
			classId,
			className,
			name,
			mapName,
			channel
		);

		local host = "textbelt.com";
		local port = 80;
		local connection = socket.connect(host, port);

		if connection ~= nil then
			connection:send("POST /text HTTP/1.1\n");
			connection:send("Content-Type: application/x-www-form-urlencoded\n");
			connection:send("Accept: text/plain\n");
			connection:send("Host: " .. host .. "\n");
			connection:send("Content-Length: " .. string.len(message) .. "\n\n");
			connection:send(message);

			local line = connection:receive('*line');
			CHAT_SYSTEM("Status: " .. line);
			connection:close();
		end
	end
end

function SHINOBI_SET_SMS_NUMBER(params)
	local smsNumber = table.remove(params, 1);

	_G["SHINOBI_SMS_NUMBER"] = smsNumber;

	CHAT_SYSTEM("Number set to: " .. smsNumber);
end

function SHINOBI_TEST_SMS()
	local smsNumber = _G["SHINOBI_SMS_NUMBER"];

	if smsNumber == nil or smsNumber == "" then
		return;
	end

	local socket = require("socket");

	if socket ~= nil then
		local message = string.format("number=%s&message=Found item test!", smsNumber);

		local host = "textbelt.com";
		local port = 80;
		local connection = socket.connect(host, port);

		if connection ~= nil then
			connection:send("POST /text HTTP/1.1\n");
			connection:send("Content-Type: application/x-www-form-urlencoded\n");
			connection:send("Accept: text/plain\n");
			connection:send("Host: " .. host .. "\n");
			connection:send("Content-Length: " .. string.len(message) .. "\n\n");
			connection:send(message);

			local line = connection:receive('*line');
			CHAT_SYSTEM("Status: " .. line);
			connection:close();
		end
	end
end
