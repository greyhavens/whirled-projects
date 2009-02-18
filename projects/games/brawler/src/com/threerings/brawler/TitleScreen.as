package com.threerings.brawler {

import com.threerings.util.MultiLoader;
import com.whirled.contrib.EventHandlerManager;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class TitleScreen extends Sprite
{
    public function TitleScreen ()
    {
        MultiLoader.getContents(TITLE_SWF, onScreenLoaded);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    protected function onScreenLoaded (screen :MovieClip) :void
    {
        // Begin loading the rest of the game's resources, so they'll be ready sooner.
        Resources.load();

        _titleScreen = screen;
        addChild(_titleScreen);

        // Process clicks on the single-player and multiplayer buttons
        var titleMode :MovieClip = _titleScreen["title_mode"];
        var singleBtn :SimpleButton = titleMode["btn_single"];
        var multiBtn :SimpleButton = titleMode["btn_multi"];

        _events.registerOneShotCallback(singleBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                showDifficultySelect();
            });

        _events.registerOneShotCallback(multiBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                Brawler.showMultiplayerLobby();
            });
    }

    protected function showDifficultySelect () :void
    {
        _titleScreen.gotoAndPlay(2);

        // Ugh. Wait until the screen has appeared to grab these buttons.
        waitUntil(
            function () :Boolean {
                return (_titleScreen["title_difficulty"] != null);
            },
            function () :void {
                // Process clicks on the difficulty selection buttons
                var difficultyMode :MovieClip = _titleScreen["title_difficulty"];
                var difficultyButtons :Array = [];
                for each (var difficultyName :String in DIFFICULTY) {
                    var buttonName :String = "btn_" + difficultyName.toLowerCase();
                    var difficultyBtn :SimpleButton = difficultyMode[buttonName];
                    _events.registerOneShotCallback(
                        difficultyBtn,
                        MouseEvent.CLICK,
                        createDifficultyListener(difficultyName));
                }
            }
        );
    }

    protected function createDifficultyListener (difficultyName :String) :Function
    {
        return function (...ignored) :void {
            Brawler.startGame(difficultyName);
        }
    }

    protected function waitUntil (pred :Function, callback :Function) :void
    {
        var titleScreen :TitleScreen = this;

        _events.registerListener(titleScreen, Event.ENTER_FRAME, frameListener);
        function frameListener (...ignored) :void {
            if (pred()) {
                _events.unregisterListener(titleScreen, Event.ENTER_FRAME, frameListener);
                callback();
            }
        }
    }

    protected var _difficulty :String;

    protected var _titleScreen :MovieClip;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const DIFFICULTY :Array = [ "Easy", "Normal", "Hard", "Inferno" ];

    [Embed(source="../../../../rsrc/titlescreen.swf", mimeType="application/octet-stream")]
    protected static const TITLE_SWF :Class;
}

}
