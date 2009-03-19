package vampire.feeding.client {

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
        _movie = ClientCtx.createSpecialStrainMovie(strain, true, true);
        _movie.gotoAndPlay(1);

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        addTask(new SerialTask(
            new PlaySoundTask("sfx_popped_special_strain"),
            new ParallelTask(
                ScaleTask.CreateSmooth(0, 0, 0.7),
                ColorMatrixBlendTask.colorize(0xffffff, 0, 0.3, _sprite)),
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
}

}
