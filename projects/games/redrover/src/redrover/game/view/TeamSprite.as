package redrover.game.view {

import flash.display.Sprite;

import redrover.util.SpriteUtil;

public class TeamSprite extends Sprite
{
    public var boardLayer :Sprite;
    public var gemLayer :Sprite;
    public var playerLayer :Sprite;

    public function TeamSprite ()
    {
        boardLayer = SpriteUtil.createSprite(true);
        gemLayer = SpriteUtil.createSprite();
        playerLayer = SpriteUtil.createSprite();

        addChild(boardLayer);
        addChild(gemLayer);
        addChild(playerLayer);
    }

}

}
