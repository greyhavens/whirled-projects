package popcraft.game.story {

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
import popcraft.game.*;
import popcraft.data.LevelData;
import popcraft.ui.UIBits;

public class LevelOutroMode extends AppMode
{
    public function LevelOutroMode (level :LevelData)
    {
        _level = level;
        _success = (GameContext.winningTeamId == GameContext.localPlayerInfo.teamId);
    }

    override protected function setup () :void
    {
        saveProgress();

        var bgSprite :Sprite = UIBits.createFrame(WIDTH, HEIGHT);

        bgSprite.x = (Constants.SCREEN_SIZE.x * 0.5) - (WIDTH * 0.5);
        bgSprite.y = (Constants.SCREEN_SIZE.y * 0.5) - (HEIGHT * 0.5);

        this.modeSprite.addChild(bgSprite);

        // win/lose text
        var tfName :TextField = UIBits.createTitleText(_success ? "Victory!" : "Defeated");
        tfName.x = (WIDTH * 0.5) - (tfName.width * 0.5);
        tfName.y = 20;

        bgSprite.addChild(tfName);

        if (_success) {
            // if the player won, show their score
            var scoreMessage :String = "Completion days: " + this.completionDays + "\n";
            scoreMessage += "Resources score: " + this.resourcesScore + "\n";
            if (this.completionBonus > 0) {
                scoreMessage += "Level bonus: " + this.completionBonus + "\n";
            }
            if (this.expertCompletionScore > 0) {
                scoreMessage += "Expert completion bonus: " + this.expertCompletionScore + "\n";
            }
            scoreMessage += "TOTAL SCORE: " + this.totalScore;

            var tfScore :DisplayObject = UIBits.createTextPanel(scoreMessage, 1, WIDTH - 30, 0, TextFormatAlign.LEFT);
            tfScore.x = (WIDTH * 0.5) - (tfScore.width * 0.5);
            tfScore.y = tfName.y + tfName.height + 10;
            bgSprite.addChild(tfScore);

            // if it's not the last level, display a "Continue playing?" text
            if (!AppContext.levelMgr.isLastLevel) {
                var message :String;
                if (AppContext.levelMgr.curLevelIndex == Constants.UNLOCK_ENDLESS_AFTER_LEVEL) {
                    message = "Initiation Challenge has been unlocked in the Main Menu!";
                } else {
                    message = (SeatingManager.isLocalPlayerGuest ?
                        "Create an account on Whirled to save your progress!" :
                        "Your progress has been saved.") + "\nContinue playing?"
                }

                var tfMessage :DisplayObject = UIBits.createText(message, 1.1, WIDTH - 30);
                tfMessage.x = (WIDTH * 0.5) - (tfMessage.width * 0.5);
                tfMessage.y = tfScore.y + tfScore.height + 11;
                bgSprite.addChild(tfMessage);
            }

        } else {
            // if the player lost, show a hint
            var hints :Array = _level.levelHints;
            var tfHint :DisplayObject = UIBits.createTextPanel(
                Rand.nextElement(hints, Rand.STREAM_COSMETIC), 1, WIDTH - 50, 0, TextFormatAlign.LEFT);
            tfHint.x = (WIDTH * 0.5) - (tfHint.width * 0.5);
            tfHint.y = tfName.y + tfName.height + 10;
            bgSprite.addChild(tfHint);
        }

        // buttons
        var button :SimpleButton;

        if (_success && !AppContext.levelMgr.isLastLevel) {
            button = UIBits.createButton("Next Level", 1.5, 150);
            var localThis :LevelOutroMode = this;
            registerOneShotCallback(button, MouseEvent.CLICK,
                function (...ignored) :void {
                    if (localThis.showUpsellScreen) {
                        AppContext.mainLoop.pushMode(new UpsellMode());
                    } else {
                        AppContext.levelMgr.incrementCurLevelIndex();
                        AppContext.levelMgr.playLevel();
                    }
                });

        } else if (!_success) {
            button = UIBits.createButton("Retry", 1.5, 150);
            registerOneShotCallback(button, MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.playLevel();
                });
        }

        if (null != button) {
            button.x = (WIDTH * 0.5) - (button.width * 0.5);
            button.y = 210;
            bgSprite.addChild(button);
        }

        button = UIBits.createButton("Main Menu", 1.5, 150);
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                LevelSelectMode.create();
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

        if (!_showedUpsellMode && this.showUpsellScreen) {
            AppContext.mainLoop.pushMode(new UpsellMode());
            _showedUpsellMode = true;
        }
    }

    protected function get showUpsellScreen () :Boolean
    {
        return (AppContext.levelMgr.curLevelIndex >= Constants.NUM_FREE_SP_LEVELS - 1 &&
            !AppContext.isStoryModeUnlocked);
    }

    protected function saveProgress () :void
    {
        // if the player lost the level, give them points for the resources they gathered
        var awardedScore :int = (_success ? this.totalScore : this.resourcesScore);

        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.game.endGameWithScore(awardedScore, Constants.SCORE_MODE_STORY);

        } else {
            log.info("Level score: " + awardedScore);
        }

        // save our progress and award trophies if we were successful
        if (_success) {
            var dataChanged :Boolean;

            var newLevelRecord :LevelRecord = new LevelRecord();
            newLevelRecord.unlocked = true;
            newLevelRecord.expert = this.expertCompletion;
            newLevelRecord.score = this.totalScore;

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
                AppContext.userCookieMgr.needsUpdate();
            }

            // trophies
            var levelTrophy :String;
            switch (thisLevelIndex) {
            case Trophies.FRESHMAN_LEVEL: levelTrophy = Trophies.FRESHMAN; break;
            case Trophies.SOPHOMORE_LEVEL: levelTrophy = Trophies.SOPHOMORE; break;
            case Trophies.JUNIOR_LEVEL: levelTrophy = Trophies.JUNIOR; break;
            case Trophies.SENIOR_LEVEL: levelTrophy = Trophies.SENIOR; break;
            case Trophies.GRADUATE_LEVEL: levelTrophy = Trophies.GRADUATE; break;
            }

            if (null != levelTrophy) {
                AppContext.awardTrophy(levelTrophy);
            }

            if (AppContext.levelMgr.playerBeatGameWithExpertScore) {
                AppContext.awardTrophy(Trophies.MAGNACUMLAUDE);
            }
        }
    }

    protected function get expertCompletion () :Boolean
    {
        return (GameContext.diurnalCycle.dayCount <= _level.expertCompletionDays);
    }

    protected function get expertCompletionScore () :int
    {
        return (expertCompletion ? _level.expertCompletionBonus : 0);
    }

    protected function get resourcesScore () :int
    {
        var score :int = Math.max(StoryGameMode(GameContext.gameMode).totalResourcesEarned, 0) *
            GameContext.gameData.pointsPerResource;
        if (_level.maxResourcesScore >= 0) {
            score = Math.min(score, _level.maxResourcesScore);
        }

        return score;
    }

    protected function get completionDays () :int
    {
        return GameContext.diurnalCycle.dayCount;
    }

    protected function get completionBonus () :int
    {
        return _level.levelCompletionBonus;
    }

    protected function get totalScore () :int
    {
        return expertCompletionScore + resourcesScore + completionBonus;
    }

    protected var _level :LevelData;
    protected var _success :Boolean;
    protected var _playedSound :Boolean;
    protected var _showedUpsellMode :Boolean;

    protected static var log :Log = Log.getLog(LevelOutroMode);

    protected static const WIDTH :Number = 280;
    protected static const HEIGHT :Number = 325;

}

}