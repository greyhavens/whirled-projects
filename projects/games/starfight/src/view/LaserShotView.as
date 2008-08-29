package view {

import flash.display.MovieClip;

public class LaserShotView extends ShotView
{
    public function LaserShotView (laserShot :LaserShot)
    {
        super(laserShot);

        var shipType :ShipType = Codes.getShipType(laserShot.shipType);
        var shotMovie :MovieClip = MovieClip(new (shipType.shotAnim)());
        shotMovie.gotoAndStop(1);
        shotMovie.scaleY = Codes.PIXELS_PER_TILE * laserShot.length / shotMovie.height;
        addChild(shotMovie);

        rotation = laserShot.angle - 90;
    }
}

}
