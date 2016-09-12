function LEAVEDUNGEON_ON_INIT(addon, frame)
	local acutil = require("acutil");

	acutil.slashCommand("/ld", LEAVE_DUNGEON);
	acutil.slashCommand("/leavedungeon", LEAVE_DUNGEON);
end

function LEAVE_DUNGEON()
	control.RequesDungeonLeave();
end
