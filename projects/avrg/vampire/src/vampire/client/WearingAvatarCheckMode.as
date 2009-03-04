package vampire.client
{
    import com.whirled.contrib.simplegame.AppMode;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class WearingAvatarCheckMode extends AppMode
    {
        public function WearingAvatarCheckMode()
        {
            super();
        }

        override protected function setup():void
        {
            modeSprite.visible = false;

            var infoPanel :MovieClip = ClientContext.instantiateMovieClip("HUD", "popup_avatar", false);
            modeSprite.addChild( infoPanel );


            registerListener( infoPanel["button_ok"], MouseEvent.CLICK, function(...ignored) :void {
                tryStarting();
            });
            registerListener( infoPanel["avatar_close"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.player.deactivateGame();
            });

            infoPanel.gotoAndStop(2);
            infoPanel.x = ClientContext.ctrl.local.getRoomBounds()[0]/2;
            infoPanel.y = ClientContext.ctrl.local.getRoomBounds()[1]/2;


        }
        override protected function enter():void
        {
            if( ClientContext.isWearingValidAvatar ) {
                ClientContext.game.ctx.mainLoop.popMode();
            }
            else {
                modeSprite.visible = true;
            }
        }

        protected function tryStarting() :void
        {
            if( ClientContext.isWearingValidAvatar ) {
                ClientContext.game.ctx.mainLoop.popMode();
            }
            else {
                ClientContext.ctrl.local.feedback("The game cannot start until you are wearing a Vampire Whirled avatar.");
            }
        }

    }
}