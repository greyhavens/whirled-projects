package ghostbusters.client.fight.ouija {
    
public class SpiritGuideSettings
{
    public var gameTime :Number;
    public var transformDifficulty :uint;
    public var damageOutput :Number;
    
    public function SpiritGuideSettings (gameTime :Number, transformDifficulty :uint, damageOutput :Number)
    {
        this.gameTime = gameTime;
        this.transformDifficulty = transformDifficulty;
        this.damageOutput = damageOutput;
    }
}

}