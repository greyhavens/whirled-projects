package popcraft.battle.view {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import popcraft.*;
import popcraft.battle.*;
import popcraft.game.*;
import popcraft.ui.HealthMeters;
import popcraft.ui.RectMeterView;
import popcraft.util.*;

public class WorkshopView extends BattlefieldSprite
{
    public static function getAll () :Array
    {
        return GameCtx.gameMode.getObjectsInGroup(GROUP_NAME);
    }

    public static function getForPlayer (playerIndex :int) :WorkshopView
    {
        return GameCtx.gameMode.getObjectNamed(NAME_PREFIX + playerIndex) as WorkshopView;
    }

    public function WorkshopView (unit :WorkshopUnit)
    {
        _unit = unit;

        _movie = ClientCtx.instantiateMovieClip("workshop", "base", true);
        _workshop = _movie["workshop"];
        // is the workshop already burning?
        if (_unit.health / _unit.maxHealth <= BURNING_HEALTH_PERCENT) {
            setBurning();
        } else {
            recolorWorkshop(_workshop);
        }

        _targetAttach = _movie["target_attach"];

        _sprite.addChild(_movie);

        // create health meters
        _healthMeters = HealthMeters.createWorkshopMeters(
            _unit.owningPlayerInfo.color,
            _unit.maxHealth,
            _unit.health);

        var yOffset :Number = -_sprite.height;
        for each (var healthMeter :RectMeterView in _healthMeters) {
            healthMeter.x = -(healthMeter.width * 0.5);
            healthMeter.y = yOffset - healthMeter.height;
            _sprite.addChild(healthMeter);
            yOffset -= (healthMeter.height + 1);
        }

        _shieldMeterParent = SpriteUtil.createSprite();
        _shieldMeterParent.y = -_sprite.height + SHIELD_METER_Y_LOC;
        _sprite.addChild(_shieldMeterParent);
        updateShieldMeters(false);

        // player name
        var owningPlayer :PlayerInfo = _unit.owningPlayerInfo;
        var nameText :TextField = _movie["player_name"];
        nameText.text = owningPlayer.displayName;

        // create "Shout View"
        _shoutView = new ShoutView();
        _shoutView.x = SHOUT_VIEW_LOC.x;
        _shoutView.y = SHOUT_VIEW_LOC.y;
        GameCtx.gameMode.addObject(_shoutView, _sprite);

        // clickable sprite
        _clickableSprite.graphics.beginFill(0, 0);
        _clickableSprite.graphics.drawRect(
            CLICKABLE_SPRITE_SIZE.x,
            CLICKABLE_SPRITE_SIZE.y,
            CLICKABLE_SPRITE_SIZE.width,
            CLICKABLE_SPRITE_SIZE.height);
        _clickableSprite.graphics.endFill();

        GameCtx.battleBoardView.clickableObjectParent.addChild(_clickableSprite);
        var thisObj :WorkshopView = this;
        registerListener(_clickableSprite, MouseEvent.CLICK,
            function (...ignored) :void {
                GameCtx.gameMode.workshopClicked(thisObj);
            });

        updateWorkshopLocation();
    }

    public function showShout (shoutType :int) :void
    {
        _shoutView.showShout(shoutType);
    }

    public function addTargetWorkshopBadge (badge :TargetWorkshopBadge) :void
    {
        _targetBadges.push(badge);
        updateTargetWorkshopBadges();
    }

    public function removeTargetWorkshopBadge (badge :TargetWorkshopBadge) :void
    {
        ArrayUtil.removeFirst(_targetBadges, badge);
        updateTargetWorkshopBadges();
    }

    protected function updateTargetWorkshopBadges () :void
    {
        if (_targetBadgeParent != null) {
            _targetAttach.removeChild(_targetBadgeParent);
            _targetBadgeParent = null;
        }

        if (_targetBadges.length > 0) {
            _targetBadgeParent = SpriteUtil.createSprite();
            var xOffset :Number = TARGET_BADGE_X_OFFSET;
            for each (var badge :TargetWorkshopBadge in _targetBadges) {
                badge.x = xOffset;
                _targetBadgeParent.addChild(badge.displayObject);
                xOffset += TARGET_BADGE_X_OFFSET;
            }

            var width :Number = (_targetBadges.length * TARGET_BADGE_WIDTH) -
                ((_targetBadges.length - 1) * TARGET_BADGE_X_OFFSET);

            _targetBadgeParent.x = -width * 0.5;
            _targetAttach.addChild(_targetBadgeParent);
        }
    }

    protected function setBurning () :void
    {
        setWorkshopMovie(ClientCtx.instantiateMovieClip("workshop", "workshop_fire"));
    }

    protected function setWorkshopMovie (workshop :MovieClip) :void
    {
        recolorWorkshop(workshop);
        var index :int = _movie.getChildIndex(_workshop);
        _movie.removeChildAt(index);
        _movie.addChildAt(workshop, index);
        _workshop = workshop;

        updateWorkshopLocation();
    }

    protected function recolorWorkshop (workshop :MovieClip) :void
    {
        var playerColor :uint = _unit.owningPlayerInfo.color;
        var recolor :MovieClip = workshop["recolor"];
        recolor.filters = [ ColorMatrix.create().colorize(playerColor).createFilter() ];
    }

    override public function get objectName () :String
    {
        return NAME_PREFIX + _unit.owningPlayerIndex;
    }

    public function unitCreated () :void
    {
        _workshop.gotoAndPlay("flash");
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        registerListener(_unit, UnitEvent.ATTACKED, handleAttacked);
    }

    override protected function removedFromDB () :void
    {
        _clickableSprite.parent.removeChild(_clickableSprite);
        _shoutView.destroySelf();
        super.removedFromDB();
    }

    override protected function scaleSprites () :void
    {
        super.scaleSprites();
        _clickableSprite.scaleX = _spriteScale;
        _clickableSprite.scaleY = _spriteScale;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get clickableObject () :InteractiveObject
    {
        return _clickableSprite;
    }

    protected function updateWorkshopLocation () :void
    {
        updateLoc(_unit.x, _unit.y);

        // flip the movie if we're on the left side of the board
        _workshop.scaleX = (_unit.x < GameCtx.gameMode.battlefieldWidth * 0.5 ? -1 : 1);

        _clickableSprite.x = this.x;
        _clickableSprite.y = this.y;
    }

    override protected function update (dt :Number) :void
    {
        var health :Number = _unit.health;
        if (health != _lastHealth) {
            if (health <= 0) {
                GameCtx.playGameSound("sfx_death_base");
                destroySelf();

                // create the rubble sprite
                GameCtx.gameMode.addObject(
                    new DeadWorkshopView(_unit),
                    GameCtx.battleBoardView.unitViewParent);

            } else {
                // update all health meters
                var remainingValue :Number = health;
                for each (var healthMeter :RectMeterView in _healthMeters) {
                    var meterValue :Number = Math.min(remainingValue, healthMeter.maxValue);
                    healthMeter.value = meterValue;
                    remainingValue -= meterValue;
                    if (healthMeter.needsDisplayUpdate) {
                        healthMeter.updateDisplay();
                    }
                }

                // swap in the burning workshop
                if ((health / _unit.maxHealth) <= BURNING_HEALTH_PERCENT &&
                    (_lastHealth / _unit.maxHealth) > BURNING_HEALTH_PERCENT) {
                    setBurning();
                }
            }

            _lastHealth = health;
        }

        // update damage shields
        var shieldModCount :int = _unit.damageShieldModCount;
        if (shieldModCount != _lastShieldsModCount) {
            updateShieldMeters(true);
        }
    }

    protected function updateShieldMeters (playSounds :Boolean) :void
    {
        var playerColor :uint = _unit.owningPlayerInfo.color;
        var shieldColor :uint = 0xFFFFFF;//ColorUtil.blend(playerColor, 0x000000);

        var shields :Array = _unit.damageShields;
        var meter :RectMeterView;

        // remove destroyed shields
        var soundName :String;
        while (_shieldMeters.length > shields.length) {
            meter = _shieldMeters[0];
            meter.parent.removeChild(meter);
            _shieldMeters.splice(0, 1);
            soundName = "sfx_lostmultiplier";
        }

        // add new shields
        while (_shieldMeters.length < shields.length) {
            meter = new RectMeterView();
            meter.foregroundColor = shieldColor;
            meter.backgroundColor = 0xBBBBBB;
            meter.outlineColor = 0x000000;
            meter.meterHeight = SHIELD_METER_HEIGHT;
            _shieldMeterParent.addChild(meter);
            _shieldMeters.push(meter);
            soundName = "sfx_gotmultiplier";
        }

        if (playSounds && soundName != null) {
            GameCtx.playGameSound(soundName);
        }

        // update shields
        var xLoc :Number = 0;
        for (var ii :int = shields.length - 1; ii >= 0; --ii) {
            meter = _shieldMeters[ii];
            var shield :UnitDamageShield = shields[ii];

            meter.maxValue = shield.maxHealth;
            meter.value = shield.health;
            meter.meterWidth = SHIELD_METER_WIDTH_PER_HEALTH * meter.maxValue;
            if (meter.needsDisplayUpdate) {
                meter.updateDisplay();
            }

            meter.x = xLoc;
            xLoc += meter.meterWidth;
        }

        _shieldMeterParent.x = -(_shieldMeterParent.width * 0.5);

        _lastShieldsModCount = _unit.damageShieldModCount;
    }

    protected function handleAttacked (...ignored) :void
    {
        var timeNow :Number = ClientCtx.mainLoop.elapsedSeconds;
        if (timeNow - _lastDebrisTime >= DEBRIS_INTERVAL_MIN) {
            // show a "debris" effect
            if (null == g_debrisClass) {
                var swf :SwfResource = ClientCtx.rsrcs.getResource("splatter") as SwfResource;
                g_debrisClass = swf.getClass("debris");
            }

            var debrisObj :SimpleSceneObject = new SimpleSceneObject(new g_debrisClass());
            debrisObj.addTask(After(0.3, new SelfDestructTask()));

            // pick a random location for the debris
            var x :Number = Rand.nextNumberRange(DEBRIS_RECT.left, DEBRIS_RECT.right,
                Rand.STREAM_COSMETIC);
            var y :Number = Rand.nextNumberRange(DEBRIS_RECT.top, DEBRIS_RECT.bottom,
                Rand.STREAM_COSMETIC);
            debrisObj.x = x;
            debrisObj.y = y;

            this.db.addObject(debrisObj, _sprite);

            _lastDebrisTime = timeNow;
        }

        // play a sound
        var soundName :String = Rand.nextElement(HIT_SOUND_NAMES, Rand.STREAM_COSMETIC);
        GameCtx.playGameSound(soundName);
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    public function get workshop () :WorkshopUnit
    {
        return _unit;
    }

    protected var _sprite :Sprite = SpriteUtil.createSprite();
    protected var _clickableSprite :Sprite = SpriteUtil.createSprite(true, true);
    protected var _movie :MovieClip;
    protected var _workshop :MovieClip;
    protected var _targetAttach :MovieClip;
    protected var _targetBadgeParent :Sprite;
    protected var _targetBadges :Array = [];
    protected var _unit :WorkshopUnit;
    protected var _shoutView :ShoutView;

    protected var _lastHealth :Number;
    protected var _healthMeters :Array = [];

    protected var _lastShieldsModCount :int;
    protected var _shieldMeters :Array = [];
    protected var _shieldMeterParent :Sprite;

    protected var _lastDebrisTime :Number = 0;

    protected static var g_debrisClass :Class;

    protected static const SHOUT_VIEW_LOC :Point = new Point(0, -75);
    protected static const SHIELD_METER_HEIGHT :Number = 7;
    protected static const SHIELD_METER_Y_LOC :Number = 6;
    protected static const SHIELD_METER_WIDTH_PER_HEALTH :Number = 50 / 75;
    protected static const GROUP_NAME :String = "PlayerBaseUnitView";
    protected static const HIT_SOUND_NAMES :Array =
        [ "sfx_basehit1", "sfx_basehit2", "sfx_basehit3" ];

    protected static const CLICKABLE_SPRITE_SIZE :Rectangle = new Rectangle(-27, -74, 55, 74);
    protected static const DEBRIS_RECT :Rectangle = new Rectangle(-27, -74, 55, 74);

    protected static const BURNING_HEALTH_PERCENT :Number = 0.5;

    protected static const DEBRIS_INTERVAL_MIN :Number = 0.5;
    protected static const NAME_PREFIX :String = "WorkshopView_";

    protected static const TARGET_BADGE_WIDTH :Number = 25;
    protected static const TARGET_BADGE_X_OFFSET :Number = 12;
}

}
