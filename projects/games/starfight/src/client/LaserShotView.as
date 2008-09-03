package client {

import flash.display.MovieClip;

public class LaserShotView extends ShotView
{
    public function LaserShotView (laserShot :LaserShot)
    {
        super(laserShot);

        var rsrc :ShipTypeResources = ClientConstants.getShipResources(laserShot.shipType);
        var shotMovie :MovieClip = MovieClip(new rsrc.shotAnim());
        shotMovie.gotoAndStop(1);
        shotMovie.scaleY = Constants.PIXELS_PER_TILE * laserShot.length / shotMovie.height;
        addChild(shotMovie);

        rotation = laserShot.angle - 90;
    }
}

}
