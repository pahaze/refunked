local switch = {
    [0] = function()
        playActorAnimation("girlfriend", "singLEFT")
    end,
	[1] = function()
        playActorAnimation("girlfriend", "singDOWN")
	end,
	[2] = function()
        playActorAnimation("girlfriend", "singUP")
	end,
	[3] = function()
        playActorAnimation("girlfriend", "singRIGHT")
	end
}

local noteSing = switch[0]

function goodNoteHit()
    noteSing = switch[goodNoteData];
    if(noteSing) then
        noteSing()
    end
    giveHealth(0.023)
end

function noteMiss()
    playActorAnimation("girlfriend", "sad")
    drainHealth(0.04)
end