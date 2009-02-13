package vampire.feeding.client {

import com.whirled.avrg.AVRGameControl;

import flash.display.Sprite;

[SWF(width="700", height="500", frameRate="30")]
public class BloodBloomStandalone extends Sprite
{
    public function BloodBloomStandalone ()
    {
        BloodBloom.init(this, new AVRGameControl(this));
        addChild(new BloodBloom(0));
    }
}

}
