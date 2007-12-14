package popcraft.battle {

/** Encapsulates immutable data about a particular type of Creature. */
public class UnitData
{
    public var name :String;
    public var resourceCosts :Array;
    public var imageClass :Class;

    // movement variables
    public var wanderEvery :Number;
    public var wanderRangeMin: Number;
    public var wanderRangeMax: Number;
    public var movePixelsPerSecond :Number;

    public function UnitData (
        name :String,
        resourceCosts :Array,
        imageClass :Class,
        wanderEvery :Number,
        wanderRangeMin :Number,
        wanderRangeMax :Number,
        movePixelsPerSecond :Number )
    {
        this.name = name;
        this.resourceCosts = resourceCosts;
        this.imageClass = imageClass;

        this.wanderEvery = wanderEvery;
        this.wanderRangeMin = wanderRangeMin;
        this.wanderRangeMax = wanderRangeMax;
        this.movePixelsPerSecond = movePixelsPerSecond;
    }

    public function getResourceCost (resourceType :uint) :int
    {
        return this.resourceCosts[resourceType];
    }
}

}
