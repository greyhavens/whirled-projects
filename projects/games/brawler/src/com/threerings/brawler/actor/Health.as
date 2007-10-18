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

    // documentation inherited
    override protected function get clipClass () :String
    {
        return "HealthSprite";
    }

    // documentation inherited
    override protected function hit (player :Player) :void
    {
        var amount :Number = Math.round(player.maxhp - player.hp);
        super.hit(player);
        _view.addTransient(_ctrl.create("Crosses"), x, y, true);
        if (amount > 0) {
            var health :MovieClip = _ctrl.create("HealthNumber");
            health.txt.dmg.text = "+" + Math.round(amount);
            _view.addTransient(health, x, y, true);
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
}
}
