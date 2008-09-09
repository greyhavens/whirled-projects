package client {

import com.whirled.game.SizeChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.Font;
import flash.text.TextField;

public class GameView extends Sprite
{
    public static var gameFont :Font;

    public var boardLayer :Sprite;
    public var shipLayer :Sprite;
    public var shotLayer :Sprite;
    public var subShotLayer :Sprite;
    public var statusLayer :Sprite;
    public var resultsLayer :Sprite;
    public var popupLayer :Sprite;

    /** Status info. */
    public var status :StatusOverlay;

    public function GameView ()
    {
        _center = new Sprite();
        var mask :Shape = new Shape();
        _center.addChild(mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, Constants.GAME_WIDTH, Constants.GAME_HEIGHT);
        mask.graphics.endFill();
        _center.mask = mask;
        addChild(_left = new BACKGROUND() as Bitmap);
        addChild(_right = new BACKGROUND() as Bitmap);
        addChild(_center);
        _center.graphics.beginFill(Constants.BLACK);
        _center.graphics.drawRect(0, 0, Constants.GAME_WIDTH, Constants.GAME_HEIGHT);

        gameFont = Font(new _venusRising());

        _introMovie = MovieClip(new introAsset());
        _center.addChild(_introMovie);

        AppContext.gameCtrl.local.addEventListener(SizeChangedEvent.SIZE_CHANGED,
            updateDisplayPosition);

        AppContext.gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            messageReceived);

        updateDisplayPosition();
    }

    public function beginGame () :void
    {
        // stop the intro movie if it's playing
        if (_introMovie != null) {
            _center.removeChild(_introMovie);
            _introMovie = null;
        }

        while (_center.numChildren > 1) {
            _center.removeChildAt(_center.numChildren - 1);
        }

        boardLayer = new Sprite();
        subShotLayer = new Sprite();
        shipLayer = new Sprite();
        shotLayer = new Sprite();
        statusLayer = new Sprite();
        resultsLayer = new Sprite();
        popupLayer = new Sprite();
        _center.addChild(boardLayer);
        _center.addChild(subShotLayer);
        _center.addChild(shipLayer);
        _center.addChild(shotLayer);
        _center.addChild(statusLayer);
        _center.addChild(resultsLayer);
        _center.addChild(popupLayer);

        statusLayer.addChild(status = new StatusOverlay());
    }

    public function boardLoaded () :void
    {
        if (_endMovie != null) {
            _endMovie.parent.removeChild(_endMovie);
            _endMovie = null;
        }

        ShipChooser.show(true);
    }

    public function showRoundResults (winningShips :Array) :void
    {
        _endMovie = MovieClip(new (Resources.getClass("round_results"))());
        for (var ii :int = 0; ii < winningShips.length; ii++) {
            _endMovie.fields_mc.getChildByName("place_" + (ii + 1)).text =
                    "" + (ii + 1) + ". " + Ship(winningShips[ii]).playerName;
        }
        _nextRoundTimerText = _endMovie.fields_mc.timer;
        _nextRoundTimerText.text = String(Constants.END_ROUND_TIME_S);
        resultsLayer.addChild(_endMovie);
    }

    protected function updateDisplayPosition (...ignored) :void
    {
        var displayWidth :Number = AppContext.gameCtrl.local.getSize().x;
        _center.x = Math.max(0, (displayWidth - Constants.GAME_WIDTH) / 2);
        _right.width = _left.width = _center.x;
        _right.x = displayWidth - _right.width;
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Constants.TICKER_NEXTROUND) {
            if (_nextRoundTimerText != null) {
                _nextRoundTimerText.text = String(Math.max(0, int(_nextRoundTimerText.text) - 1));
            }
        }
    }

    protected var _introMovie :MovieClip;
    protected var _endMovie :MovieClip;

    protected var _left :Bitmap;
    protected var _right :Bitmap;
    protected var _center :Sprite;

    protected var _nextRoundTimerText :TextField;

    [Embed(source="../../rsrc/intro_movie.swf")]
    protected var introAsset :Class;

    [Embed(source="../../rsrc/VENUSRIS.TTF", fontName="Venus Rising", mimeType="application/x-font")]
    protected var _venusRising :Class;

    [Embed(source="../../rsrc/gutters.png")]
    protected static const BACKGROUND :Class;
}

}
