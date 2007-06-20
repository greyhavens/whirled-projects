package {

import flash.display.Sprite;

import com.threerings.flash.FPSDisplay;

[SWF(width="63", height="20")]
public class Fps extends Sprite
{
    public function Fps ()
    {
        addChild(new FPSDisplay());
    }
}
}
