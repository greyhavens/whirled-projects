package ghostbusters.fight.lantern {
    
public class HeartOfDarknessSettings
{
    public var gameTime :Number;
    public var heartShineTime :Number;
    public var lanternBeamRadius :Number;
    public var heartRadius :Number;
    public var ghostScale :Number;
    
    public function HeartOfDarknessSettings (gameTime :Number, heartShineTime :Number, lanternBeamRadius :Number, heartRadius :Number, ghostScale :Number)
    {
        this.gameTime = gameTime;
        this.heartShineTime = heartShineTime;
        this.lanternBeamRadius = lanternBeamRadius;
        this.heartRadius = heartRadius;
        this.ghostScale = ghostScale;
    }

}

}