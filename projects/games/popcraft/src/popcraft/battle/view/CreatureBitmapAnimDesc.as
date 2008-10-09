package popcraft.battle.view {
    import popcraft.BitmapAnim;


public class CreatureBitmapAnimDesc
{
    public var frameIndexes :Array;
    public var frameRate :Number;
    public var endBehavior :int;

    public function CreatureBitmapAnimDesc (frameIndexes :Array, totalTime :Number,
        endBehavior :int = BitmapAnim.LOOP)
    {
        this.frameIndexes = frameIndexes;
        this.frameRate = frameIndexes.length / totalTime;
        this.endBehavior = endBehavior;
    }

}

}
