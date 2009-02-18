package com.threerings.brawler.actor {

import flash.display.MovieClip;

import com.threerings.brawler.BrawlerController;

/**
 * Represents something that can be picked up by players (coins, weapon drops).
 */
public class Pickup extends Actor
{
    // documentation inherited
    override public function receive (message :Object) :void
    {
        hit(_ctrl.actors[message.player]);
    }

    // documentation inherited
    override public function enterFrame (elapsed :Number) :void
    {
        if ((_age += elapsed) >= LIFESPAN) {
            if (amOwner && visible) {
                visible = false;
                destroy();
            }
            return;
        }
        hitTestPlayers();
        if (_age >= LIFESPAN - FLASH_INTERVAL) {
            alpha = 1 - alpha;
        }
    }

    // documentation inherited
    override protected function didInit (state :Object) :void
    {
        super.didInit(state);

        // create the clip
        addChild(_clip = _ctrl.create(clipClass));
        _bounds = _clip.boundbox;
    }

    /**
     * Returns the name of the pickup's movie clip class.
     */
    protected function get clipClass () :String
    {
        return null;
    }

    /**
     * Checks for collisions against the players.
     */
    protected function hitTestPlayers () :void
    {
        if (!(amOwner && available && visible)) {
            return;
        }
        for each (var actor :Actor in _ctrl.actors) {
            if (!(actor is Player)) {
                continue;
            }
            var player :Player = actor as Player;
            if (!player.dead && bounds.hitTestObject(player.bounds)) {
                hit(player);
            }
        }
    }

    /**
     * Notes that the pickup hit a player.
     */
    protected function hit (player :Player) :void
    {
        if (amOwner) {
            send({ player: player.name });
            destroy();
        }
        if (player.amOwner) {
            award();
            _ctrl.coinsCollected += 1;
        }
        visible = false;
    }

    /**
     * Awards the local player with the pickup's contents.
     */
    protected function award () :void
    {
        // award some number of points
        _ctrl.score += points;
    }

    /**
     * Determines whether the pickup can be picked up.
     */
    protected function get available () :Boolean
    {
        return _age > 1.5;
    }

    /**
     * Returns the number of points awarded for picking this up.
     */
    protected function get points () :int
    {
        return 0;
    }

    /** The pickup clip. */
    protected var _clip :MovieClip;

    /** The current age of the pickup in seconds. */
    protected var _age :Number = 0;

    /** We disappear after we are this old. */
    protected static const LIFESPAN :Number = 10;

    /** We start flashing when we have this much time remaining to live. */
    protected static const FLASH_INTERVAL :Number = 1;
}
}
