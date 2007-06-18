//
// $Id$

package dictattack {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;

import flash.events.Event;
import flash.utils.ByteArray;

import com.threerings.ezgame.StateChangedEvent;
import com.threerings.util.EmbeddedSwfLoader;

import com.whirled.WhirledGameControl;

[SWF(width="1000", height="550")]
public class DictionaryAttack extends Sprite
{
    /**
     * Creates and initializes our game.
     */
    public function DictionaryAttack ()
    {
        // wire up our unloader
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // create and wire ourselves into our multiplayer game control
        _control = new WhirledGameControl(this);
        _control.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _control.addEventListener(StateChangedEvent.ROUND_STARTED, roundDidStart);
        _control.addEventListener(StateChangedEvent.ROUND_ENDED, roundDidEnd);
        _control.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);

        // load up our content pack
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, finishInit);
        _content = new Content(loader);
        loader.load(ByteArray(new CONTENT()));

        // make our background totally black
        opaqueBackground = 0x000000;
        var bounds :Rectangle = _control.getStageBounds();
        if (bounds == null) {
            bounds = new Rectangle(0, 0, 1000, 550);
        }
        graphics.drawRect(0, 0, bounds.width, bounds.height);
    }

    protected function finishInit (event :Event) :void
    {
        // TODO: get this info from the game config
        var size :int = Content.BOARD_SIZE;
        var pcount :int = _control.isConnected() ? _control.seating.getPlayerIds().length : 4;

        // create our model and our view, and initialize them
        _model = new Model(size, _control);
        _view = new GameView(_control, _model, _content);
        _view.init(size, pcount);
        addChild(_view);

        // if the game was already started but we weren't ready yet, start now (TODO: allow us to
        // delay our playerReady() until we're actually ready...)
        if (_control.isInPlay()) {
            gameDidStart(null);
        }
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        if (_view == null) {
            return; // we'll get recalled when the view is ready
        }
        _view.gameDidStart();

        // zero out the scores
        var pcount :int = _control.seating.getPlayerIds().length;
        if (_control.amInControl()) {
            _control.set(Model.SCORES, new Array(pcount).map(function (): int { return 0; }));
        }
    }

    protected function roundDidStart (event :StateChangedEvent) :void
    {
        _model.roundDidStart();
        _view.roundDidStart();
    }

    protected function roundDidEnd (event :StateChangedEvent) :void
    {
        _view.roundDidEnd();
        var scorer :String = _model.roundDidEnd();
        _view.marquee.display("Round over. Point to " + scorer + ".", 2000);
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        roundDidEnd(event);

        // grant ourselves flow based on how many players we defeated
        var scores :Array = (_control.get(Model.SCORES) as Array);
        var myidx :int = _control.seating.getMyPosition();
        var beat :int = 0;
        for (var ii :int = 0; ii < scores.length; ii++) {
            if (ii != myidx && scores[ii] < scores[myidx]) {
                beat++;
            }
        }
        var factor :Number = ((0.5/3) * beat + 0.5);
        var award: int = int(factor * _control.getAvailableFlow());
        trace("Defeated: " + beat + " factor: " + factor + " award: " + award);
        if (award > 0) {
            _control.awardFlow(award);
        }

        _view.gameDidEnd(award);
    }

    protected function handleUnload (event :Event) :void
    {
        // TODO: clean up things that need cleaning up
    }

    protected var _control :WhirledGameControl;
    protected var _model :Model;
    protected var _view :GameView;
    protected var _content :Content;

    [Embed(source="../../rsrc/invaders.swf", mimeType="application/octet-stream")]
    protected var CONTENT :Class;
}

}
