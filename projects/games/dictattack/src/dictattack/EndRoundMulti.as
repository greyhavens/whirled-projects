//
// $Id$

package dictattack {

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.text.TextField;

import flash.events.MouseEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * Displays the end of game information for a single player game.
 */
public class EndRoundMulti extends Dialog
{
    public function EndRoundMulti (ctx :Context)
    {
        super(ctx);

        var view :MovieClip = _ctx.content.createRoundOverMulti();
        setText(view, "duration", Util.millisToMinSec(_ctx.model.getRoundDuration()));

        var points :Array = (_ctx.control.net.get(Model.POINTS) as Array);
        var precs :Array = [];
        for (var pidx :int = 0; pidx < points.length; pidx++) {
            precs.push([pidx, points[pidx]]);
        }
        precs.sort(function (left :Array, right :Array) :Number {
            return int(right[1]) - int(left[1]);
        });

        for (var ii :int = 0; ii < precs.length; ii++) {
            pidx = precs[ii][0];
            if (points[pidx] < _ctx.model.getWinningPoints()) {
                removeViewChild(view, "winner" + ii);
            }
            setText(view, "player_name" + ii, _ctx.model.getPlayerName(pidx, MAX_NAME_LENGTH));
            setText(view, "points" + ii, ""+points[pidx]);
            var highest :WordPlay = _ctx.model.getHighestScoringWord(pidx);
            var htext :String = ((highest.word.length == 0) ? "" :
                                 highest.word + " for " + highest.getPoints(_ctx.model));
            setText(view, "highest_score" + ii, htext, true);
        }

        for (ii = precs.length; ii < 4; ii++) {
            removeViewChild(view, "winner" + ii);
            removeViewChild(view, "player_name" + ii);
            removeViewChild(view, "points" + ii);
            removeViewChild(view, "highest_score" + ii);
        }

        if (_ctx.control.game.isInPlay()) {
            // if the game is not over, count down to the next round
            _nextSecs = _ctx.model.getInterRoundDelay();
            _nextField = setText(view, "next_round", Util.millisToMinSec(_nextSecs*1000));
        } else {
            // otherwise remove our next round countdown
            removeViewChild(view, "next_label");
            removeViewChild(view, "next_round");
        }

        setContent(view);

        // these have to happen after we've set our content
        if (_ctx.control.game.isInPlay()) {
            var timer :Timer = new Timer(1000, _nextSecs);
            timer.addEventListener(TimerEvent.TIMER, function () :void {
                    _nextField.text = Util.millisToMinSec(--_nextSecs*1000);
                });
            timer.start();

        } else {
            var results :SimpleButton = _ctx.content.makeButton("Final Results");
            results.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                _ctx.view.clearOverView();
                _ctx.view.showGameOver();
            });
            addButton(results, CENTER);
        }
    }

    protected var _nextField :TextField;
    protected var _nextSecs :int;

    protected static const MAX_NAME_LENGTH :int = 11;
}
}
