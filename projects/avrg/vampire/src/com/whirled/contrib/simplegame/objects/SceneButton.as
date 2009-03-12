package com.whirled.contrib.simplegame.objects
{
    import flash.display.SimpleButton;

    public class SceneButton extends SimpleSceneObject
    {
        public function SceneButton( button :SimpleButton, name :String = null)
        {
            super(button, name);
            _button = button;
        }

        public function get button() :SimpleButton
        {
            return _button;
        }

        public function registerButtonListener( eventname :String, f :Function ) :void
        {
            registerListener( _button, eventname, f);
        }

        public function get mouseEnabled() :Boolean
        {
            return _button.mouseEnabled;
        }
        public function set mouseEnabled( m :Boolean ) :void
        {
            _button.mouseEnabled = m;
        }

        protected var _button :SimpleButton;

    }
}