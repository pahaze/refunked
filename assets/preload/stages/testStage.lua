-- create runs any functions when PlayState (/ReFunkedLua) gets created.
function create()
    -- makeSprite creates a sprite
    makeSprite("bg", "assets/shared/images/stageback.png", -600, -200, true)
    -- setSpriteScrollFactor changes scroll factor if needed
    setSpriteScrollFactor("bg", 0.9, 0.9)
    -- addSprite adds the sprite to the game (needed).
    addSprite("bg", false);

    -- makeSprite creates a sprite
    makeSprite("stagefront", "assets/shared/images/stagefront.png", -650, 600, true)
    -- setSpriteGraphicSize as suggested sets the graphic size of a sprite.
    setSpriteGraphicSize(giveSpriteWidth("stagefront") * 1.1, giveSpriteWidth("stagefront") * 1.1)
    -- updateSpriteHitbox updates a sprite's hitbox.
    updateSpriteHitbox("stagefront")
    -- setSpriteScrollFactor changes scroll factor if needed
    setSpriteScrollFactor("stagefront", 0.9, 0.9)
    -- addSprite adds the sprite to the game (needed).
    addSprite("stagefront", false)

    -- makeSprite creates a sprite
    makeSprite("stagecurtains", "assets/shared/images/stagecurtains.png", -500, -300, true)
    -- setSpriteGraphicSize as suggested sets the graphic size of a sprite.
    setSpriteGraphicSize(giveSpriteWidth("stagecurtains") * 0.9, giveSpriteWidth("stagecurtains") * 0.9)
    -- updateSpriteHitbox updates a sprite's hitbox.
    updateSpriteHitbox("stagecurtains")
    -- setSpriteScrollFactor changes scroll factor if needed
    setSpriteScrollFactor("stagecurtains", 1.3, 1.3)
    -- addSprite adds the sprite to the game (needed).
    addSprite("stagecurtains", false)
end

-- endSong runs any functions when the song ends.
function endSong()
    -- destroySprite destroys a sprite to free memory
    destroySprite("bg")
    -- destroySprite destroys a sprite to free memory
    destroySprite("stagefront")
    -- destroySprite destroys a sprite to free memory
    destroySprite("stagecurtains")
end