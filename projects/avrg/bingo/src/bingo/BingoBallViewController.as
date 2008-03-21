package bingo {

import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class BingoBallViewController
{
    public function BingoBallViewController ()
    {
        var ballClass :Class = BingoMain.resourcesDomain.getDefinition("bingo_ball") as Class;
        _ball = new ballClass();

        _ball.x = Constants.BALL_LOC.x;
        _ball.y = Constants.BALL_LOC.y;

        _textField = _ball["text"] as TextField;
        _textField.autoSize = TextFieldAutoSize.LEFT;

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
        _ball.removeChild(_textField);

        _textField.scaleX = 1;
        _textField.scaleY = 1;

        var ballString :String = BingoMain.model.curState.ballInPlay;
        _textField.text = (null != ballString ? ballString : "");

        var scale :Number = MAX_TEXT_WIDTH / _textField.textWidth;
        _textField.scaleX = scale;
        _textField.scaleY = scale;

        // re-center the text field
        _textField.x = (_ball.width * 0.5) - (_textField.width * 0.5);
        _textField.y = ((_ball.height * 0.5) - (_textField.height * 0.5)) - 2;

        _ball.addChild(_textField);
    }

    protected var _ball :MovieClip;
    protected var _textField :TextField;

    protected static const MAX_TEXT_WIDTH :Number = 62;
}

}
