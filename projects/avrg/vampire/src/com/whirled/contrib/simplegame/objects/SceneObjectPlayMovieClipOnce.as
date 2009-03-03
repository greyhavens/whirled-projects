package com.whirled.contrib.simplegame.objects
{
    import flash.display.MovieClip;
    import flash.events.Event;

    public class SceneObjectPlayMovieClipOnce extends SimpleSceneObject
    {
        public function SceneObjectPlayMovieClipOnce(mc :MovieClip, name :String = null)
        {
            super(mc, name);
            _mc = mc;
            _mc.gotoAndStop(1);
            registerListener( _mc, Event.ENTER_FRAME, handleEnterFrame);
        }

        protected function handleEnterFrame(...ignored) :void
        {
            if( _mc.currentFrame >= _mc.totalFrames) {
                destroySelf();
            }
        }

        override protected function addedToDB () :void
        {
            _mc.play();
        }

        protected var _mc :MovieClip;
    }
}