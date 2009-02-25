package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.feeding.*;

public class LostSpecialStrainAnim
    extends SceneObject
{
    public function LostSpecialStrainAnim (strain :int, x :int, y :int)
    {
        _movie = ClientCtx.instantiateMovieClip("blood", MOVIES[strain], true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        addTask(new SerialTask(
            new ParallelTask(
                ScaleTask.CreateSmooth(0, 0, 0.7),
                ColorMatrixBlendTask.colorize(_sprite, 0xffffff, 0, 0.3)),
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

    protected static const MOVIES :Array = [
        "type_01",
        "type_02",
        "type_03",
        "type_04",
        "type_05",
        "type_06",
        "type_07",
        "type_08",
        "type_09",
        "type_10",
        "type_11",
        "type_12",
    ];
}

}
