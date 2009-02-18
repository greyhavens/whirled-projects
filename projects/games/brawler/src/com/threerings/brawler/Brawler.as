package com.threerings.brawler {

import com.whirled.game.GameControl;

import flash.display.Sprite;

/**
 * The Brawler entry point.
 */
[SWF(width="800", height="500", frameRate="30")]
public class Brawler extends Sprite
{
    /** The width of the display. */
    public static const WIDTH :Number = 700;

    /** The height of the display. */
    public static const HEIGHT :Number = 500;

    public function Brawler ()
    {
        _displayRoot = this;
        _control = new GameControl(this, false);

        // If this is a single-player game, show the Title Screen.
        // The Title Screen will kick off the game.
        if (!_control.isConnected() || _control.game.seating.getPlayerIds().length == 1) {
            _titleScreen = new TitleScreen();
            addChild(_titleScreen);

        } else {
            // Otherwise, dump us right into the multiplayer game
            startGame(_control.game.getConfig()["difficulty"]);
        }
    }

    public static function startGame (difficulty :String) :void
    {
        if (_titleScreen != null) {
            _displayRoot.removeChild(_titleScreen);
            _titleScreen.shutdown();
            _titleScreen = null;
        }

        // create the controller (it will create the view)
        var ctrl :BrawlerController = new BrawlerController(_control, _displayRoot, difficulty);

        // add the view
        _displayRoot.addChild(ctrl.view);
    }

    public static function showMultiplayerLobby () :void
    {
        _control.local.showGameLobby(true);
    }

    protected static var _control :GameControl;
    protected static var _displayRoot :Brawler;
    protected static var _titleScreen :TitleScreen;
}
}
