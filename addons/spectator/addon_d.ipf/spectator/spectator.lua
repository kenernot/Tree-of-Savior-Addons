--dofile("../addons/spectator.lua");

function SPECTATOR_ON_INIT(addon, frame)
	local acutil = require("acutil");

	acutil.slashCommand("/!spectate", SPECTATOR_OPEN);
	acutil.slashCommand("/!spectator", SPECTATOR_OPEN);

	_G["SPECTATOR"] = _G["SPECTATOR"] or {};

	_G["SPECTATOR"].x = 0;
	_G["SPECTATOR"].y = 0;
	_G["SPECTATOR"].z = 0;

	_G["SPECTATOR"].moveAmount = 20;
end

function SPECTATOR_OPEN()
	ui.ToggleFrame("spectator");
end

function SPECTATOR_MOVE(xOffset, yOffset, zOffset)
	_G["SPECTATOR"].x = _G["SPECTATOR"].x + xOffset;
	_G["SPECTATOR"].y = _G["SPECTATOR"].y + yOffset;
	_G["SPECTATOR"].z = _G["SPECTATOR"].z + zOffset;

	local cameratime = 1.0;
	local motionratio = 1.0;

	camera.ChangeCamera(1, 0, _G["SPECTATOR"].x, _G["SPECTATOR"].y, _G["SPECTATOR"].z, cameratime, motionratio, 0);

	print(_G["SPECTATOR"].x .. " " .. _G["SPECTATOR"].y .. " " .. _G["SPECTATOR"].z);
end

function SPECTATOR_MOVE_LEFT()
	SPECTATOR_MOVE(-_G["SPECTATOR"].moveAmount, 0, -_G["SPECTATOR"].moveAmount);
end

function SPECTATOR_MOVE_RIGHT()
	SPECTATOR_MOVE(_G["SPECTATOR"].moveAmount, 0, _G["SPECTATOR"].moveAmount);
end

function SPECTATOR_MOVE_UP()
	SPECTATOR_MOVE(-_G["SPECTATOR"].moveAmount, 0, _G["SPECTATOR"].moveAmount);
end

function SPECTATOR_MOVE_DOWN()
	SPECTATOR_MOVE(_G["SPECTATOR"].moveAmount, 0, -_G["SPECTATOR"].moveAmount);
end

function SPECTATOR_ZOOM_IN()
	SPECTATOR_MOVE(0, -_G["SPECTATOR"].moveAmount, 0);
end

function SPECTATOR_ZOOM_OUT()
	SPECTATOR_MOVE(0, _G["SPECTATOR"].moveAmount, 0);
end
