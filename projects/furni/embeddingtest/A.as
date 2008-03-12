package {

import flash.display.Sprite;

import com.threerings.util.ClassUtil;

[SWF(width="200", height="200")]
public class A extends Sprite
{
    B;
    public function A ()
    {
        new C();
        trace("get B Class: " + ClassUtil.getClassByName("B"));
    }
}
}
