//
// $Id$

package dictattack {

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * Displays the end of game information for a single player game.
 */
public class EndGameSingle extends Dialog
{
    public function EndGameSingle (ctx :Context, flowAward :int)
    {
        super(ctx);

        var points :Array = (_ctx.control.get(Model.POINTS) as Array);
        var mypoints :int = points[_ctx.control.seating.getMyPosition()];
        var view :MovieClip = _ctx.content.createGameOverSingle();

        setText(view, "final_score", ""+mypoints);
        setText(view, "duration", Util.millisToMinSec(_ctx.model.getGameDuration()));

        var longest :WordPlay = _ctx.model.getLongestWord();
        setText(view, "longest_word", (longest == null) ? "<none>" : longest.word, true);

        var highest :WordPlay = _ctx.model.getHighestScoringWord();
        setText(view, "highest_score", (highest == null) ? "<none>" : // TODO: render colored
                (highest.word + " for " + highest.getPoints(_ctx.model)), true);

        var counts :Array = _ctx.model.getWordCountsByLength();
        setText(view, "word_count_left", counts[4] + "\n" + counts[5] + "\n" +
                counts[6] + "\n" + counts[7]);

        setText(view, "word_count_right",
                ((counts[8] > 0) ? counts[8] + " Nice!\n" : "0\n") +
                ((counts[9] > 0) ? counts[9] + " Awesome!\n" : "0\n") +
                ((counts[10] > 0) ? counts[10] + " Amazing!\n" : "0\n") +
                ((counts[11] > 0) ? counts[11] + " You Rock!" : "0"), true).wordWrap = false;

        setContent(view);

        var restart :SimpleButton = _ctx.content.makeButton("Play Again");
        restart.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _ctx.view.clearOverView();
            _ctx.control.playerReady();
        });
        addButton(restart, LEFT);

        var leave :SimpleButton = _ctx.content.makeButton("To Whirled");
        leave.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            _ctx.view.clearOverView();
            _ctx.control.backToWhirled();
        });
        addButton(leave, RIGHT);
    }
}
}
