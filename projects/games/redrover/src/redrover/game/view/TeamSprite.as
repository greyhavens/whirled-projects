package redrover.game.view {

import flash.display.Sprite;

import redrover.util.SpriteUtil;

public class TeamSprite extends Sprite
{
    public var boardLayer :Sprite;
    public var objectLayer :Sprite;

    public function TeamSprite ()
    {
        boardLayer = SpriteUtil.createSprite(true);
        objectLayer = SpriteUtil.createSprite();

        addChild(boardLayer);
        addChild(objectLayer);
    }

}

}
