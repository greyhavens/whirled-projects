package redrover.game.view {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class GemView extends SceneObject
{
    public function GemView (gemType :int, teamId :int, boardCell :BoardCell)
    {
        _boardCell = boardCell;
        _teamId = teamId;

        var gem :DisplayObject = GemViewFactory.createGem(GameContext.levelData.cellSize - 12,
                                                          gemType);
        gem.x = -gem.width * 0.5;
        gem.y = -gem.height * 0.6;

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(gem);

        // center the GemView in its cell
        this.x = _boardCell.ctrPixelX;
        this.y = _boardCell.ctrPixelY;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function updateView () :void
    {
        _sprite.alpha = (_teamId == GameContext.localPlayer.teamId ? 0.5 : 1);

        // all gems scale simultaneously
        if (_gemPulser.isNull) {
            var gemPulserObj :SimObject = new SceneObject();
            gemPulserObj.addTask(new RepeatingTask(
                AnimateValueTask.CreateEaseIn(_gemScale, SCALE_HI, 0.4),
                AnimateValueTask.CreateEaseOut(_gemScale, SCALE_LO, 0.4)));
            _gemPulser = this.db.addObject(gemPulserObj);
        }

        var scale :Number = _gemScale.value;
        _sprite.scaleX = scale;
        _sprite.scaleY = scale;
    }

    override protected function update (dt :Number) :void
    {
        if (!_boardCell.hasGem) {
            destroySelf();
        } else {
            updateView();
        }
    }

    protected var _boardCell :BoardCell;
    protected var _teamId :int;
    protected var _sprite :Sprite;

    protected static var _gemScale :Object = { value: SCALE_LO };
    protected static var _gemPulser :SimObjectRef = SimObjectRef.Null();

    protected static const SCALE_LO :Number = 1.2;
    protected static const SCALE_HI :Number = 2.2;
}

}
