local bfSwitch = {
    [0] = function()
        playActorAnimation("boyfriend", "singLEFT-alt")
    end,
	[1] = function()
        playActorAnimation("boyfriend", "singDOWN-alt")
	end,
	[2] = function()
        playActorAnimation("boyfriend", "singUP-alt")
	end,
	[3] = function()
        playActorAnimation("boyfriend", "singRIGHT-alt")
	end
}

local bfMissSwitch = {
    [0] = function()
        playActorAnimation("boyfriend", "singLEFTmiss")
    end,
	[1] = function()
        playActorAnimation("boyfriend", "singDOWNmiss")
	end,
	[2] = function()
        playActorAnimation("boyfriend", "singUPmiss")
	end,
	[3] = function()
        playActorAnimation("boyfriend", "singRIGHTmiss")
	end
}

local cpuSwitch = {
    [0] = function()
        playActorAnimation("opponent", "singLEFT-alt")
    end,
	[1] = function()
        playActorAnimation("opponent", "singDOWN-alt")
	end,
	[2] = function()
        playActorAnimation("opponent", "singUP-alt")
	end,
	[3] = function()
        playActorAnimation("opponent", "singRIGHT-alt")
	end
}

local cpuMissSwitch = {
    [0] = function()
        playActorAnimation("opponent", "singLEFTmiss")
    end,
	[1] = function()
        playActorAnimation("opponent", "singDOWNmiss")
	end,
	[2] = function()
        playActorAnimation("opponent", "singUPmiss")
	end,
	[3] = function()
        playActorAnimation("opponent", "singRIGHTmiss")
	end
}

local noteSing = bfSwitch[0]
local noteMiss = bfMissSwitch[0]

function goodNoteHit(noteData, isSustainNote, mustPress, noteType)
    if noteType == "altNote" then
        if mustPress then
            noteSing = bfSwitch[noteData]
            if(noteSing) then
                noteSing()
            end
            giveHealth(0.023)
        else
            noteSing = cpuSwitch[noteData]
            if(noteSing) then
                noteSing()
            end
        end
    end
end

function noteMiss(noteData, isSustainNote, mustPress, noteType)
    if noteType == "altNote" then
        if mustPress then
            noteMiss = bfMissSwitch[noteData]
            if(noteMiss) then
                noteMiss()
            end
            drainHealth(0.04)
        else
            noteMiss = cpuMissSwitch[noteData]
            if(noteMiss) then
                noteMiss()
            end
        end
    end
end