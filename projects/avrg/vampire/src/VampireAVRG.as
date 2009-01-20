package {
import flash.display.Sprite;

import vampire.client.VampireMain;

[SWF(width="700", height="500")]
public class VampireAVRG extends Sprite
{
    public function VampireAVRG()
    {
        addChild( new VampireMain() );
//        var s :Server = new Server();
    }
}
}
