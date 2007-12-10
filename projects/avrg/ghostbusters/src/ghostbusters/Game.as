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
    public static var log :Log = Log.getLog(Game);

    public function Game ()
    {
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        _control = new AVRGameControl(this);

        addChild(_panel);
        _model.init(_panel);

        _control.setMobSpriteExporter(_panel.exportMobSprite);
        _control.setHitPointTester(_panel.hitTestPoint);

        // TODO: this is just while debugging
        _control.despawnMob("ghost");
    }

    protected function handleUnload (event :Event) :void
    {
        _controller.shutdown();
        _panel.shutdown();
        _model.shutdown();
    }

    protected var _control :AVRGameControl;

    protected var _model :GameModel;
    protected var _panel :GamePanel;
    protected var _controller :GameController;
}
}
