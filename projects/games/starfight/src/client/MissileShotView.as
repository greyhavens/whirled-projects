package client {

import flash.display.MovieClip;

public class MissileShotView extends ShotView
{
    public function MissileShotView (missile :MissileShot, shotClip :Class, explodeClip :Class)
    {
        super(missile);

        var shotMovie :MovieClip;
        if (shotClip != null) {
            shotMovie = MovieClip(new shotClip());
        } else {
            var rsrc :ShipTypeResources = ClientConstants.getShipResources(missile.shipType);
            shotMovie = MovieClip(new rsrc.shotAnim());
        }

        shotMovie.gotoAndStop(1);
        addChild(shotMovie);

        rotation = Constants.RADS_TO_DEGS * Math.atan2(missile.xVel, -missile.yVel);

        if (explodeClip != null) {
            _explodeMovie = MovieClip(new explodeClip());
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
