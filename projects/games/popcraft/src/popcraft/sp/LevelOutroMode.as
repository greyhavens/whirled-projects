package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class LevelOutroMode extends AppMode
{
    public function LevelOutroMode (success :Boolean)
    {
        _success = success;

        // save our progress and award trophies if we were successful
        if (_success) {
            // calculate the score for this level
            var fastCompletionScore :int =
                Math.max(GameContext.spLevel.parDays - GameContext.diurnalCycle.dayCount, 0) *
                GameContext.gameData.pointsPerDayUnderPar;

            var resourcesScore :int =
                Math.max(GameContext.localPlayerInfo.totalResourcesEarned, 0) *
                GameContext.gameData.pointsPerResource;

            var levelScore :int =
                fastCompletionScore +
                resourcesScore +
                GameContext.spLevel.levelCompletionBonus;

            var dataChanged :Boolean;

            var thisLevelIndex :int = AppContext.levelMgr.curLevelIndex;
            var thisLevel :LevelRecord = AppContext.levelMgr.getLevelRecord(thisLevelIndex);
            if (null != thisLevel && thisLevel.score < levelScore) {
                thisLevel.score = levelScore;
                dataChanged = true;
            }

            var nextLevel :LevelRecord = AppContext.levelMgr.getLevelRecord(AppContext.levelMgr.curLevelIndex + 1);
            if (null != nextLevel && !nextLevel.unlocked) {
                nextLevel.unlocked = true;
                dataChanged = true;
            }

            if (dataChanged) {
                AppContext.cookieMgr.setNeedsUpdate();
            }

            // trophies
            var levelTrophy :String;
            switch (thisLevelIndex) {
            case 2: levelTrophy = TrophyManager.TROPHY_FRESHMAN; break;
            case 5: levelTrophy = TrophyManager.TROPHY_SOPHOMORE; break;
            case 8: levelTrophy = TrophyManager.TROPHY_JUNIOR; break;
            case 11: levelTrophy = TrophyManager.TROPHY_SENIOR; break;
            case 13: levelTrophy = TrophyManager.TROPHY_GRADUATE; break;
            }

            if (null != levelTrophy) {
                TrophyManager.awardTrophy(levelTrophy);
            }
        }
    }

    override protected function setup () :void
    {
        // draw dim background
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var bgSprite :Sprite = new Sprite();
        g = bgSprite.graphics;
        g.beginFill(_success ? 0x76FF86 : 0xFD5CFF);
        g.drawRect(0, 0, 250, 300);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_DIMS.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_DIMS.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.addChild(bgSprite);

        // win/lose text
        var tfName :TextField = new TextField();
        tfName.selectable = false;
        tfName.autoSize = TextFieldAutoSize.CENTER;
        tfName.scaleX = 2;
        tfName.scaleY = 2;
        tfName.text = (_success ? "Victory!" : "Defeated");
        tfName.x = (bgSprite.width * 0.5) - (tfName.width * 0.5);
        tfName.y = 30;

        bgSprite.addChild(tfName);

        var message :String = "";

        // if the player lost, show a hint
        var hints :Array = GameContext.spLevel.levelHints;
        if (!_success && hints.length > 0) {
            message = hints[Rand.nextIntRange(0, hints.length, Rand.STREAM_COSMETIC)] + "\n\n";
        }

        message += "Your progress has been saved. Continue playing?";

        var tfMessage :TextField = new TextField();
        tfMessage.selectable = false;
        tfMessage.wordWrap = true;
        tfMessage.multiline = true;
        tfMessage.width = 250 - 24;
        tfMessage.autoSize = TextFieldAutoSize.LEFT;
        tfMessage.text = message;
        tfMessage.x = 12;
        tfMessage.y = tfName.y + tfName.height + 3;

        bgSprite.addChild(tfMessage);

        // buttons
        var button :SimpleTextButton;

        if (_success) {
            button = new SimpleTextButton("Next Level");
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.incrementLevelNum();
                    AppContext.levelMgr.playLevel();
                });
        } else {
            button = new SimpleTextButton("Retry");
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.playLevel();
                });
        }

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 200;
        bgSprite.addChild(button);

        button = new SimpleTextButton("Main Menu");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new LevelSelectMode());
            });
        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 250;
        bgSprite.addChild(button);
    }

    override protected function enter () :void
    {
        if (!_playedSound) {
            AudioManager.instance.playSoundNamed(_success ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
    }

    protected var _success :Boolean;
    protected var _playedSound :Boolean;

}

}
