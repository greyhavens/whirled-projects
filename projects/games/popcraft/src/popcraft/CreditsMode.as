package popcraft {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.MouseEvent;

import popcraft.battle.view.CreatureAnimFactory;
import popcraft.battle.view.TeslaSoundPlayer;
import popcraft.sp.story.LevelSelectMode;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

public class CreditsMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // show a bit of the Tesla level
        var bg :MovieClip = SwfResource.instantiateMovieClip("bg", "tesla");
        bg.x = 152;
        bg.y = 245;
        _modeSprite.addChild(bg);

        var attach :MovieClip = bg["attachment"];
        _unitParent = SpriteUtil.createSprite();
        _unitParent.x = -bg.x;
        _unitParent.y = -bg.y;
        attach.addChild(_unitParent);

        // play the zap sound for the Tesla animation
        addObject(new TeslaSoundPlayer(bg, AudioManager.instance.playSoundNamed));

        var creditsMovie :MovieClip = SwfResource.instantiateMovieClip("splashUi", "credits");
        creditsMovie.x = 350;
        creditsMovie.y = 250;
        _modeSprite.addChild(creditsMovie);

        // show little units next to Tim, Jon, and Harry
        MovieClip(creditsMovie["tim"]).addChild(CreatureAnimFactory.instantiateUnitAnimation(
            Constants.UNIT_TYPE_BOSS, 0x9FBCFF, "walk_SW"));
        MovieClip(creditsMovie["jon"]).addChild(CreatureAnimFactory.instantiateUnitAnimation(
            Constants.UNIT_TYPE_HEAVY, 0x9FBCFF, "walk_SW"));
        MovieClip(creditsMovie["harry"]).addChild(CreatureAnimFactory.instantiateUnitAnimation(
            Constants.UNIT_TYPE_SAPPER, 0x9FBCFF, "walk_SW"));

        // back button
        var backButton :SimpleButton = UIBits.createButton("Back", 1.5);
        backButton.x = Constants.SCREEN_SIZE.x - backButton.width - 10;
        backButton.y = Constants.SCREEN_SIZE.y - backButton.height - 10;
        registerOneShotCallback(backButton, MouseEvent.CLICK,
            function (...ignored) :void {
                LevelSelectMode.create();
            });
        _modeSprite.addChild(backButton);

        // create some creatures to wander around
        for (var ii :int = 0; ii < NUM_CREATURES; ++ii) {
            var creature :WanderingCreature = new WanderingCreature(
                Constants.UNIT_TYPE_GRUNT,
                0xFFFFFF);
            creature.x =
                Rand.nextIntRange(WANDER_BOUNDS.left, WANDER_BOUNDS.right + 1, Rand.STREAM_COSMETIC);
            creature.y =
                Rand.nextIntRange(WANDER_BOUNDS.top, WANDER_BOUNDS.bottom + 1, Rand.STREAM_COSMETIC);
            addObject(creature, _unitParent);
        }

        for (ii = 0; ii < NUM_DEAD_CREATURES; ++ii) {
            var creatureType :int = Rand.nextElement(DEAD_CREATURE_TYPES, Rand.STREAM_COSMETIC);
            var facing :String = Rand.nextElement(Constants.FACING_STRINGS, Rand.STREAM_COSMETIC);
            var flipX :Boolean;
            if (facing == "NE") {
                facing = "NW";
                flipX = true;
            } else if (facing == "SE") {
                facing = "SW";
                flipX = true;
            }

            var anim :BitmapAnim =
                CreatureAnimFactory.getBitmapAnim(creatureType, 0xFF0000, "die_" + facing);
            var lastFrame :BitmapAnimFrame = anim.frames[anim.frames.length - 1];
            // create an anim view using only the last frame of the death animation
            var animView :BitmapAnimView = new BitmapAnimView(new BitmapAnim([ lastFrame ], 1));
            animView.x =
                Rand.nextIntRange(DIE_BOUNDS.left, DIE_BOUNDS.right + 1, Rand.STREAM_COSMETIC);
            animView.y =
                Rand.nextIntRange(DIE_BOUNDS.top, DIE_BOUNDS.bottom + 1, Rand.STREAM_COSMETIC);
            animView.scaleX = (flipX ? -1 : 1);

            addObject(animView, _unitParent);
        }
    }

    override protected function enter () :void
    {
        super.enter();
        StageQualityManager.pushStageQuality(StageQuality.HIGH);
    }

    override protected function exit () :void
    {
        StageQualityManager.popStageQuality();
        super.exit();
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        DisplayUtil.sortDisplayChildren(_unitParent, displayObjectYSort);
    }

    protected static function displayObjectYSort (a :DisplayObject, b :DisplayObject) :int
    {
        var ay :Number = a.y;
        var by :Number = b.y;

        if (ay < by) {
            return -1;
        } else if (ay > by) {
            return 1;
        } else {
            return 0;
        }
    }

    protected var _unitParent :Sprite;

    protected static const NUM_CREATURES :int = 1;
    protected static const NUM_DEAD_CREATURES :int = 8;

    protected static const DEAD_CREATURE_TYPES :Array = [
        Constants.UNIT_TYPE_GRUNT, Constants.UNIT_TYPE_HEAVY, Constants.UNIT_TYPE_COURIER
    ];

}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.util.Rand;

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Rectangle;

