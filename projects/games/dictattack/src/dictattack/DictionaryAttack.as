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

import com.whirled.FlowAwardedEvent;
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
        _control.addEventListener(FlowAwardedEvent.FLOW_AWARDED, flowAwarded);
        _control.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);

        // make our background totally black (actually 222222 as that's MSOY's black)
        opaqueBackground = 0x222222;
        var bounds :Rectangle = _control.isConnected() ?
            _control.getStageBounds() : new Rectangle(0, 0, 1000, 550);
        graphics.drawRect(0, 0, bounds.width, bounds.height);

        // show our splash screen
        var splash :SplashView = new SplashView(this, function () :void {
            removeChild(splash);
            maybeFinishInit(null);
        });
        addChild(splash);

        // load up our content pack
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, maybeFinishInit);
        _content = new Content(loader);
        loader.load(ByteArray(new CONTENT()));
    }

    protected function maybeFinishInit (event :Event) :void
    {
        if (++_initComplete == 2) {
            finishInit();
        }
    }

    protected function finishInit () :void
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
        _flowAward = 0;
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

    protected function flowAwarded (event :FlowAwardedEvent) :void
    {
        _flowAward = event.amount;
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        roundDidEnd(event);

        // note our score in non-multiplayer games
        var mypoints :int = -1;
        if (!_model.isMultiPlayer()) {
            var points :Array = (_control.get(Model.POINTS) as Array);
            mypoints = points[_control.seating.getMyPosition()];

            // update our personal high scores
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

            // see if we qualify for any end-of-game trophies
            for each (var score :int in SCORE_AWARDS) {
                if (mypoints > score && !_control.holdsTrophy("score_over_" + score)) {
                    _control.awardTrophy("score_over_" + score);
                    break;
                }
            }
            var perfectClear :Boolean = (_model.nonEmptyColumns() == 0);
            if (perfectClear && _model.getNotOnBoardPlays() == 0) {
                if (!_control.holdsTrophy("no_not_on_board")) {
                    _control.awardTrophy("no_not_on_board");
                }
            }
            if (perfectClear && _model.getNotInDictPlays() == 0) {
                if (!_control.holdsTrophy("no_not_in_dict")) {
                    _control.awardTrophy("no_not_in_dict");
                }
            }
        }

        // _flowAward is set via a FLOW_AWARDED event that precedes the GAME_ENDED event
        _view.gameDidEnd(_flowAward, mypoints);
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
    protected var _flowAward :int;
    protected var _initComplete :int;

    [Embed(source="../../rsrc/invaders.swf", mimeType="application/octet-stream")]
    protected var CONTENT :Class;

    protected static const LONG_WORD :int = 8;
    protected static const MAX_HISCORES :int = 4;

    protected static const SCORE_AWARDS :Array = [60, 50, 40, 30, 20];
}
}
