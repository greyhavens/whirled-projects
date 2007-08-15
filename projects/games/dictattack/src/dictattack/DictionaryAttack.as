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

        // create our model and our view, and initialize them
        _model = new Model(Content.BOARD_SIZE, _control);
        _view = new GameView(_control, _model, _content);
        _view.init(pcount);
        addChild(_view);

        // now that we're actually ready, go ahead and request that the game start
        if (_control.isConnected()) {
            _control.playerReady();
            // also load up our user cookie
            _control.getUserCookie(_control.getMyId(), gotUserCookie);
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
        var mypoints :int = -1;
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
            var letters :int = _model.getLetterCount();
            var minpoints :int = Math.round(letters / _model.getMinWordLength());
            var maxpoints :int = Math.round(letters / LONG_WORD) *
                (LONG_WORD - _model.getMinWordLength() + 1);
            mypoints = points[myidx];
            Log.getLog(this).info("Min: " + minpoints + " max: " + maxpoints +
                                  " points: " + mypoints + ".");
            // TODO: bonus for perfectly cleared single player board, record high scores, etc.
//             factor = (mypoints - minpoints) / (maxpoints - minpoints);
            // for now do straight points over maxpoints until we stop penalizing for * usage
            factor = mypoints / maxpoints;

            // also update their personal high scores
            if (_cookie != null) {
                var hiscores :Array = _cookie["highscores"] as Array;
                if (hiscores == null) {
                    hiscores = new Array();
                }

                // add our score onto the list, sort it and prune it
                hiscores.push([ points, new Date().getTime() ]);
                hiscores.sort(function (one :Array, two :Array) :int {
                    return int(two[0]) - int(one[0]);
                });
                _cookie["highscores"] = hiscores.slice(0, Math.min(hiscores.length, MAX_HISCORES));

                // update our highscore display and save our high score
                _view.gotUserCookie(_cookie);
                if (!_control.setUserCookie(_cookie)) {
                    Log.getLog(this).warning("Failed to save cookie " + _cookie + ".");
                }
            }
        }

        var award :int = _control.grantFlowAward(factor * 100);
        Log.getLog(this).info("Factor: " + factor + " award: " + award);
        _view.gameDidEnd(award, mypoints);
    }

    protected function handleUnload (event :Event) :void
    {
        // TODO: clean up things that need cleaning up
    }

    protected function gotUserCookie (cookie :Object) :void
    {
        _cookie = (cookie == null) ? new Object() : cookie;
        _view.gotUserCookie(_cookie);
    }

    protected var _control :WhirledGameControl;
    protected var _model :Model;
    protected var _view :GameView;
    protected var _content :Content;
    protected var _cookie :Object;

    [Embed(source="../../rsrc/invaders.swf", mimeType="application/octet-stream")]
    protected var CONTENT :Class;

    protected static const LONG_WORD :int = 8;
    protected static const MAX_HISCORES :int = 4;
}
}
