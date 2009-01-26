package popcraft.battle.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;

import popcraft.*;
import popcraft.game.*;

public class BattlefieldSprite extends SceneObject
{
    public function BattlefieldSprite ()
    {
        _mapScaleXInv = GameCtx.mapScaleXInv;
        _mapScaleYInv = GameCtx.mapScaleYInv;
        _spriteScale = Math.max(_mapScaleXInv, _mapScaleYInv);
    }

    override protected function addedToDB () :void
    {
        if (GameCtx.scaleSprites) {
            scaleSprites();
        }
    }

    protected function scaleSprites () :void
    {
        var displayObject :DisplayObject = this.displayObject;
        if (null != displayObject) {
            displayObject.scaleX = _spriteScale;
            displayObject.scaleY = _spriteScale;
        }
    }

    override public function set x (val :Number) :void
    {
        super.x = val * _mapScaleXInv;
    }

    override public function set y (val :Number) :void
    {
        super.y = val * _mapScaleYInv;
    }

    protected function updateLoc (x :Number, y :Number) :void
    {
        super.x = x * _mapScaleXInv;
        super.y = y * _mapScaleYInv;
    }

    protected var _mapScaleXInv :Number;
    protected var _mapScaleYInv :Number;
    protected var _spriteScale :Number;

}

}
