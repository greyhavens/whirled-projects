package com.threerings.brawler.actor {

import flash.display.MovieClip;

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
        super(HealthSprite);
    }

    // documentation inherited
    override protected function hit (player :Player) :void
    {
        super.hit(player);
        var crosses :MovieClip = new Crosses();
        _view.addTransient(crosses, x, y, 0.5, true);
        var amount :Number = Math.round(player.maxhp - player.hp);
        if (amount > 0) {
            var health :MovieClip = new HealthNumber();
            health.txt.dmg.text = "+" + Math.round(amount);
            _view.addTransient(health, x, y, 1.25, true);
        }
    }

    // documentation inherited
    override protected function award () :void
    {
        // heal to maximum
        super.award();
        var self :Player = _ctrl.self;
        self.heal(self.maxhp - self.hp);
    }

    // documentation inherited
    override protected function get points () :int
    {
        return 25;
    }

    /** The health sprite class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="health")]
    protected static const HealthSprite :Class;

    /** The crosses effect class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="health_got")]
    protected static const Crosses :Class;

    /** The health number effect class. */
    [Embed(source="../../../../../rsrc/raw.swf", symbol="heal_num_player")]
    protected static const HealthNumber :Class;
}
}
