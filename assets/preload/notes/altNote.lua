local switch = {
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

local switch2 = {
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

local noteSing = switch[0]
local noteMiss = switch2[0]

function goodNoteHit()
    noteSing = switch[goodNoteData]
    if(noteSing) then
        noteSing()
    end
    giveHealth(0.023)
end

function noteMiss()
    noteMiss = switch2[missNoteData]
    drainHealth(0.04)
end