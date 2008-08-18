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
    public function EndGameSingle (ctx :Context, coinsAward :int)
    {
        super(ctx);

        var mypoints :int = (_ctx.control.net.get(Model.POINTS) as Array)[0];
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

        if (_ctx.control.game.seating.getMyPosition() >= 0) {
            var restart :SimpleButton = _ctx.content.makeButton("Play Again");
            restart.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                    _ctx.view.clearOverView();
                    _ctx.control.game.playerReady();
                });
            addButton(restart, CENTER);
        }
    }
}
}
