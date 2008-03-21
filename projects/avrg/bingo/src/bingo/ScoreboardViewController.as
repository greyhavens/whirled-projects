package bingo {

import flash.display.MovieClip;
import flash.text.TextField;

public class ScoreboardViewController
{
    public function ScoreboardViewController ()
    {
        var hudClass :Class = BingoMain.resourcesDomain.getDefinition("HUD") as Class;
        _hud = new hudClass();

        _hud.x = Constants.SCOREBOARD_LOC.x;
        _hud.y = Constants.SCOREBOARD_LOC.y;

        BingoMain.sprite.addChild(_hud);

        BingoMain.model.addEventListener(SharedStateChangedEvent.NEW_SCORES, updateScores, false, 0, true);

        this.updateScores();
    }

    public function destroy () :void
    {
        BingoMain.model.removeEventListener(SharedStateChangedEvent.NEW_SCORES, updateScores);

        BingoMain.sprite.removeChild(_hud);
    }

    protected function updateScores (...ignored) :void
    {
        var scores :Array = BingoMain.model.curScores.scores;
        var scoreboardView :MovieClip = _hud["scoreboard"];

        for (var i :int = 0; i < NUM_ROWS; ++i) {

            var nameField :TextField = scoreboardView["player_" + String(i + 1)];
            var scoreField :TextField = scoreboardView["score_" + String(i + 1)];

            var score :Score = (i < scores.length ? scores[i] : null);

            nameField.text = (score != null ? score.name : "");
            scoreField.text = (score != null ? String(score.score) : "");
        }

    }

    protected var _hud :MovieClip;

    protected static const NUM_ROWS :int = 7;

    /*public function ScoreboardViewController (scoreboard :Scoreboard)
    {
        _scoreboard = scoreboard;

        this.mouseEnabled = false;
        this.mouseChildren = false;

        this.updateView();
    }

    public function set scoreboard (newScoreboard :Scoreboard) :void
    {
        _scoreboard = newScoreboard;
        this.updateView();
    }

    protected function updateView () :void
    {
        if (null != _childSprite) {
            this.removeChild(_childSprite);
        }

        _childSprite = new Sprite();
        this.addChild(_childSprite);

        var scores :Array = (_scoreboard == null ? [] : _scoreboard.scores);
        var numScores :int = Math.min(scores.length, Constants.NUM_SCOREBOARD_NAMES);

        var numRows :int = numScores + 1;
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

        // draw score separator
        if (numRows > 1) {
            g.moveTo(ROW_WIDTH - SCORE_WIDTH, ROW_HEIGHT);
            g.lineTo(ROW_WIDTH - SCORE_WIDTH, height);
        }

        // draw the scoreboard title
        var title :TextField = createTextField("TOP SCORES", ROW_WIDTH, ROW_HEIGHT);
        title.x = (ROW_WIDTH * 0.5) - (title.width * 0.5);
        title.y = (ROW_HEIGHT * 0.5) - (title.height * 0.5);
        _childSprite.addChild(title);

        // draw the scores
        for (i = 0; i < numScores; ++i) {
            var score :Score = scores[i];

            var nameText :TextField = createTextField(score.name, ROW_WIDTH - SCORE_WIDTH, ROW_HEIGHT);
            var scoreText :TextField = createTextField(score.score.toString(), SCORE_WIDTH, ROW_HEIGHT);

            nameText.textColor = 0x0000FF;
            scoreText.textColor = 0xFF0000;

            var rowY :Number = ((i + 1.5) * ROW_HEIGHT);

            nameText.x = ((ROW_WIDTH - SCORE_WIDTH) * 0.5) - (nameText.width * 0.5);
            nameText.y = rowY - (nameText.height * 0.5);

            scoreText.x = ROW_WIDTH - (SCORE_WIDTH * 0.5) - (scoreText.width * 0.5);
            scoreText.y = rowY - (scoreText.height * 0.5);

            _childSprite.addChild(nameText);
            _childSprite.addChild(scoreText);
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

    protected var _scoreboard :Scoreboard;
    protected var _childSprite :Sprite;

    protected static const ROW_HEIGHT :int = 30;
    protected static const ROW_WIDTH :int = 150;
    protected static const SCORE_WIDTH :int = 25;*/
}

}
