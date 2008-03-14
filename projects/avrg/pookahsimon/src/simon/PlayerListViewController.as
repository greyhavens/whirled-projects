package simon {

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class PlayerListViewController extends Sprite
{
    public function PlayerListViewController ()
    {
        this.mouseEnabled = false;
        this.mouseChildren = false;

        //SimonMain.model.addEventListener(SharedStateChangedEvent.GAME_STATE_CHANGED, handleGameStateChange);
        //SimonMain.model.addEventListener(SharedStateChangedEvent.NEXT_PLAYER, handleNextPlayer);

        this.updateView();
    }

    public function updateView () :void
    {
        if (null != _childSprite) {
            this.removeChild(_childSprite);
        }

        _childSprite = new Sprite();
        this.addChild(_childSprite);

        var players :Array = SimonMain.model.curState.players;

        var numRows :int = players.length + 1;
        var height :int = (ROW_HEIGHT * numRows);

        var g :Graphics = _childSprite.graphics;

        // draw a border
        g.lineStyle(1, 0x000000);
        g.beginFill(0xFFFFFF);
        g.drawRect(0, 0, ROW_WIDTH, height);
        g.endFill();

        // draw row separators
        for (var i :int = 1; i <= (numRows - 1); ++i) {
            var y :int = (i * ROW_HEIGHT);
            g.moveTo(0, y);
            g.lineTo(ROW_WIDTH, y);
        }

        // draw the title
        var title :TextField = createTextField("PLAYERS", ROW_WIDTH, ROW_HEIGHT);
        title.x = (ROW_WIDTH * 0.5) - (title.width * 0.5);
        title.y = (ROW_HEIGHT * 0.5) - (title.height * 0.5);
        _childSprite.addChild(title);

        // draw the scores
        for (i = 0; i < players.length; ++i) {

            var playerId :int = players[i];
            var playerName :String = SimonMain.getPlayerName(playerId);
            var nameText :TextField = createTextField(playerName, ROW_WIDTH, ROW_HEIGHT);

            var thisPlayersTurn :Boolean = (SimonMain.model.curState.gameState == SharedState.PLAYING_GAME && SimonMain.model.curState.curPlayerIdx == i);

            nameText.textColor = (thisPlayersTurn ? 0xFF0000 : 0x000000);

            var rowY :Number = ((i + 1.5) * ROW_HEIGHT);

            nameText.x = (ROW_WIDTH * 0.5) - (nameText.width * 0.5);
            nameText.y = rowY - (nameText.height * 0.5);

            _childSprite.addChild(nameText);
        }

    }

    protected static function createTextField (text :String, maxWidth :int, maxHeight :int) :TextField
    {
        var textField :TextField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.selectable = false;
        textField.mouseEnabled = false;
        textField.text = text;

        var scale :Number = Math.min(maxWidth / textField.width, maxHeight / textField.height);

        textField.scaleX = scale;
        textField.scaleY = scale;

        return textField;
    }

    protected var _childSprite :Sprite;

    protected static const ROW_HEIGHT :int = 30;
    protected static const ROW_WIDTH :int = 150;
}

}