import popcraft.*;
import popcraft.data.UnitData;
import popcraft.util.SpriteUtil;
import popcraft.battle.view.CreatureAnimFactory;
import com.whirled.contrib.simplegame.tasks.LocationTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.threerings.util.Random;
import com.whirled.contrib.simplegame.tasks.TimedTask;
import mx.effects.Move;

class WanderingCreature extends SceneObject
{
    public function WanderingCreature (unitType :int, color :uint)
    {
        _unitType = unitType;
        _unitData = AppContext.defaultGameData.units[unitType];
        _sprite = SpriteUtil.createSprite();

        setupAnimations(color);
    }

    override protected function addedToDB () :void
    {
        // wander around
        addTask(new RepeatingTask(
            new WanderTask(this),
            new RandomPauseTask(1, 3, Rand.STREAM_COSMETIC)));
    }

    public function get unitData () :UnitData
    {
        return _unitData;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function set movementAngle (val :Number) :void
    {
        _movementAngle = val;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var moving :Boolean;
        var facing :int = _lastFacing;

        var loc :Vector2 = new Vector2(this.x, this.y);
        if (!loc.equals(_lastLoc)) {
            moving = true;
            // determine facing direction
            facing = getFacingDirectionFromAngle(_movementAngle);
        }

        if (moving != _lastMoving || facing != _lastFacing) {
            var animArray :Array = (moving ? _animMoving : _animMoving);
            var animIndex :int = facing;
            // if the character is facing NE or SE,
            // we use the NW/SW animations and flip
            var flipX :Boolean;
            if (Constants.FACING_NE == animIndex) {
                animIndex = Constants.FACING_NW;
                flipX = true;
            } else if (Constants.FACING_SE == animIndex) {
                animIndex = Constants.FACING_SW;
                flipX = true;
            }

            var newAnim :MovieClip = animArray[animIndex];
            newAnim.scaleX = (flipX ? -1 : 1);
            var oldAnim :MovieClip = MovieClip(_sprite.getChildAt(0));
            if (newAnim != oldAnim) {
                _sprite.removeChildAt(0);
                _sprite.addChildAt(newAnim, 0);
            }
        }

        _lastLoc = loc;
        _lastFacing = facing;
        _lastMoving = moving;
    }

    protected static function getFacingDirectionFromAngle (angleRadians :Number) :int
    {
        Assert.isTrue(angleRadians >= 0 && angleRadians < (Math.PI * 2), "bad angle: " + angleRadians);

        // where does the angle land on the unit circle?
        // since we're dealing with screen coordinates, south is "up" on the unit circle

        if (angleRadians < Math.PI * (3/8)) {
            return Constants.FACING_SE;
        } else if (angleRadians < Math.PI * (5/8)) {
            return Constants.FACING_S;
        } else if (angleRadians < Math.PI) {
            return Constants.FACING_SW;
        } else if (angleRadians < Math.PI * (11/8)) {
            return Constants.FACING_NW;
        } else if (angleRadians < Math.PI * (13/8)) {
            return Constants.FACING_N;
        } else {
            return Constants.FACING_NE;
        }
    }

    protected function setupAnimations (playerColor :uint) :void
    {
        for (var i :int = 0; i < 2; ++i) {

            var animArray :Array;
            var animNamePrefix :String;

            switch (i) {
            case 0: animArray = _animStanding; animNamePrefix = "stand_"; break;
            case 2: animArray = _animMoving; animNamePrefix = "walk_"; break;
            }

            // we don't have separate animations for NE and SE facing directions,
            // instead, we use the NW and SW animations and flip them.
            for (var facing :int = Constants.FACING_N; facing <= Constants.FACING_S; ++facing) {
                var animName :String = animNamePrefix + Constants.FACING_STRINGS[facing];
                var anim :MovieClip = CreatureAnimFactory.instantiateUnitAnimation(
                    _unitType, playerColor, animName);

                if (null != anim) {
                    animArray.push(anim);
                }
            }
        }

        // substitute animations
        if (_animMoving.length == 0 && _animStanding.length > 0) {
            _animMoving = _animStanding;
        } else if (_animStanding.length == 0 && _animMoving.length > 0) {
            _animStanding = _animMoving;
        }

        _sprite.addChild(_animStanding[0]);
    }

    protected var _sprite :Sprite;
    protected var _unitType :int;
    protected var _unitData :UnitData;

    protected var _movementAngle :Number = 0;
    protected var _lastLoc :Vector2 = new Vector2();
    protected var _lastFacing :int = 0;
    protected var _lastMoving :Boolean;

    protected var _animStanding :Array = [];
    protected var _animMoving :Array = [];
}

class WanderTask extends LocationTask
{
    public function WanderTask (creature :WanderingCreature)
    {
        _creature = creature;

        var loc :Vector2 = new Vector2(creature.x, creature.y);

        var targetLoc :Vector2 = new Vector2(
            Rand.nextIntRange(WANDER_BOUNDS.left, WANDER_BOUNDS.right + 1, Rand.STREAM_COSMETIC),
            Rand.nextIntRange(WANDER_BOUNDS.top, WANDER_BOUNDS.bottom + 1, Rand.STREAM_COSMETIC));

        var d :Vector2 = targetLoc.subtract(loc);
        var time :Number = d.length / creature.unitData.baseMoveSpeed;
        creature.movementAngle = d.normalize().angle;

        super(targetLoc.x, targetLoc.y, time);
    }

    override public function clone () :ObjectTask
    {
        return new WanderTask(_creature);
    }

    protected var _creature :WanderingCreature;
}

class RandomPauseTask extends TimedTask
{
    public function RandomPauseTask (low :Number, high :Number, randStreamId :int)
    {
        _low = low;
        _high = high;
        _randStreamId = randStreamId;

        super(Rand.nextNumberRange(low, high, randStreamId));
    }

    override public function clone () :ObjectTask
    {
        return new RandomPauseTask(_low, _high, _randStreamId);
    }

    protected var _low :Number;
    protected var _high :Number;
    protected var _randStreamId :int;
}

const WANDER_BOUNDS :Rectangle = new Rectangle(0, 42, 320, 250);
const DIE_BOUNDS :Rectangle = new Rectangle(0, 42, 320, 250);
