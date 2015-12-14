package redrover.game.view {

import flash.display.Sprite;

import redrover.util.SpriteUtil;

public class TeamSprite extends Sprite
{
    public var boardLayer :Sprite;
    public var shadowLayer :Sprite;
    public var objectLayer :Sprite;
    public var playerLayer :Sprite;
    public var effectLayer :Sprite;

    public function TeamSprite ()
    {
        boardLayer = SpriteUtil.createSprite(true);
        shadowLayer = SpriteUtil.createSprite();
        objectLayer = SpriteUtil.createSprite();
        playerLayer = SpriteUtil.createSprite();
        effectLayer = SpriteUtil.createSprite();

        addChild(boardLayer);
        addChild(shadowLayer);
        addChild(objectLayer);
        addChild(playerLayer);
        addChild(effectLayer);
    }

}

}
