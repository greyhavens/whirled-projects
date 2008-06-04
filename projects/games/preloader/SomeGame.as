//
// $Id$

package {

import flash.display.Sprite;

import com.whirled.game.*;

[Frame(factoryClass="Preloader")]
public class SomeGame extends Sprite
{
    public function SomeGame ()
    {
    }

    public function init (game :GameControl) :void
    {
        _game = game;

        // draw a red circle so that we know we're loaded
        graphics.beginFill(0xFF0000);
        graphics.drawCircle(50, 50, 50);
        graphics.endFill();
    }

    protected var _game :GameControl;

    [Embed(source="huge_asset.xxx", mimeType="application/octet-stream")]
    protected static const HUGE_ASSET_1 :Class;
}
}
