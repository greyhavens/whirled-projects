package view {

import flash.display.MovieClip;

public class TorpedoShotView extends ShotView
{
    public function TorpedoShotView (torpedo :TorpedoShot)
    {
        super(torpedo);

        var shipType :ShipType = Codes.getShipType(torpedo.shipType);
        var shotMovie :MovieClip = MovieClip(new (shipType.secondaryAnim)());
        addChild(shotMovie);

        rotation = Codes.RADS_TO_DEGS*Math.atan2(torpedo.xVel, -torpedo.yVel);
    }

    override protected function handleHit (e :ShotHitEvent) :void
    {
        var wasp :WaspShipType = Codes.SHIP_TYPE_WASP;
        AppContext.game.explodeCustom(e.x, e.y, MovieClip(new (wasp.secondaryExplode)()));
        AppContext.game.playSoundAt(wasp.secondaryExplodeSound, x, y);
    }
}

}
