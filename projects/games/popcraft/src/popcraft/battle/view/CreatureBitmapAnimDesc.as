package popcraft.battle.view {
    
public class CreatureBitmapAnimDesc
{
    public var frameIndexes :Array;
    public var frameRate :Number;
    
    public function CreatureBitmapAnimDesc (frameIndexes :Array, totalTime :Number)
    {
        this.frameIndexes = frameIndexes;
        this.frameRate = frameIndexes.length / totalTime;
    }

}
    
}