package ghostbusters.client.fight.plasma {
    
import com.whirled.contrib.simplegame.util.NumRange;
    
public class SpiritShellSettings
{
    public var gameTime :Number;
    public var ectoplasmCount :uint;
    public var ghostSpeed :Number;
    public var ghostWanderDist :NumRange;
    public var ghostWanderDelay :NumRange;
    public var ghostBlink :Boolean;
    public var plasmaSpeed :Number;
    public var plasmaFireDelay :Number;
    public var damageOutput :Number;
    
    public function SpiritShellSettings (
        gameTime :Number, 
        ectoplasmCount :uint, 
        ghostSpeed :Number,
        ghostWanderDist :NumRange,
        ghostWanderDelay :NumRange,
        ghostBlink :Boolean,
        plasmaSpeed :Number, 
        plasmaFireDelay :Number,
        damageOutput :Number)
    {
        this.gameTime = gameTime;
        this.ectoplasmCount = ectoplasmCount;
        this.ghostSpeed = ghostSpeed;
        this.ghostWanderDist = ghostWanderDist;
        this.ghostWanderDelay = ghostWanderDelay;
        this.ghostBlink = ghostBlink;
        this.plasmaSpeed = plasmaSpeed;
        this.plasmaFireDelay = plasmaFireDelay;
        this.damageOutput = damageOutput;
    }

}

}