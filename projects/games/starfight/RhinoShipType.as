package {

import flash.media.Sound;
import flash.media.SoundTransform;

public class RhinoShipType extends ShipType
{
    public function RhinoShipType () :void
    {
        name = "Rhino";
        forwardAccel = 6.0;
        backwardAccel = -2;
        friction = 0.1;
        turnRate = 240;
        turnAccel = 48.0;
        turnFriction = 0.01;

        hitPower = 0.2;
        primaryShotCost = 0.2;
        primaryShotRecharge = 0.4;
        primaryPowerRecharge = 4;
        primaryShotSpeed = 30;
        primaryShotLife = 2.5;
        primaryShotSize = 0.1;

        secondaryShotCost = 0.5;
        secondaryShotRecharge = 3;
        secondaryPowerRecharge = 20;

        armor = 1.5;
        size = 1.2;
    }

    override public function primaryShot (sf :StarFight, val :Array) :void
    {
        var left :Number = val[6] + Math.PI/2;
        var right :Number = val[6] - Math.PI/2;
        var leftOffsetX :Number = Math.cos(left) * 0.5;
        var leftOffsetY :Number = Math.sin(left) * 0.5;
        var rightOffsetX :Number = Math.cos(right) * 0.5;
        var rightOffsetY :Number = Math.sin(right) * 0.5;

        var damage :Number = (val[2] == ShotSprite.SUPER ? hitPower * 1.5 : hitPower);

        sf.addShot(new MissileShotSprite(val[3] + leftOffsetX, val[4] + leftOffsetY,
                val[5], val[6], val[0], damage, primaryShotLife, val[1], sf));
        sf.addShot(new MissileShotSprite(val[3] + rightOffsetX, val[4] + rightOffsetY,
                val[5], val[6], val[0], damage, primaryShotLife, val[1], sf));

        super.primaryShot(sf, val);
    }

    override protected function swfAsset () :Class
    {
        return SHIP;
    }

    [Embed(source="rsrc/ships/rhino.swf", mimeType="application/octet-stream")]
    protected static const SHIP :Class;
}
}
