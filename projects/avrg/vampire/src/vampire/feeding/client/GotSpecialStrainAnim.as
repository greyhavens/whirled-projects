package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.feeding.*;

public class GotSpecialStrainAnim
    extends SceneObject
{
    public function GotSpecialStrainAnim (strain :int, x :int, y :int)
    {
        _movie = ClientCtx.createSpecialStrainMovie(strain, true, true);
        _movie.gotoAndPlay(2);

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        addTask(new SerialTask(
            new WaitForFrameTask(55, _movie),
            new TimedTask(0.75),
            new PlaySoundTask("sfx_got_special_strain"),
            new ParallelTask(
                LocationTask.CreateSmooth(DEST_LOC.x, DEST_LOC.y, 1.25),
                ScaleTask.CreateSmooth(3, 3, 1.25)),
            new TimedTask(2),
            new AlphaTask(0, 0.5),
            new SelfDestructTask()));

        this.x = x;
        this.y = y;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected static const DEST_LOC :Vector2 = new Vector2(550, 75);
}

}
