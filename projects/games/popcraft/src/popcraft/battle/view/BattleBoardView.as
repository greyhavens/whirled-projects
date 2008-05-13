package popcraft.battle.view {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.AlphaTask;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.*;
import popcraft.net.*;

public class BattleBoardView extends SceneObject
{
    public static const TILE_GROUND :uint = 0;
    public static const TILE_TREE :uint = 1;
    public static const TILE_BASE :uint = 2;

    public function BattleBoardView (width :int, height :int)
    {
        _width = width;
        _height = height;

        _view = new Sprite();

        // the darkness is shown during nighttime
        var darknessShape :Shape = new Shape();
        var g :Graphics = darknessShape.graphics;
        g.beginFill(0, 0.7);
        g.drawRect(0, 0, width, height);
        g.endFill();
        _darkness = new SimpleSceneObject(darknessShape);
        _darkness.alpha = 0;

        var bg :Bitmap = (ResourceManager.instance.getResource("battle_bg") as ImageResourceLoader).createBitmap();
        bg.scaleX = (_width / bg.width);
        bg.scaleY = (_height / bg.height);

        var fg :Bitmap = (ResourceManager.instance.getResource("battle_fg") as ImageResourceLoader).createBitmap();
        fg.scaleX = (_width / fg.width);
        fg.y = bg.height - fg.height; // fg is aligned to the bottom of the board

        _view.addChild(bg);
        _view.addChild(_darkness.displayObject);
        _view.addChild(_spellDropViewParent);
        _view.addChild(_unitViewParent);
        _view.addChild(fg);

        _lastDayPhase = (DiurnalCycle.isDisabled ? Constants.PHASE_NIGHT : GameContext.gameData.initialDayPhase);
        _darkness.alpha = (_lastDayPhase == Constants.PHASE_NIGHT ? 1 : 0);
    }

    override protected function addedToDB () :void
    {
        this.db.addObject(_darkness);
    }

    override protected function removedFromDB () :void
    {
        this.db.destroyObject(_darkness.ref);
    }

    override protected function update (dt :Number) :void
    {
        var newDayPhase :uint = GameContext.diurnalCycle.phaseOfDay;
        if (newDayPhase != _lastDayPhase) {
            this.animateDayPhaseChange(newDayPhase);
            _lastDayPhase = newDayPhase;
        }
    }

    protected function animateDayPhaseChange (phase :uint) :void
    {
        if (phase == Constants.PHASE_DAY) {
            _darkness.alpha = 1;
            _darkness.addTask(new AlphaTask(0, 2));
        } else {
            _darkness.alpha = 0;
            _darkness.addTask(new AlphaTask(1, 2));
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _view;
    }

    public function get spellDropViewParent () :DisplayObjectContainer
    {
        return _spellDropViewParent;
    }

    public function get unitViewParent () :DisplayObjectContainer
    {
        return _unitViewParent;
    }

    public function sortUnitDisplayChildren () :void
    {
        DisplayUtil.sortDisplayChildren(_unitViewParent, displayObjectYSort);
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

    protected var _width :int;
    protected var _height :int;
    protected var _view :Sprite;
    protected var _darkness :SceneObject;
    protected var _spellDropViewParent :Sprite = new Sprite();
    protected var _unitViewParent :Sprite = new Sprite();
    protected var _lastDayPhase :uint;
}

}
