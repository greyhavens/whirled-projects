package fakeavrg
{
    import com.whirled.ServerObject;
    import com.whirled.avrg.AVRServerGameControl;
    
    import flash.display.DisplayObject;

    public class AVRServerGameControlFake extends AVRServerGameControl
    {
        public function AVRServerGameControlFake(d :DisplayObject)
        {
            var fakeserverobject :ServerObjectFake = new ServerObjectFake( d );
            super(fakeserverobject);
        }
        
    }
}
    import flash.display.DisplayObject;
    import com.whirled.ServerObject;
    

