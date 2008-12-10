package redrover.game.view {

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

        addTask(new RepeatingTask(
            ScaleTask.CreateEaseIn(1.8, 1.8, 0.4),
            ScaleTask.CreateEaseOut(1.2, 1.2, 0.4)));

        updateView();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function updateView () :void
    {
        //_sprite.alpha = (_teamId == GameContext.localPlayer.teamId ? 0.25 : 1);
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
}

}
