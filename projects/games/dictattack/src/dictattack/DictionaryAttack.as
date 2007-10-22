//
// $Id$

package dictattack {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;

import flash.events.Event;

import com.threerings.ezgame.StateChangedEvent;

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

        // we use this function to wait for our various bits to complete
        var initComplete :int = 0;
        var maybeFinishInit :Function = function () :void {
            if (++initComplete == 2) {
                finishInit();
            }
        };

        // create and wire ourselves into our multiplayer game control (and create our content)
        _ctx = new Context(new WhirledGameControl(this, false), new Content(maybeFinishInit));
        _ctx.control.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _ctx.control.addEventListener(StateChangedEvent.ROUND_STARTED, roundDidStart);
        _ctx.control.addEventListener(StateChangedEvent.ROUND_ENDED, roundDidEnd);
        _ctx.control.addEventListener(FlowAwardedEvent.FLOW_AWARDED, flowAwarded);
        _ctx.control.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);

        // make our background totally black
        opaqueBackground = 0x000000;
        var bounds :Rectangle = _ctx.control.isConnected() ?
            _ctx.control.getStageBounds() : new Rectangle(0, 0, 1000, 550);
        graphics.drawRect(0, 0, bounds.width, bounds.height);

        // show our splash screen
        var splash :SplashView = new SplashView(this, function () :void {
            removeChild(splash);
            maybeFinishInit();
        });
        addChild(splash);
    }

    protected function finishInit () :void
    {
        var pcount :int = _ctx.control.isConnected() ?
            _ctx.control.seating.getPlayerIds().length : 4;

        // create our model and our view, and initialize them
        _ctx.init(new Model(Content.BOARD_SIZE, _ctx), new GameView(_ctx));
        _ctx.view.init(pcount);
        addChild(_ctx.view);

        // now that we're actually ready, go ahead and request that the game start
        if (_ctx.control.isConnected()) {
            _ctx.control.playerReady();
            // also load up our user cookie
            _ctx.control.getUserCookie(_ctx.control.getMyId(), gotUserCookie);
        } else {
            _ctx.view.attractMode();
        }
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _flowAward = 0;
        _ctx.view.gameDidStart();

        // zero out the scores
        var pcount :int = _ctx.control.seating.getPlayerIds().length;
        if (_ctx.control.amInControl()) {
            _ctx.control.set(Model.SCORES, new Array(pcount).map(function (): int { return 0; }));
        }
    }

    protected function roundDidStart (event :StateChangedEvent) :void
    {
        _ctx.model.roundDidStart();
        _ctx.view.roundDidStart();
    }

    protected function roundDidEnd (event :StateChangedEvent) :void
    {
        var scorer :String = _ctx.model.roundDidEnd();
        _ctx.view.roundDidEnd(scorer);
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
        if (!_ctx.model.isMultiPlayer()) {
            var points :Array = (_ctx.control.get(Model.POINTS) as Array);
            mypoints = points[_ctx.control.seating.getMyPosition()];

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
                _ctx.view.gotUserCookie(_cookie);
                if (!_ctx.control.setUserCookie(_cookie)) {
                    Log.getLog(this).warning("Failed to save cookie " + _cookie + ".");
                }
            }

            // see if we qualify for any end-of-game trophies
            for each (var score :int in SCORE_AWARDS) {
                if (mypoints > score && !_ctx.control.holdsTrophy("score_over_" + score)) {
                    _ctx.control.awardTrophy("score_over_" + score);
                    break;
                }
            }
            var perfectClear :Boolean = (_ctx.model.nonEmptyColumns() == 0);
            if (perfectClear && _ctx.model.getNotOnBoardPlays() == 0) {
                if (!_ctx.control.holdsTrophy("no_not_on_board")) {
                    _ctx.control.awardTrophy("no_not_on_board");
                }
            }
            if (perfectClear && _ctx.model.getNotInDictPlays() == 0) {
                if (!_ctx.control.holdsTrophy("no_not_in_dict")) {
                    _ctx.control.awardTrophy("no_not_in_dict");
                }
            }
        }

        // _flowAward is set via a FLOW_AWARDED event that precedes the GAME_ENDED event
        _ctx.view.gameDidEnd(_flowAward);
    }

    protected function handleUnload (event :Event) :void
    {
        // TODO: clean up things that need cleaning up
    }

    protected function gotUserCookie (cookie :Object) :void
    {
        _cookie = (cookie == null) ? new Object() : cookie;
        _ctx.view.gotUserCookie(_cookie);
    }

    protected var _ctx :Context;
    protected var _cookie :Object;
    protected var _flowAward :int;

    protected static const LONG_WORD :int = 8;
    protected static const MAX_HISCORES :int = 4;

    protected static const SCORE_AWARDS :Array = [60, 50, 40, 30, 20];
}
}
