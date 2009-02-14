package vampire.feeding.debug {

import com.whirled.avrg.AVRGameControl;

import flash.display.Sprite;

import vampire.feeding.client.BloodBloom;

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
