//
// $Id$

package {

import com.whirled.game.GameControl;

import flash.display.Sprite;

import display.BoardSprite;

[SWF(width="700", height="500")]
public class Platformer extends Sprite
{
    public function Platformer ()
    {
        var gameControl :GameControl = new GameControl(this, false);
        if (gameControl.game.isConnected()) {
            gameControl.local.setShowButtons(false, false);

            var controller :Controller = new Controller(gameControl);
            controller.init(function () :void {
                addChild(controller.getSprite());
                controller.run();
            });
        }
    }
}
}
