package vampire.combat.client
{

import com.threerings.flash.MathUtil;
import com.whirled.contrib.DisplayUtil;
import com.whirled.contrib.simplegame.objects.SceneObjectParent;

import flash.display.Graphics;
import flash.display.Sprite;

import vampire.combat.Items;
import vampire.combat.UnitProfile;
import vampire.combat.data.Weapon;

/**
 * Stores everything about a player, stats, weapons, current energy etc
 *
 */
public class UnitRecord extends SceneObjectParent
{
    public function UnitRecord(playerControlled :Boolean, name :String, profile :UnitProfile, range :int)
    {
        this.name = name;
        this.range = range;
        this.profile = profile;
//        location.x = x;
//        location.y = y;

        this.playerControlled = playerControlled;

        //Add the icon
        _arenaIcon = new UnitArenaIcon(this);
        addSimObject(_arenaIcon);
//        DisplayUtil.centerOn(_arenaIcon.displayObject, location.x, location.y);

        //Add the action seqeuence
        actions = new ActionSequence(this);
        addSceneObject(actions, _arenaIcon.displayObject as Sprite);
//        actions.x = _arenaIcon.width / 2;
//        actions.y = _arenaIcon.height / 2 + 50;
        _health = profile.maxHealth;
        energy = profile.stamina;
        maxEnergy = profile.stamina;
        setupUI();
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        destroySimObject(_arenaIcon);
        destroySimObject(actions);
    }

    public function get arenaIcon () :UnitArenaIcon
    {
        return _arenaIcon;
    }

    public function setTarget (unit :UnitRecord) :void
    {
        target = unit;
//        if (unit == null) {
//            DisplayUtil.detach(_targetReticle.displayObject);
//        }
//        else {
//            trace(name + " setting target " + unit.name);
//            Sprite(unit.arenaIcon.displayObject).addChild(_targetReticle.displayObject);
//        }
    }



    override protected function addedToDB () :void
    {
        trace("CombatUnitInfo added to db");
        super.addedToDB();

    }

//    public function setUnitLocation (x :Number, y :Number) :void
//    {
//        location.x = x;
//        location.y = y;
//        _arenaIcon.x = x;
//        _arenaIcon.y = y;
//    }

    protected function setupUI () :void
    {
        _displaySprite.graphics.beginFill(0xffffff);
        _displaySprite.graphics.drawRect(-50, -60, 120, 120);
        _displaySprite.graphics.endFill();

        _displaySprite.addChild(_bars);
        _bars.y = -40;

        redrawBars();

        DisplayUtil.drawText(_displaySprite, name, 0, -58);
//        DisplayUtil.drawText(_displaySprite, "Type:" + profile.type, 0, 30);

//        var s :Sprite = new Sprite();
//        var g :Graphics = s.graphics;
//        g.lineStyle(4, 0xff0000, 0.5);
//        g.drawCircle(0, 0, 20);
//        _targetReticle = new SimpleSceneObject(s);
//        addSimObject(_targetReticle);
    }

//    protected function drawHealth () :void
//    {
//        var barWidth :int = 40;
//        var barHeight :int = 10;
//        _bars.graphics.clear();
//        _bars.graphics.beginFill(0xff0000);
//        _bars.graphics.drawRect(-barWidth/2, 0, barWidth*health/profile.maxHealth, barHeight);
//        _bars.graphics.endFill();
//        _bars.graphics.lineStyle(1, 0xff0000);
//        _bars.graphics.drawRect(-barWidth/2, 0, barWidth, barHeight);
//    }

    public function set health (value :Number) :void
    {
        _health = value;
        _health = Math.max(value, 0);
        redrawBars();
    }



    protected function redrawBars () :void
    {
        _bars.graphics.clear();
        var textX :int = -50;
        DisplayUtil.removeAllChildren(_bars);
        var startY :int = 0;
        //Health
        DisplayUtil.drawText(_bars, "Health", textX, startY);
        drawBar(_bars.graphics, 0, startY, 0xff0000, health, profile.maxHealth);

        startY += 12;
        DisplayUtil.drawText(_bars, "Strength", textX, startY);
        drawBar(_bars.graphics, 0, startY, 0xff0000, profile.strength, profile.strength);

        startY += 12;
        DisplayUtil.drawText(_bars, "Speed", textX, startY);
        drawBar(_bars.graphics, 0, startY, 0xff0000, profile.speed, profile.speed);

        startY += 12;
        DisplayUtil.drawText(_bars, "Stamina", textX, startY);
        drawBar(_bars.graphics, 0, startY, 0xff0000, profile.stamina, profile.stamina);

        startY += 12;
        DisplayUtil.drawText(_bars, "Mind", textX, startY);
        drawBar(_bars.graphics, 0, startY, 0xff0000, profile.mind, profile.mind);

        startY += 12;
        DisplayUtil.drawText(_bars, "Energy", textX, startY);
        drawBar(_bars.graphics, 0, startY, 0xff9821, energy, profile.stamina);
    }

    protected static function drawBar (g :Graphics, x :int, y :int, color :int, value :Number, maxValue :Number, barHeight :int = 10) :void
    {
        g.beginFill(color);
        g.drawRect(x, y, value, barHeight);
        g.endFill();
        g.lineStyle(1, color);
        g.drawRect(x, y, maxValue, barHeight);
    }

    public function get health () :Number
    {
        return _health;
    }

    public function set energy (value :Number) :void
    {
//        trace("setting energy " + value);
        _energy = value;
        _energy = MathUtil.clamp(_energy, 0, profile.stamina);
        redrawBars();
    }

    public function get energy () :Number
    {
        return _energy;
    }

    override public function toString () :String
    {
        return "Profile=" + profile
//            + "\nhealth=" + _health + "/" + profile.maxHealth
//            + "\ncontrollingPlayer=" + controllingPlayer
            + "\nname=" + name
//            + "\nenergy=" + energy + "/" + maxEnergy
////            + "\ncurrentAction=" + currentAction
////            + "\nnextActions=" + nextActions
//            + "\nTeam=" + team
//            + "\nTeam=" + team

    }

    public function get isRangedWeapon () :Boolean
    {
        for each (var weaponId :int in profile.weaponDefault) {
            if (Weapon.range(weaponId) == LocationHandler.RANGED) {
                return true;
            }
        }
        return false;
    }

//    protected var _targetReticle :SceneObject;
    public var profile :UnitProfile;

    public var target :UnitRecord;
    public var team :int;
    public var range :int = LocationHandler.CLOSE;
    public var controllingPlayer :int;
    public var name :String;
    public var items :Items;
//    public var location :Point = new Point();
    protected var _energy :Number;
    public var maxEnergy :Number;
//    public var avatarState :String;
    public var actions :ActionSequence;
//    public var currentAction :int;
//    public var nextActions :Array = [];
    protected var _health :Number;

    protected var _bars :Sprite = new Sprite();

    protected var _arenaIcon :UnitArenaIcon;

    public var playerControlled :Boolean;
}
}