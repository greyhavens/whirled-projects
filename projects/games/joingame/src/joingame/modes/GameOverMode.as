package joingame.modes
{
    import com.threerings.flash.SimpleTextButton;
    import com.threerings.util.HashMap;
    import com.whirled.contrib.simplegame.AppMode;
    
    import flash.display.DisplayObject;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    
    import joingame.*;
    
    public class GameOverMode extends AppMode
    {
        public function GameOverMode( playerids :Array, scores :Array)
        {
            super();
            _playeridsInOrderOfJighestScore = playerids;
            _scores = scores;
            
            var playerids :Array = AppContext.gameCtrl.game.seating.getPlayerIds();
            var playernames :Array = AppContext.gameCtrl.game.seating.getPlayerNames();
            _id2Name = new HashMap();
            for( var i :int = 0; i < playerids.length; i++) {
                _id2Name.put( playerids[i], playernames[i]);
            }
            
            _id2Score = new HashMap();
            for( i = 0; i < playerids.length; i++) {
                _id2Score.put( playerids[i], _scores[i]);
            }
            
            _currentY = 10;
            
        }
        
        
        override protected function setup ():void
        {
            var winningPlayerID :int = GameContext.gameState.currentSeatingOrder[0];
            var _button :SimpleTextButton = new SimpleTextButton("Winning Player = " + winningPlayerID);
            _modeSprite.addChild(_button);
            _button.x = 100;
            _button.y = 100;
            
//            _gameCtrl.game.endGameWithScores(playerIds, scores, GameSubControl.TO_EACH_THEIR_OWN);
            
        }
        
        protected function drawPlayerIDScoreRank( playerid :int) :void
        {
            var format :TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 12;
            format.color = 0xff0033;
            format.bold = true;
            
            
            var textfield :TextField = new TextField();
            textfield.defaultTextFormat = format;
            textfield.text = _id2Name.get(playerid);
            textfield.x = 50;
            textfield.y = _currentY;
            textfield.width = 100;
            textfield.height = textfield.textHeight + 2;
            textfield.type = TextFieldType.DYNAMIC;
            textfield.border = false;
            _modeSprite.addChild(textfield);
            
            var headshot :DisplayObject = AppContext.gameCtrl.local.getHeadShot( playerid);
            headshot.x = 150;
            headshot.y = _currentY;
            _modeSprite.addChild(headshot);
            
            var scoreTextField :TextField = new TextField();
            scoreTextField.defaultTextFormat = format;
            scoreTextField.text = String(_id2Score.get(playerid));
            scoreTextField.x = 250;
            scoreTextField.y = _currentY;
            scoreTextField.width = 100;
            scoreTextField.height = scoreTextField.textHeight + 2;
            scoreTextField.type = TextFieldType.DYNAMIC;
            scoreTextField.border = false;
            _modeSprite.addChild(scoreTextField);
            
            _currentY += 80;
        }
        
        
        
        private var _playeridsInOrderOfJighestScore :Array;
        private var _scores :Array;
        private var _id2Name :HashMap;
        private var _id2Score :HashMap;
        private var _currentY :int;
    }
}