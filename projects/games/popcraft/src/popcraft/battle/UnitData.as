package popcraft.battle {

import com.whirled.contrib.core.util.*;

/** Encapsulates immutable data about a particular type of Unit. */
public class UnitData
{
    public var name :String;
    public var resourceCosts :Array;

    // movement variables
    public var wanderEvery :Number;
    public var wanderRange :IntRange;
    public var movePixelsPerSecond :Number;

    public var maxHealth :int;
    public var armor :UnitArmor;
    public var weapons :Array;

    public var collisionRadius :Number;
    public var detectRadius :Number;
    public var loseInterestRadius :Number;

    public function UnitData (
        name :String,
        resourceCosts :Array,
        wanderEvery :Number,
        wanderRange :IntRange,
        movePixelsPerSecond :Number,
        maxHealth :int,
        armor :UnitArmor,
        weapons :Array,
        collisionRadius :Number,
        detectRadius :Number,
        loseInterestRadius :Number )
    {
        this.name = name;
        this.resourceCosts = resourceCosts;

        this.wanderEvery = wanderEvery;
        this.wanderRange = wanderRange;
        this.movePixelsPerSecond = movePixelsPerSecond;

        this.maxHealth = maxHealth;
        this.armor = armor;
        this.weapons = weapons;

        this.collisionRadius = collisionRadius;
        this.detectRadius = detectRadius;
        this.loseInterestRadius = loseInterestRadius;
    }

    public function getResourceCost (resourceType :uint) :int
    {
        return this.resourceCosts[resourceType];
    }
}

}
