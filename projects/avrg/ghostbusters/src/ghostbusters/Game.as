//
// $Id$

package ghostbusters {

import flash.display.Sprite;

import flash.events.Event;

import com.whirled.AVRGameControl;

import com.threerings.util.Log;

[SWF(width="700", height="500")]
public class Game extends Sprite
{
    public static const DEBUG :Boolean = false;

    public static var log :Log = Log.getLog(Game);

    public function Game ()
    {
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        _control = new AVRGameControl(this);

        _controller = new GameController(_control);

        var panel :GamePanel = _controller.getGamePanel();
        addChild(panel);

        _control.setMobSpriteExporter(panel.exportMobSprite);
        _control.setHitPointTester(panel.hitTestPoint);

        // TODO: this is just while debugging
        _control.despawnMob("ghost");

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
    }

    protected function handleUnload (event :Event) :void
    {
        _controller.shutdown();
    }

    protected function handleAdded (event :Event) :void
    {
        _controller.enterState(GameModel.STATE_INTRO);
    }

    protected var _control :AVRGameControl;

    protected var _controller :GameController;
}
}
