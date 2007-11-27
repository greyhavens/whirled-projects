//
// $Id$

package dictattack {

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

/**
 * Displays the end of game information for a single player game.
 */
public class EndGameSingle extends Dialog
{
    public function EndGameSingle (ctx :Context, flowAward :int)
    {
        _ctx = ctx;

        var points :Array = (_ctx.control.get(Model.POINTS) as Array);
        var mypoints :int = points[_ctx.control.seating.getMyPosition()];

        var view :MovieClip = _ctx.content.createGameOverSingle();

        (view.getChildByName("final_score") as TextField).text = (""+mypoints);
        (view.getChildByName("duration") as TextField).text =
            Util.millisToMinSec(_ctx.model.getGameDuration());

        var longest :WordPlay = _ctx.model.getLongestWord();
        (view.getChildByName("longest_word") as TextField).text =
            (longest == null) ? "<none>" : longest.word;

        var highest :WordPlay = _ctx.model.getHighestScoringWord();
        (view.getChildByName("highest_score") as TextField).text = (highest == null) ? "<none>" :
            (highest.word + " for " + highest.getPoints(_ctx.model)); // TODO: render colored

        var counts :Array = _ctx.model.getWordCountsByLength();
        (view.getChildByName("word_count_left") as TextField).text =
            counts[4] + "\n" +
            counts[5] + "\n" +
            counts[6] + "\n" +
            counts[7];
        (view.getChildByName("word_count_right") as TextField).text =
            ((counts[8] > 0) ? counts[8] + " Nice!\n" : "0\n") +
            ((counts[9] > 0) ? counts[9] + " Awesome!\n" : "0\n") +
            ((counts[10] > 0) ? counts[10] + " Amazing!\n" : "0\n") +
            ((counts[11] > 0) ? counts[11] + " You Rock!" : "0");

        setContent(view);

        var restart :SimpleButton = _ctx.content.makeButton("Play Again");
        restart.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _ctx.view.clearGameOverView();
            _ctx.control.playerReady();
        });
        addButton(restart, LEFT);

        var leave :SimpleButton = _ctx.content.makeButton("To Whirled");
        leave.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _ctx.view.clearGameOverView();
            _ctx.control.backToWhirled();
        });
        addButton(leave, RIGHT);
    }

    protected var _ctx :Context;
}
}
