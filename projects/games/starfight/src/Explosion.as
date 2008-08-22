package {

import flash.display.MovieClip;
import flash.display.Sprite;

import flash.events.Event;

public class Explosion extends Sprite
{
    public static function createExplosion (
        x :int, y :int, rot :int, isSmall :Boolean, shipType :int) :Explosion
    {
        var explosion :Explosion;
        if (isSmall) {
            explosion = new Explosion(
                x, y, MovieClip(new (Resources.getClass("small_explosion"))()));
        } else {
            var explodeMovie :MovieClip =
                MovieClip(new Codes.SHIP_TYPES[shipType].explodeAnim());
            explodeMovie.x = explodeMovie.width/2;
            explodeMovie.y = -explodeMovie.height/2;
            explodeMovie.scaleX = Codes.SHIP_TYPES[shipType].size + 0.1;
            explodeMovie.scaleY = Codes.SHIP_TYPES[shipType].size + 0.1;
            explosion = new Explosion(x, y, explodeMovie);
        }

        // Just like we have a ship to contain our ship movie...
        explosion.rotation = rot;
        return explosion;
    }

    public function Explosion (x :int, y:int, movie :MovieClip)
    {
        _explodeMovie = movie;
        _explodeMovie.rotation = 90;
        _explodeMovie.addEventListener(Event.COMPLETE, endExplode);
        _explodeMovie.gotoAndPlay(1);
        addChild(_explodeMovie);
        this.x = x;
        this.y = y;
    }

    public function endExplode (event :Event) :void
    {
        if (parent != null) {
            _explodeMovie.removeEventListener(Event.COMPLETE, endExplode);
            parent.removeChild(this);
        }
    }

    protected var _explodeMovie :MovieClip;
}
}