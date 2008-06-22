//
// $Id$

package dictattack {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.Event;

import com.threerings.util.Log;

import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

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
        _ctx = new Context(new GameControl(this, false), new Content(maybeFinishInit));
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_STARTED, gameDidStart);
        _ctx.control.game.addEventListener(StateChangedEvent.ROUND_STARTED, roundDidStart);
        _ctx.control.game.addEventListener(StateChangedEvent.ROUND_ENDED, roundDidEnd);
        _ctx.control.game.addEventListener(StateChangedEvent.GAME_ENDED, gameDidEnd);
        _ctx.control.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, coinsAwarded);

        // make our background totally black
        opaqueBackground = 0x000000;
        var size :Point = _ctx.control.isConnected() ?
            _ctx.control.local.getSize() : new Point(1000, 550);
        graphics.drawRect(0, 0, size.x, size.y);

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
            _ctx.control.game.seating.getPlayerIds().length : 4;

        // create our model and our view, and initialize them
        _ctx.init(new Model(Content.BOARD_SIZE, _ctx), new GameView(_ctx));
        _ctx.view.init(pcount);
        addChild(_ctx.view);

        // now that we're actually ready, go ahead and request that the game start
        if (_ctx.control.isConnected()) {
            _ctx.control.game.playerReady();
            // also load up our user cookie
            _ctx.control.player.getCookie(gotUserCookie);
        } else {
            _ctx.view.attractMode();
        }
    }

    protected function gameDidStart (event :StateChangedEvent) :void
    {
        _coinsAward = 0;
        _ctx.view.gameDidStart();
        _ctx.model.gameDidStart();

        // zero out the scores
        var pcount :int = _ctx.control.game.seating.getPlayerIds().length;
        if (_ctx.control.game.amInControl()) {
            _ctx.control.net.
                set(Model.SCORES, new Array(pcount).map(function (): int { return 0; }));
        }
    }

    protected function roundDidStart (event :StateChangedEvent) :void
    {
        _ctx.model.roundDidStart();
        _ctx.view.roundDidStart();
    }

    protected function roundDidEnd (event :StateChangedEvent) :void
    {
        _ctx.model.roundDidEnd();
        _ctx.view.roundDidEnd();
    }

    protected function coinsAwarded (event :CoinsAwardedEvent) :void
    {
        _coinsAward = event.amount;
        _ctx.control.local.feedback("You earned " + _coinsAward + " coins!");
    }

    protected function gameDidEnd (event :StateChangedEvent) :void
    {
        roundDidEnd(event);

        _ctx.model.gameDidEnd();
        // _coinsAward is set via a COINS_AWARDED event that precedes the GAME_ENDED event
        _ctx.view.gameDidEnd(_coinsAward);

        // if we were not a player, stop here
        var myidx :int = _ctx.control.game.seating.getMyPosition();
        if (myidx < 0) {
            return;
        }

        // check for multiplayer trophies
        if (_ctx.model.isMultiPlayer()) {
            var scores :Array = (_ctx.control.net.get(Model.SCORES) as Array);
            var myscore :int = scores[myidx], oscores :int = 0;
            for (var pidx :int = 0; pidx < scores.length; pidx++) {
                if (pidx != myidx) {
                    oscores += int(scores[pidx]);
                }
            }

            // if we swept the game (no one else scored and we scored at least once)
            if (oscores == 0 && myscore > 0) {
                _ctx.control.player.awardTrophy("multi_sweep_" + scores.length);
            }
            return;
        }

        // in single player games we update high scores and award trophies
        var points :Array = (_ctx.control.net.get(Model.POINTS) as Array);
        var mypoints :int = points[myidx];

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
            if (!_ctx.control.player.setCookie(_cookie)) {
                Log.getLog(this).warning("Failed to save cookie " + _cookie + ".");
            }
        }

        // check for total score related trophies
        for each (var score :int in SCORE_AWARDS) {
            if (mypoints > score && !_ctx.control.player.holdsTrophy("score_over_" + score)) {
                _ctx.control.player.awardTrophy("score_over_" + score);
                break;
            }
        }

        // check for consecutive score related trophies
        for each (var cdata :Array in CONSECUTIVE_POINTS) {
            if (_ctx.model.checkConsecutivePoints(int(cdata[0]), int(cdata[1]))) {
                _ctx.control.player.awardTrophy("consec_points_" + cdata[0] + "_" + cdata[1]);
                break;
            }
        }

        // check for timed score trophies
        if (!_ctx.model.getEndedEarly()) {
            for each (var adata :Array in TIMED_AWARDS) {
                var ascore :int = int(adata[0]);
                var aseconds :int = int(adata[1]);
                var tname :String = ascore + "_in_" + aseconds;
                if (int(_ctx.model.getGameDuration() / 1000) <= aseconds &&
                    mypoints > ascore && !_ctx.control.player.holdsTrophy(tname)) {
                    _ctx.control.player.awardTrophy(tname);
                    break;
                }
            }
        }

        // check for perfect clear trophies
        switch (_ctx.model.unusedLetters()) {
        case 0:
            _ctx.control.player.awardTrophy("perfect_vacuum");
            break;
        case 1:
            _ctx.control.player.awardTrophy("near_vacuum");
            break;
        }

        // check for long word only trophies
        if (!_ctx.model.getEndedEarly()) {
            var wlengths :Array = _ctx.model.getWordCountsByLength();
            var wcount :int = 0;
            for (var ll :int = _ctx.model.getMinWordLength(); ll <= MAX_BYLENGTH_LENGTH; ll++) {
                if (ll >= MIN_BYLENGTH_LENGTH && wcount == 0) {
                    _ctx.control.player.awardTrophy("all_length_" + ll);
                }
                wcount += int(wlengths[ll]);
            }
        }

        // check for special trophies
        var perfectClear :Boolean = (_ctx.model.nonEmptyColumns() == 0);
        if (perfectClear && _ctx.model.getNotOnBoardPlays() == 0) {
            _ctx.control.player.awardTrophy("no_not_on_board");
        }
        if (perfectClear && _ctx.model.getNotInDictPlays() == 0) {
            _ctx.control.player.awardTrophy("no_not_in_dict");
        }
        if (_ctx.model.playedWord("dictionary") && _ctx.model.playedWord("attack")) {
            _ctx.control.player.awardTrophy("dictionary_attack");
        }
        if (_ctx.model.playedWord("three") && _ctx.model.playedWord("rings")) {
            _ctx.control.player.awardTrophy("three_rings");
        }
    }

    protected function handleUnload (event :Event) :void
    {
        // TODO: clean up things that need cleaning up
    }

    protected function gotUserCookie (cookie :Object, ...unused) :void
    {
        _cookie = (cookie == null) ? new Object() : cookie;
        _ctx.view.gotUserCookie(_cookie);
    }

    protected var _ctx :Context;
    protected var _cookie :Object;
    protected var _coinsAward :int;

    protected static const LONG_WORD :int = 8;
    protected static const MAX_HISCORES :int = 4;

    protected static const SCORE_AWARDS :Array = [60, 50, 40, 30, 20];
    protected static const TIMED_AWARDS :Array = [[50, 150], [40, 120], [30, 105], [20, 90]];
    protected static const CONSECUTIVE_POINTS :Array = [[3, 40], [5, 30], [3, 30]];

    protected static const MIN_BYLENGTH_LENGTH :int = 5;
    protected static const MAX_BYLENGTH_LENGTH :int = 6;
}
}
