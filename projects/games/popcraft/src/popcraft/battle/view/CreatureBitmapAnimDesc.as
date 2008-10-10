package popcraft.battle.view {
    import popcraft.BitmapAnim;


public class CreatureBitmapAnimDesc
{
    public var frameIndexes :Array;
    public var totalTime :Number;
    public var endBehavior :int;

    public function CreatureBitmapAnimDesc (frameIndexes :Array, totalTime :Number,
        endBehavior :int = BitmapAnim.LOOP)
    {
        this.frameIndexes = frameIndexes;
        this.totalTime = totalTime;
        this.endBehavior = endBehavior;
    }

}

}
