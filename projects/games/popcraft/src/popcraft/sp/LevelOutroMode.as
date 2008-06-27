package popcraft.sp {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.ui.UIBits;

public class LevelOutroMode extends AppMode
{
    public function LevelOutroMode ()
    {
        _success = (GameContext.winningTeamId == GameContext.localPlayerInfo.teamId);
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

        if (GameContext.spLevel.maxScore >= 0) {
            levelScore = Math.min(levelScore, GameContext.spLevel.maxScore);
        }

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

        var bgSprite :Sprite = UIBits.createFrame(WIDTH, HEIGHT);

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (WIDTH * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (HEIGHT * 0.5);

        this.modeSprite.addChild(bgSprite);

        // win/lose text
        var tfName :Sprite = UIBits.createTextPanel(_success ? "Victory!" : "Defeated", 2);
        tfName.x = (WIDTH * 0.5) - (tfName.width * 0.5);
        tfName.y = 20;

        bgSprite.addChild(tfName);

        var message :String = "";

        // if the player lost, show a hint
        var hints :Array = GameContext.spLevel.levelHints;
        if (!_success && hints.length > 0) {
            message = Rand.nextElement(hints, Rand.STREAM_COSMETIC) + "\n\n";
        }

        message += "Your progress has been saved.\nContinue playing?";

        var tfMessage :Sprite = UIBits.createTextPanel(message, 1.2, WIDTH - 24, false, TextFormatAlign.LEFT);
        tfMessage.x = (WIDTH * 0.5) - (tfMessage.width * 0.5);
        tfMessage.y = tfName.y + tfName.height + 10;

        bgSprite.addChild(tfMessage);

        // buttons
        var button :SimpleButton;

        if (_success && !AppContext.levelMgr.isLastLevel) {
            button = UIBits.createButton("Next Level", 1.5);
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.incrementCurLevelIndex();
                    AppContext.levelMgr.playLevel();
                });
        } else if (!_success) {
            button = UIBits.createButton("Retry", 1.5);
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.playLevel();
                });
        }

        if (null != button) {
            button.x = (WIDTH * 0.5) - (button.width * 0.5);
            button.y = 210;
            bgSprite.addChild(button);
        }

        button = UIBits.createButton("Level Select", 1.5);
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new LevelSelectMode());
            });
        button.x = (WIDTH * 0.5) - (button.width * 0.5);
        button.y = 260;
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

    protected static const WIDTH :Number = 280;
    protected static const HEIGHT :Number = 325;

}

}
