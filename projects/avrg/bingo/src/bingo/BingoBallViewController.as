package bingo {

import flash.display.MovieClip;
import flash.text.TextField;

public class BingoBallViewController
{
    public function BingoBallViewController ()
    {
        var ballClass :Class = BingoMain.resourcesDomain.getDefinition("bingo_ball") as Class;
        _ball = new ballClass();

        _ball.x = Constants.BALL_LOC.x;
        _ball.y = Constants.BALL_LOC.y;

        BingoMain.sprite.addChild(_ball);

        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_BALL, updateView, false, 0, true);

        this.updateView();
    }

    public function destroy () :void
    {
        BingoMain.sprite.removeChild(_ball);

        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_BALL, updateView);
    }

    protected function updateView (...ignored) :void
    {
        var ballString :String = BingoMain.model.curState.ballInPlay;

        var textField :TextField = _ball["text"] as TextField;
        textField.scaleX = 1;
        textField.scaleY = 1;
        textField.text = (null != ballString ? ballString : "");
    }

    protected var _ball :MovieClip;

    protected static const MAX_TEXT_WIDTH :Number = 68;
}

}
