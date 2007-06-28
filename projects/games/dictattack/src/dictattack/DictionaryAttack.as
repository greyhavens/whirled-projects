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
        _control = new WhirledGameControl(this, false);
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
        var bounds :Rectangle = _control.isConnected() ?
            _control.getStageBounds() : new Rectangle(0, 0, 1000, 550);
        graphics.drawRect(0, 0, bounds.width, bounds.height);
    }

    protected function finishInit (event :Event) :void
    {
        var pcount :int = _control.isConnected() ? _control.seating.getPlayerIds().length : 4;
        // TODO: get this info from the game config
        var size :int = (pcount == 1) ? Content.SINGLE_BOARD_SIZE : Content.BOARD_SIZE;

        // create our model and our view, and initialize them
        _model = new Model(size, _control);
        _view = new GameView(_control, _model, _content);
        _view.init(size, pcount);
        addChild(_view);

        // now that we're actually ready, go ahead and request that the game start
        if (_control.isConnected()) {
            _control.playerReady();
        } else {
            _view.attractMode();
        }
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
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
        var scorer :String = _model.roundDidEnd();
        _view.roundDidEnd(scorer);
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        roundDidEnd(event);

        // grant ourselves flow
        var myidx :int = _control.seating.getMyPosition();
        var factor :Number = 0;
        if (_model.isMultiPlayer()) {
            // if it's multiplayer, it's based on how many players we defeated
            var scores :Array = (_control.get(Model.SCORES) as Array);
            var beat :int = 0;
            for (var ii :int = 0; ii < scores.length; ii++) {
                if (ii != myidx && scores[ii] < scores[myidx]) {
                    beat++;
                }
            }
            factor = ((0.5/3) * beat + 0.5);
            Log.getLog(this).info("Defeated: " + beat);

        } else {
            // single player is based on how well we cleared the board; 25% of available flow for
            // getting all minimum length words, 100% of available flow for getting all LONG_WORD
            // letter words (with bonuses helping players to approach that score)
            var points :Array = (_control.get(Model.POINTS) as Array);
            var letters :int = _model.getBoardSize() * _model.getBoardSize();
            var minpoints :int = Math.round(letters / _model.getMinWordLength());
            var maxpoints :int = Math.round(letters / LONG_WORD) *
                (LONG_WORD - _model.getMinWordLength() + 1);
            Log.getLog(this).info("Min: " + minpoints + " max: " + maxpoints +
                                  " points: " + points[myidx] + ".");
            // TODO: bonus for perfectly cleared single player board, record high scores, etc.
//             factor = (points[myidx] - minpoints) / (maxpoints - minpoints);
            // for now do straight points over maxpoints until we stop penalizing for * usage
            factor = points[myidx] / maxpoints;
        }

        var award :int = int(factor * _control.getAvailableFlow());
        Log.getLog(this).info("Factor: " + factor + " award: " + award);
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

    protected static const LONG_WORD :int = 8;
}
}
