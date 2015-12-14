package client
{
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.Timer;
    
    import sprites.SpriteUtil;

    /**
     * TextField used to make 'loud' annoucements across the bottom of the page.
     */ 
    public class Announcement extends TextField
    {
        public function Announcement(parent:Sprite)
        {
            super();
            _parent = parent;
            autoSize = TextFieldAutoSize.CENTER;
            condenseWhite = true;
            multiline = true;
            background = true;
            backgroundColor = SpriteUtil.DARK_GREY;
            border = false;
            alpha = 0.9;
        }
        
        public function positive () :void
        {
            textColor = SpriteUtil.RED;            
        }
        
        public function negative () :void
        {
            textColor = SpriteUtil.GREEN;
        }
        
        public function set announcement (text:String) :void
        {
            htmlText = "<textstyle leftmargin='2' rightmargin='2'><font face='Helvetica, Arial, _sans' size='30'>" + text + "</font></textstyle>";
        }

        /**
         * Show the announcement for the preset time.  If called while the announcement is already showing,
         * then the timer will be reset.
         */
        public function show () :void
        {
            if (!_parent.contains(this)) {
                _parent.addChild(this);
            }
            startTimer();
        }
        
        protected function startTimer() :void
        {
            if (_timer != null) {
                stopTimer();
            }
            _timer = new Timer(SHOWTIME, 1);
            _timer.addEventListener(TimerEvent.TIMER, handleTimerEvent);
            _timer.start();
        }

        protected function handleTimerEvent (event:TimerEvent) :void
        {
            stopTimer();
            hide();
        }
        
        protected function stopTimer () :void
        {
            _timer.stop();
            _timer = null;
        }
        
        public function hide () :void
        {
            if (_parent.contains(this)) {
                _parent.removeChild(this);
            }
        }
        
        protected var _timer:Timer;
        protected var _parent:Sprite;
        
        protected static const SHOWTIME:int = 5000;
    }
}