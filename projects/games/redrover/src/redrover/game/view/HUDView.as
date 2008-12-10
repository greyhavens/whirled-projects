package redrover.game.view {

import com.threerings.util.StringUtil;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import redrover.*;
import redrover.game.*;
import redrover.ui.UIBits;
import redrover.util.SpriteUtil;

public class HUDView extends SceneObject
{
    public function HUDView (size :Point)
    {
        _sprite = SpriteUtil.createSprite(true);
        var g :Graphics = _sprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, size.x, size.y);
        g.endFill();

        _gemSprite = SpriteUtil.createSprite();
        _gemSprite.x = GEM_X;
        _gemSprite.y = size.y * 0.5;
        _sprite.addChild(_gemSprite);

        var switchBoardsButton :SwitchBoardsButton = new SwitchBoardsButton();
        switchBoardsButton.x = BUTTON_X;
        switchBoardsButton.y = (size.y - switchBoardsButton.height) * 0.5;
        GameContext.gameMode.addObject(switchBoardsButton, _sprite);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var newScore :int = GameContext.localPlayer.score;
        if (newScore != _lastScore) {
            if (_scoreText != null) {
                _scoreText.parent.removeChild(_scoreText);
            }

            _scoreText = UIBits.createText("Score: " + StringUtil.formatNumber(newScore),
                1.5, 0, 0xFFFFFF);
            _scoreText.x = SCORE_X;
            _scoreText.y = (_sprite.height - _scoreText.height) * 0.5;
            _sprite.addChild(_scoreText);
            _lastScore = newScore;
        }

        var newGems :int = GameContext.localPlayer.numGems;
        if (newGems != _lastGems) {
            while (_gemSprite.numChildren > 0) {
                _gemSprite.removeChildAt(_gemSprite.numChildren - 1);
            }

            for each (var gemType :int in GameContext.localPlayer.gems) {
                var gem :DisplayObject = GemViewFactory.createGem(25, gemType);
                gem.x = _gemSprite.width;
                gem.y = -gem.height * 0.5;
                _gemSprite.addChild(gem);
            }

            _lastGems = newGems;
        }

        for (var teamId :int = 0; teamId < Constants.NUM_TEAMS; ++teamId) {
            var teamSize :int = GameContext.getTeamSize(teamId);
            if (teamSize != _lastTeamSizes[teamId]) {
                var oldTeamText :TextField = _teamTexts[teamId];
                if (oldTeamText != null) {
                    oldTeamText.parent.removeChild(oldTeamText);
                }
                var teamText :TextField = UIBits.createText(
                    Constants.TEAM_LEADER_NAMES[teamId] + " team size: " + teamSize, 1.1, 0,
                    TEAM_COLORS[teamId]);
                var loc :Point = TEAM_SIZE_LOCS[teamId];
                teamText.x = loc.x;
                teamText.y = loc.y;
                _sprite.addChild(teamText);

                _teamTexts[teamId] = teamText;
                _lastTeamSizes[teamId] = teamSize;
            }
        }
    }

    protected var _sprite :Sprite;
    protected var _scoreText :TextField;
    protected var _teamTexts :Array = [ null, null ];
    protected var _gemSprite :Sprite;
    protected var _lastGems :int = -1;
    protected var _lastScore :int = -1;
    protected var _lastTeamSizes :Array = [ -1, -1 ];

    protected static const SCORE_X :Number = 5;
    protected static const GEM_X :Number = 250;
    protected static const BUTTON_X :Number = 695;
    protected static const TEAM_COLORS :Array = [ 0xff6c77, 0x88c5ff ];
    protected static const TEAM_SIZE_LOCS :Array = [ new Point(115, 8), new Point(115, 27) ];
}

}
