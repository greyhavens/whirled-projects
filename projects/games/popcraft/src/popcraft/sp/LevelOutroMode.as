package popcraft.sp {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.ui.UIBits;

public class LevelOutroMode extends AppMode
{
    public function LevelOutroMode ()
    {
        _success = (GameContext.winningTeamId == GameContext.localPlayerInfo.teamId);
    }

    override protected function setup () :void
    {
        this.saveProgress();

        var bgSprite :Sprite = UIBits.createFrame(WIDTH, HEIGHT);

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (WIDTH * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (HEIGHT * 0.5);

        this.modeSprite.addChild(bgSprite);

        // win/lose text
        var tfName :TextField = UIBits.createTitleText(_success ? "Victory!" : "Defeated");
        tfName.x = (WIDTH * 0.5) - (tfName.width * 0.5);
        tfName.y = 20;

        bgSprite.addChild(tfName);

        var message :String = "";

        var hints :Array = GameContext.spLevel.levelHints;

        // if the player won, show their score calculation
        if (_success) {
            message += "Resources score: " + LevelScoreInfo.resourcesScore + "\n";
            if (LevelScoreInfo.completionBonus > 0) {
                message += "Level bonus: " + LevelScoreInfo.completionBonus + "\n";
            }
            if (LevelScoreInfo.expertCompletionScore > 0) {
                message += "Expert completion bonus: " + LevelScoreInfo.expertCompletionScore + "\n";
            }
            message += "TOTAL SCORE: " + LevelScoreInfo.totalScore + "\n\n" +
                       "Your progress has been saved.\nContinue playing?";

        } else {
            // if the player lost, show a hint
            message = Rand.nextElement(hints, Rand.STREAM_COSMETIC) + "\n\n";
        }

        var tfMessage :DisplayObject = UIBits.createText(message, 1, WIDTH - 30, 0, TextFormatAlign.LEFT);
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
        super.enter();

        if (!_playedSound) {
            AudioManager.instance.playSoundNamed(_success ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
    }

    protected function saveProgress () :void
    {
        // if the player lost the level, give them points for the resources they gathered
        var awardedScore :int = (_success ? LevelScoreInfo.totalScore : LevelScoreInfo.resourcesScore);

        if (AppContext.gameCtrl.isConnected()) {
            // don't show the rematch button in single-player games
            AppContext.gameCtrl.local.setShowButtons(false, true);
            AppContext.gameCtrl.game.endGameWithScore(awardedScore);

        } else {
            log.info("Level score: " + awardedScore);
        }

        // save our progress and award trophies if we were successful
        if (_success) {
            var dataChanged :Boolean;

            var newLevelRecord :LevelRecord = new LevelRecord();
            newLevelRecord.unlocked = true;
            newLevelRecord.expert = LevelScoreInfo.expertCompletion;
            newLevelRecord.score = LevelScoreInfo.totalScore;

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

            if (AppContext.levelMgr.playerBeatGameWithExpertScore) {
                TrophyManager.awardTrophy(TrophyManager.TROPHY_MAGNACUMLAUDE);
            }
        }
    }

    protected var _success :Boolean;
    protected var _playedSound :Boolean;

    protected static var log :Log = Log.getLog(LevelOutroMode);

    protected static const WIDTH :Number = 280;
    protected static const HEIGHT :Number = 325;

}

}

import popcraft.*;

class LevelScoreInfo
{
    public static function get expertCompletion () :Boolean
    {
        return (GameContext.diurnalCycle.dayCount <= GameContext.spLevel.expertCompletionDays);
    }

    public static function get expertCompletionScore () :int
    {
        return (expertCompletion ? GameContext.spLevel.expertCompletionBonus : 0);
    }

    public static function get resourcesScore () :int
    {
        var score :int = Math.max(GameContext.localPlayerInfo.totalResourcesEarned, 0) * GameContext.gameData.pointsPerResource;
        if (GameContext.spLevel.maxResourcesScore >= 0) {
            score = Math.min(score, GameContext.spLevel.maxResourcesScore);
        }

        return score;
    }

    public static function get completionDays () :int
    {
        return GameContext.diurnalCycle.dayCount;
    }

    public static function get completionBonus () :int
    {
        return GameContext.spLevel.levelCompletionBonus;
    }

    public static function get totalScore () :int
    {
        return expertCompletionScore + resourcesScore + completionBonus;
    }
}
