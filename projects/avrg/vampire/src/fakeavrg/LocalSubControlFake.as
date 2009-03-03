package fakeavrg
{
    import com.whirled.AbstractControl;
    import com.whirled.avrg.LocalSubControl;

    import flash.geom.Point;

    import framework.FakeAVRGContext;

    public class LocalSubControlFake extends LocalSubControl
    {
        public function LocalSubControlFake(parent :AbstractControl)
        {
            super(parent);
        }

        override public function locationToRoom (x :Number, y :Number, z :Number) :Point
        {
            var xMinFront :Number = 0;
            var xMaxFront :Number = 700;
            var xMinBack :Number = 50;
            var xMaxBack :Number = 600;

            return new Point(x*700, 500 - (z*240));
        }

        override public function locationToPaintable (x :Number, y :Number, z :Number) :Point
        {
            return locationToRoom(x, y, z);
        }

        override public function getRoomBounds () :Array
        {
            return FakeAVRGContext.roomBounds;
        }
    }
}