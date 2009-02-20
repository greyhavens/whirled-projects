package fakeavrg
{
    import com.whirled.AbstractControl;
    import com.whirled.avrg.LocalSubControl;
    import com.whirled.contrib.simplegame.util.Rand;
    
    import flash.geom.Point;

    public class LocalSubControlFake extends LocalSubControl
    {
        public function LocalSubControlFake(parent :AbstractControl)
        {
            super(parent);
        }
        
        override public function locationToRoom (x :Number, y :Number, z :Number) :Point
        {
            return new Point(x*500 + 50, z*300 + 350);
        }
        
        override public function locationToPaintable (x :Number, y :Number, z :Number) :Point
        {
            return locationToRoom(x, y, z);
        }
    }
}