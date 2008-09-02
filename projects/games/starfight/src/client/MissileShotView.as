package client {

import flash.display.MovieClip;

public class MissileShotView extends ShotView
{
    public function MissileShotView (missile :MissileShot)
    {
        super(missile);

        var shotMovie :MovieClip;
        if (missile.shotClip != null) {
            shotMovie = MovieClip(new missile.shotClip());
        } else {
            var rsrc :ShipTypeResources = ClientConstants.getShipResources(missile.shipType);
            shotMovie = MovieClip(new rsrc.shotAnim());
        }

        shotMovie.gotoAndStop(1);
        addChild(shotMovie);

        rotation = Codes.RADS_TO_DEGS * Math.atan2(missile.xVel, -missile.yVel);

        if (missile.explodeClip != null) {
            _explodeMovie = MovieClip(new missile.explodeClip());
        }
    }

    override protected function handleHit (e :ShotHitEvent) :void
    {
        if (_explodeMovie != null) {
            ClientContext.board.playCustomExplosion(e.x, e.y, _explodeMovie);
        }
    }

    protected var _explodeMovie :MovieClip;

}

}
