package ghostbusters.client.fight.lantern {
    
public class HeartOfDarknessSettings
{
    public var gameTime :Number;
    public var heartShineTime :Number;
    public var lanternBeamRadius :Number;
    public var heartRadius :Number;
    public var ghostScale :Number;
    public var damageOutput :int;
    
    public function HeartOfDarknessSettings (
        gameTime :Number, 
        heartShineTime :Number, 
        lanternBeamRadius :Number, 
        heartRadius :Number, 
        ghostScale :Number,
        damageOutput :Number )
    {
        this.gameTime = gameTime;
        this.heartShineTime = heartShineTime;
        this.lanternBeamRadius = lanternBeamRadius;
        this.heartRadius = heartRadius;
        this.ghostScale = ghostScale;
        this.damageOutput = damageOutput;
    }

}

}