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
    public function EndGameMulti (ctx :Context, flowAward :int)
    {
        super(ctx);

        var view :MovieClip = _ctx.content.createGameOverMulti();
        setText(view, "duration", Util.millisToMinSec(_ctx.model.getGameDuration()));
        setText(view, "flow", flowAward + " flow");

        // determine the winner
        var widx :int = 0;
        var scores :Array = (_ctx.control.get(Model.SCORES) as Array);
        for (var pidx :int = 0; pidx < scores.length; pidx++) {
            if (scores[pidx] >= _ctx.model.getWinningScore()) {
                widx = pidx;
                break;
            }
        }

        var shotMarker :DisplayObject = view.getChildByName("avatar");
        view.removeChild(shotMarker);
        setText(view, "winner_name", _ctx.model.getPlayerName(widx, MAX_NAME_LENGTH));
        var winnerId :int = _ctx.control.seating.getPlayerIds()[widx];
        _ctx.control.getHeadShot(winnerId, function (sprite :Sprite, success :Boolean) :void {
            if (success) {
                sprite.x = shotMarker.x - sprite.width/2;
                sprite.y = shotMarker.y - sprite.height/2;
                view.addChild(sprite);
            }
        });
        setContent(view);

        var restart :SimpleButton = _ctx.content.makeButton("Rematch");
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

    protected static const MAX_NAME_LENGTH :int = 11;
}
}
