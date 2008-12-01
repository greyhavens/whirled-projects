package {

import flash.display.Sprite;

import com.whirled.AVRGameClientControl;

public class Game extends Sprite
{
    public function Game ()
    {
        new AVRGameClientControl(this); // Unused, but stops backend from complaining
    }
}

}
