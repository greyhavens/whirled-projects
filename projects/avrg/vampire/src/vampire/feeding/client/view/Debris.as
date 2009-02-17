package vampire.feeding.client.view {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;

import vampire.feeding.*;
import vampire.feeding.client.*;

public class Debris extends SceneObject
{
    public function Debris ()
    {
        _movie = ClientCtx.instantiateMovieClip("blood", "extra", true, true);
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(_movie);

        init();
    }

    protected function init () :void
    {
        removeAllTasks();
        _respawning = false;
        _respawnNow = false;

        // pick a random location
        var dist :Number = Rand.nextNumberRange(
            Constants.HEART_RADIUS + 5,
            Constants.GAME_RADIUS - 25,
            Rand.STREAM_COSMETIC);
        var angle :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_COSMETIC);
        _loc = Vector2.fromAngle(angle, dist).addLocal(Constants.GAME_CTR);

        // pick a random location to die at
        var respawnDist :Number =
            Rand.nextNumberRange(dist, Constants.GAME_RADIUS - 5, Rand.STREAM_COSMETIC);
        _respawnDist2 = respawnDist * respawnDist;

        _moveCCW = Rand.nextBoolean(Rand.STREAM_COSMETIC);
        _speed = Rand.nextNumberRange(3, 7, Rand.STREAM_COSMETIC);

        // fade in
        this.alpha = 0;
        addTask(new AlphaTask(1, 1));

        // rotate
        addTask(new ConstantRotationTask(
            Rand.nextNumberRange(3, 5, Rand.STREAM_COSMETIC),
            _moveCCW));
    }

    override protected function update (dt :Number) :void
    {
        if (_respawnNow) {
            init();
        }

        // move around the heart
        var ctrImpulse :Vector2 = _loc.subtract(Constants.GAME_CTR);
        ctrImpulse.length = 2;

        var perpImpulse :Vector2 = ctrImpulse.getPerp(_moveCCW);
        perpImpulse.length = 3.5;

        var impulse :Vector2 = ctrImpulse.add(perpImpulse);
        impulse.length = _speed * dt;

        _loc.x += impulse.x;
        _loc.y += impulse.y;

        _loc = GameCtx.clampLoc(_loc);

        if (!_respawning && _loc.subtract(Constants.GAME_CTR).lengthSquared >= _respawnDist2) {
            _respawning = true;
            addTask(new SerialTask(
                new AlphaTask(0, 1),
                new FunctionTask(function () :void {
                    _respawnNow = true;
                })));
        }

        this.displayObject.x = _loc.x;
        this.displayObject.y = _loc.y;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    protected var _sprite :Sprite;
    protected var _movie :MovieClip;

    protected var _loc :Vector2;
    protected var _moveCCW :Boolean;
    protected var _speed :Number;
    protected var _respawnDist2 :Number;

    protected var _respawning :Boolean;
    protected var _respawnNow :Boolean;
}

}
