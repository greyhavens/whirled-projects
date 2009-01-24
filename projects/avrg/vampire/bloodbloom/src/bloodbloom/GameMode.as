package bloodbloom {

import com.whirled.contrib.simplegame.AppMode;

import flash.geom.Point;

public class GameMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        _modeSprite.addChild(ClientCtx.instantiateBitmap("bg"));

        _heart = new Heart();
        _heart.x = HEART_LOC.x;
        _heart.y = HEART_LOC.y;
        addObject(_heart, _modeSprite);
    }

    protected var _heart :Heart;

    protected static const HEART_LOC :Point = new Point(246, 205);
}

}
