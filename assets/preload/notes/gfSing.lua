local gfSwitch = {
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

local noteSing = gfSwitch[0]

function goodNoteHit(noteData, isSustainNote, mustPress, noteType)
    if noteType == "gfSing" then
        noteSing = gfSwitch[noteData];
        if(noteSing) then
            noteSing()
        end
        if mustPress then
            giveHealth(0.023)
        end
    end
end

function noteMiss(noteData, isSustainNote, mustPress, noteType)
    if noteType == "gfSing" then
        playActorAnimation("girlfriend", "sad")
        if mustPress then
            drainHealth(0.04)
        end
    end
end