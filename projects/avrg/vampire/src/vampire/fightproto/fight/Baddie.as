package vampire.fightproto.fight {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.fightproto.*;

public class Baddie extends SceneObject
{
    public static function getSelectedBaddie () :Baddie
    {
        for each (var baddie :Baddie in GameCtx.mode.getObjectsInGroup("Baddie")) {
            if (baddie.isSelected) {
                return baddie;
            }
        }

        return null;
    }

    public static function areBaddiesAlive () :Boolean
    {
        return (GameCtx.mode.getObjectsInGroup("Baddie").length > 0);
    }

    public function Baddie (desc :BaddieDesc)
    {
        _desc = desc;
        _curHealth = desc.health;

        _sprite = new Sprite();

        var baddieSprite :Sprite = desc.createSprite();
        baddieSprite.x = -baddieSprite.width * 0.5;
        baddieSprite.y = -baddieSprite.height;
        _sprite.addChild(baddieSprite);

        _healthMeter = new RectMeterView();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _desc.health;
        _healthMeter.value = _curHealth;
        _healthMeter.foregroundColor = 0xff0000;
        _healthMeter.backgroundColor = 0xffffff;
        _healthMeter.outlineColor = 0;
        _healthMeter.meterWidth = 100;
        _healthMeter.meterHeight = 10;
        _healthMeter.updateDisplay();

        _healthMeter.x = -_healthMeter.width * 0.5;
        _healthMeter.y = baddieSprite.y - _healthMeter.height - 3;
        _sprite.addChild(_healthMeter);

        var arrowBitmap :Bitmap = ClientCtx.instantiateBitmap("selection_arrow");
        arrowBitmap.filters = [ new ColorMatrix().colorize(0xff0000).createFilter() ];
        _selectionArrow = new SimpleSceneObject(arrowBitmap);
        _selectionArrow.x = -_selectionArrow.width * 0.5;
        _selectionArrow.y = _healthMeter.y - _selectionArrow.height - 3;
        _selectionArrow.addTask(new RepeatingTask(
            LocationTask.CreateEaseOut(_selectionArrow.x, _selectionArrow.y - 15, 0.5),
            LocationTask.CreateEaseIn(_selectionArrow.x, _selectionArrow.y, 0.5)));
        GameCtx.mode.addSceneObject(_selectionArrow, _sprite);

        registerListener(_sprite, MouseEvent.MOUSE_DOWN,
            function (...ignored) :void {
                select();
            });

        beginCastNextSkill();
    }

    public function select () :void
    {
        if (!this.isSelected) {
            for each (var baddie :Baddie in this.db.getObjectsInGroup("Baddie")) {
                baddie._selectionArrow.visible = (baddie == this);
            }
        }
    }

    public function offsetHealth (offset :Number) :void
    {
        _curHealth = _curHealth + offset;
        _curHealth = Math.max(_curHealth, 0);
        _curHealth = Math.min(_curHealth, _desc.health);
    }

    public function get isSelected () :Boolean
    {
        return _selectionArrow.visible;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0:
            return "Baddie";

        default:
            return super.getObjectGroup(groupNum - 1);
        }
    }

    public function get curHealth () :int
    {
        return _curHealth;
    }

    protected function beginCastNextSkill () :void
    {
        var castTime :Number = _desc.skillCastTime.next();
        if (castTime > 0) {
            var nextSkill :BaddieSkill = _desc.chooseNextSkill();
            if (nextSkill != null) {
                addTask(After(castTime, new FunctionTask(
                    function () :void {
                        castSkill(nextSkill);
                        beginCastNextSkill();
                    })));
            }
        }
    }

    protected function castSkill (skill :BaddieSkill) :void
    {
        var damage :Number = skill.damageOutput.next();
        if (damage > 0) {
            ClientCtx.player.offsetHealth(-damage);
            GameCtx.mode.showSkillCastAnimation(skill, -damage, this, GameCtx.playerView);
        }

        var health :Number = skill.healOutput.next();
        if (health > 0) {
            offsetHealth(health);
            GameCtx.mode.showSkillCastAnimation(skill, health, this, this);
        }
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        _healthMeter.value = Math.max(_curHealth, 0);
        if (_healthMeter.needsDisplayUpdate) {
            _healthMeter.updateDisplay();
        }

        if (_curHealth <= 0) {
            die();
        }
    }

    override protected function removedFromDB () :void
    {
        _selectionArrow.destroySelf();
        super.removedFromDB();
    }

    protected function die () :void
    {
        destroySelf();

        var deadBaddie :DeadBaddie = new DeadBaddie(_desc);
        deadBaddie.x = this.x;
        deadBaddie.y = this.y;
        GameCtx.mode.addSceneObject(deadBaddie, GameCtx.characterLayer);
    }

    protected var _desc :BaddieDesc;
    protected var _curHealth :int;
    protected var _isSelected :Boolean;

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeterView;
    protected var _selectionArrow :SceneObject;
}

}

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Sprite;
import flash.display.DisplayObject;

import vampire.fightproto.*;

class DeadBaddie extends SceneObject
{
    public function DeadBaddie (desc :BaddieDesc)
    {
        _sprite = new Sprite();

        var baddieSprite :Sprite = desc.createSprite();
        baddieSprite.x = -baddieSprite.width * 0.5;
        baddieSprite.y = -baddieSprite.height;
        _sprite.addChild(baddieSprite);

        addTask(new SerialTask(
            new AlphaTask(0, 1.5),
            new SelfDestructTask()));
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}
