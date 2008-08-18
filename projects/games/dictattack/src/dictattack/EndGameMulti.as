//
// $Id$

package dictattack {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;

import flash.events.MouseEvent;
import flash.events.MouseEvent;

/**
 * Displays information at the end of a multiplayer game.
 */
public class EndGameMulti extends Dialog
{
    public function EndGameMulti (ctx :Context, coinsAward :int)
    {
        super(ctx);

        var view :MovieClip = _ctx.content.createGameOverMulti();
        setText(view, "duration", Util.millisToMinSec(_ctx.model.getGameDuration()));
        setText(view, "flow", coinsAward + " coins");

        // determine the winner
        var widx :int = 0;
        var scores :Array = (_ctx.control.net.get(Model.SCORES) as Array);
        for (var pidx :int = 0; pidx < scores.length; pidx++) {
            if (scores[pidx] >= _ctx.model.getWinningScore()) {
                widx = pidx;
                break;
            }
        }

        var shotMarker :DisplayObject = view.getChildByName("avatar");
        view.removeChild(shotMarker);
        setText(view, "winner_name", _ctx.model.getPlayerName(widx, MAX_NAME_LENGTH));
        var winnerId :int = _ctx.control.game.seating.getPlayerIds()[widx];
        var shot :DisplayObject = _ctx.control.local.getHeadShot(winnerId);
        shot.x = shotMarker.x - shot.width/2;
        shot.y = shotMarker.y - shot.height/2;
        view.addChild(shot);
        setContent(view);

        if (_ctx.control.game.seating.getMyPosition() >= 0) {
            var restart :SimpleButton = _ctx.content.makeButton("Rematch");
            restart.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                    _ctx.view.clearOverView();
                    _ctx.control.game.playerReady();
                });
            addButton(restart, CENTER);
        }
    }

    protected static const MAX_NAME_LENGTH :int = 11;
}
}
