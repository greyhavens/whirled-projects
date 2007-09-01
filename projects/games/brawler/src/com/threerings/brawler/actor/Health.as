package com.threerings.brawler.actor {

/**
 * Represents a health pickup.
 */
public class Health extends Pickup
{
    /**
     * Creates an initial health pickup state.
     */
    public static function createState (x :Number, y :Number ) :Object
    {
        return { type: "Health", x: x, y: y };
    }

    public function Health ()
    {
        addChild(new HealthSprite());
    }

    /** The health sprite class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="health")]
    protected static const HealthSprite :Class;

    /** The crosses effect class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="health_got")]
    protected static const Crosses :Class;
}
}
