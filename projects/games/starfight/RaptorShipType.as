package {

import flash.media.Sound;
import flash.media.SoundTransform;

public class RaptorShipType extends ShipType
{
    public function RaptorShipType () :void
    {
        name = "Raptor";

        forwardAccel = 4.0;
        backwardAccel = -1.5;
        friction = 0.02;
        turnRate = 130;
        turnAccel = 45.0;
        turnFriction = 0.02;

        hitPower = 0.12;
        primaryShotCost = 0.25;
        primaryShotRecharge = 0.1;
        primaryPowerRecharge = 2.5;
        primaryShotSpeed = 20;
        primaryShotLife = 0.3;
        primaryShotSize = 0.3;

        secondaryShotCost = 0.33;
        secondaryShotRecharge = 1;
        secondaryPowerRecharge = 30;
        secondaryShotSpeed = 0.5;
        secondaryShotLife = 4;

        armor = 1;
        size = 1.1;
    }

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var ttl :Number = primaryShotLife;
        if (val[2] == ShotSprite.SUPER) {
            ttl *= 2;
        }
        for (var ii :Number = -0.3; ii <= 0.3; ii += 0.3) {
            sf.addShot(new MissileShotSprite(
                    val[3], val[4], val[5], val[6] + ii, val[0], hitPower, ttl, val[1], sf));
        }
        super.primaryShot(sf, val);
    }

    override public function secondaryShot (sf :StarFight, val :Array) :void
    {
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    [Embed(source="rsrc/ships/raptor.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;
}
}
