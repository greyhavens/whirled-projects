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
        _movie = ClientCtx.createSpecialStrainMovie(strain);
        addTask(new SerialTask(
            new PlaySoundTask("sfx_popped_special_strain"),
            new ParallelTask(
                ScaleTask.CreateSmooth(0, 0, 0.7),
                ColorMatrixBlendTask.colorize(0xffffff, 0, 0.3, _movie)),
            new SelfDestructTask()));

        this.x = x;
        this.y = y;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    protected var _movie :MovieClip;
}

}
