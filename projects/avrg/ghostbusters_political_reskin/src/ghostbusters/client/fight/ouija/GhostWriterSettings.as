package ghostbusters.client.fight.ouija {
    
public class GhostWriterSettings
{
    public var minWordLength :int;
    public var maxWordLength :int;
    public var timePerLetter :Number;
    public var letterSelectionTimer :Number;
    public var damageOutput :Number;
    
    public function GhostWriterSettings (
        minWordLength :int,
        maxWordLength :int,
        timePerLetter :Number,
        letterSelectionTimer :Number,
        damageOutput :Number)
    {
        this.minWordLength = minWordLength;
        this.maxWordLength = maxWordLength;
        this.timePerLetter = timePerLetter;
        this.letterSelectionTimer = letterSelectionTimer;
        this.damageOutput = damageOutput;
    }
}

}