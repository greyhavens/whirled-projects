package popcraft.sp {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.ui.UIBits;

public class LevelOutroMode extends AppMode
{
    public function LevelOutroMode (success :Boolean)
    {
        _success = success;
    }

    protected function saveProgress () :void
    {
        // calculate the score for this level (we give the player a few points if they died)
        var expertCompletion :Boolean = (GameContext.diurnalCycle.dayCount <= GameContext.spLevel.expertCompletionDays);
        var expertCompletionScore :int = (expertCompletion ? GameContext.spLevel.expertCompletionBonus : 0);

        var resourcesScore :int =
            Math.max(GameContext.localPlayerInfo.totalResourcesEarned, 0) *
            GameContext.gameData.pointsPerResource;

        var levelScore :int =
            expertCompletionScore +
            resourcesScore +
            GameContext.spLevel.levelCompletionBonus;

        var awardedScore :Number = (_success ? levelScore : levelScore * Constants.LEVEL_LOSE_SCORE_MULTIPLIER);

        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.game.endGameWithScore(awardedScore);
        } else {
            log.info("Level score: " + awardedScore);
        }

        // save our progress and award trophies if we were successful
        if (_success) {
            var dataChanged :Boolean;

            var newLevelRecord :LevelRecord = new LevelRecord();
            newLevelRecord.unlocked = true;
            newLevelRecord.expert = expertCompletion;
            newLevelRecord.score = levelScore;

            var thisLevelIndex :int = AppContext.levelMgr.curLevelIndex;
            var curLevelRecord :LevelRecord = AppContext.levelMgr.getLevelRecord(thisLevelIndex);
            if (null != curLevelRecord && newLevelRecord.isBetterThan(curLevelRecord)) {
                curLevelRecord.assign(newLevelRecord);
                dataChanged = true;
            }

            var nextLevel :LevelRecord = AppContext.levelMgr.getLevelRecord(thisLevelIndex + 1);
            if (null != nextLevel && !nextLevel.unlocked) {
                nextLevel.unlocked = true;
                dataChanged = true;
            }

            if (dataChanged) {
                UserCookieManager.setNeedsUpdate();
            }

            // trophies
            var levelTrophy :String;
            switch (thisLevelIndex) {
            case TrophyManager.FRESHMAN_LEVEL: levelTrophy = TrophyManager.TROPHY_FRESHMAN; break;
            case TrophyManager.SOPHOMORE_LEVEL: levelTrophy = TrophyManager.TROPHY_SOPHOMORE; break;
            case TrophyManager.JUNIOR_LEVEL: levelTrophy = TrophyManager.TROPHY_JUNIOR; break;
            case TrophyManager.SENIOR_LEVEL: levelTrophy = TrophyManager.TROPHY_SENIOR; break;
            case TrophyManager.GRADUATE_LEVEL: levelTrophy = TrophyManager.TROPHY_GRADUATE; break;
            }

            if (null != levelTrophy) {
                TrophyManager.awardTrophy(levelTrophy);
            }

            if (AppContext.levelMgr.expertScoreForAllLevels) {
                TrophyManager.awardTrophy(TrophyManager.TROPHY_MAGNACUMLAUDE);
            }
        }
    }

    override protected function setup () :void
    {
        this.saveProgress();

        // draw dim background
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var bgSprite :Sprite = new Sprite();
        g = bgSprite.graphics;
        g.beginFill(_success ? 0x76FF86 : 0xFD5CFF);
        g.drawRect(0, 0, 250, 300);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (bgSprite.height * 0.5);

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
            message = Rand.nextElement(hints, Rand.STREAM_COSMETIC) + "\n\n";
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
        var button :SimpleButton;

        if (_success) {
            button = UIBits.createButton("Next Level");
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.incrementCurLevelIndex();
                    AppContext.levelMgr.playLevel();
                });
        } else {
            button = UIBits.createButton("Retry");
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.playLevel();
                });
        }

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 200;
        bgSprite.addChild(button);

        button = UIBits.createButton("Main Menu");
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

    protected static var log :Log = Log.getLog(LevelOutroMode);

}

}
