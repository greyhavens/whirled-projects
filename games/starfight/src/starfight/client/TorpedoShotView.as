package starfight.client {

import flash.display.MovieClip;

import starfight.*;

public class TorpedoShotView extends ShotView
{
    public function TorpedoShotView (torpedo :TorpedoShot)
    {
        super(torpedo);

        var rsrc :ShipTypeResources = ClientConstants.getShipResources(torpedo.shipType);
        var shotMovie :MovieClip = MovieClip(new rsrc.secondaryAnim());
        addChild(shotMovie);

        rotation = Constants.RADS_TO_DEGS*Math.atan2(torpedo.xVel, -torpedo.yVel);
    }

    override protected function handleHit (e :ShotHitEvent) :void
    {
        var wasp :WaspShipTypeResources = ClientConstants.SHIP_RSRC_WASP;
        ClientContext.board.playCustomExplosion(e.x, e.y, MovieClip(new (wasp.secondaryExplode)()));
        ClientContext.game.playSoundAt(wasp.secondaryExplodeSound, x, y);
    }
}

}
