package testing
{
    import com.whirled.contrib.simplegame.AppMode;

    public class TestMode extends AppMode
    {
        override protected function setup():void
        {
//            trace("adafdsf");
            addObject(new LocationTester(), modeSprite);
        }

    }
}