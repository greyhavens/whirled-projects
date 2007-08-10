//
// $Id$

package dictattack {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;

/**
 * Used to display a popup dialog.
 */
public class Dialog extends Sprite
{
    public static const LEFT :int = 0;
    public static const RIGHT :int = 1;
    public static const CENTER :int = 2;

    public function Dialog (content :DisplayObject)
    {
        content.x = BORDER;
        content.y = BORDER;
        addChild(_content = content);
    }

    public function addButton (button :SimpleButton, position :int) :void
    {
        switch (position) {
        case LEFT:
            button.x = BORDER;
            break;
        case RIGHT:
            button.x = BORDER + _content.width - button.width;
            break;
        case CENTER:
            button.x = BORDER + (_content.width - button.width)/2;
            break;
        }
        button.y = BORDER + _content.height + BORDER;
        addChild(button);
    }

    public function show (view :GameView) :void
    {
        // draw a background and border around our bits
        graphics.beginFill(uint(0x222222));
        graphics.lineStyle(2, 0xCCCCCC);
        graphics.drawRect(0, 0, width + 2*BORDER, height + 2*BORDER);
        graphics.endFill();

        x = Content.BOARD_BORDER + (view.getBoard().getPixelSize() - width)/2;
        y = Content.BOARD_BORDER + (view.getBoard().getPixelSize() - height)/2;
        view.addChild(this);
    }

    protected var _content :DisplayObject;

    protected static const BORDER :int = 5;
}
}
