function MAP_OPEN_HOOKED(frame)
	_G["MAP_OPEN_OLD"](frame);
	DRAW_RED_FOG(frame);
end

function REVEAL_MAP_PICTURE_HOOKED(frame, mapName, info, i, forMinimap)
	_G["REVEAL_MAP_PICTURE_OLD"](frame, mapName, info, i, forMinimap);
	DRAW_RED_FOG(frame);
end

function MINIMAP_CHAR_UDT_HOOKED(frame, msg, argStr, argNum)
	_G["MINIMAP_CHAR_UDT_OLD"](frame, msg, argStr, argNum);
	DRAW_RED_FOG(frame);
end

function DRAW_RED_FOG(frame)
	HIDE_CHILD_BYNAME(frame, "_SAMPLE_");
	local offsetX, offsetY = GET_MAPFOG_PIC_OFFSET(frame);
	local mapPic = GET_CHILD(frame, "map", 'ui::CPicture');
	local mapZoom = math.abs((GET_MINIMAPSIZE() + 100) / 100);

	local list = session.GetMapFogList(session.GetMapName());
	local cnt = list:Count();
	for i = 0 , cnt - 1 do
		local tile = list:PtrAt(i);

		if tile.revealed == 0 then
			local name = string.format("_SAMPLE_%d", i);
			local tilePosX = (tile.x * mapZoom) + offsetX;
			local tilePosY = (tile.y * mapZoom) + offsetY;
			local tileWidth = math.ceil(tile.w * mapZoom);
			local tileHeight = math.ceil(tile.h * mapZoom);
			local pic = frame:CreateOrGetControl("picture", name, tilePosX, tilePosY, tileWidth, tileHeight);
			tolua.cast(pic, "ui::CPicture");
			pic:ShowWindow(1);
			pic:SetImage("fullred");
			pic:SetEnableStretch(1);
			pic:SetAlpha(30.0);
			pic:EnableHitTest(0);

			if tile.selected == 1 then
				pic:ShowWindow(0);
			end
		end
	end

	frame:Invalidate();
end

SETUP_HOOK(MAP_OPEN_HOOKED, "MAP_OPEN");
SETUP_HOOK(REVEAL_MAP_PICTURE_HOOKED, "REVEAL_MAP_PICTURE");
SETUP_HOOK(MINIMAP_CHAR_UDT_HOOKED, "MINIMAP_CHAR_UDT");

ui.SysMsg("Map Fog Viewer loaded!");
