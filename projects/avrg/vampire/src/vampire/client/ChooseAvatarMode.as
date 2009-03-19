package vampire.client
{
    import com.whirled.contrib.avrg.DraggableSceneObject;
    import com.whirled.contrib.simplegame.AppMode;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import vampire.data.Codes;
    import vampire.data.VConstants;

    public class ChooseAvatarMode extends AppMode
    {
        public function ChooseAvatarMode()
        {
            super();
        }

        override protected function setup():void
        {


            return;

            modeSprite.visible = false;


            var infoPanel :MovieClip = ClientContext.instantiateMovieClip("HUD", "popup_avatar", false);

            var drag :DraggableSceneObject = new DraggableSceneObject(ClientContext.ctrl);
            drag.displaySprite.addChild( infoPanel );
            drag.init( new Rectangle(0,0,100, 100), 0, 0, 0, 0);

            modeSprite.addChild( drag.displaySprite );
            drag.centerOnViewableRoom();

            registerListener( infoPanel["choose_female"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_MESSAGE_CHOOSE_FEMALE);
                ClientContext.game.ctx.mainLoop.popMode();
            });

            registerListener( infoPanel["choose_male"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_MESSAGE_CHOOSE_MALE);
                ClientContext.game.ctx.mainLoop.popMode();
            });

            registerListener( infoPanel["avatar_close"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.player.deactivateGame();
            });


            infoPanel.gotoAndStop(1);
//            infoPanel.x = infoPanel.width/2 + 20;//ClientContext.ctrl.local.getRoomBounds()[0]/2;
//            infoPanel.y = infoPanel.height/2 + 20;;//ClientContext.ctrl.local.getRoomBounds()[1]/2;

//            drag.x = ClientContext.ctrl.local.getPaintableArea().width/2;
//            drag.y = ClientContext.ctrl.local.getPaintableArea().height/2;

//            registerListener( ClientContext.ctrl.local, AVRGameControlEvent.SIZE_CHANGED, function(...ignored) :void {
//                infoPanel.x = ClientContext.ctrl.local.getPaintableArea().width/2;
//                infoPanel.y = ClientContext.ctrl.local.getPaintableArea().height/2;
//            });
        }
        override protected function enter():void
        {
            if( !isFirstTimePlayer() ) {
                //Push the main game mode
                ClientContext.game.ctx.mainLoop.popMode();
            }
            else {
                ClientContext.isNewPlayer = true;
                modeSprite.visible = true;
            }
        }

        protected function isFirstTimePlayer() :Boolean
        {
            var lastTimeAwake :Number = Number(ClientContext.ctrl.player.props.get(
                Codes.PLAYER_PROP_LAST_TIME_AWAKE ) );

            //The last is debugging in whirled dev
            if( isNaN( lastTimeAwake ) || lastTimeAwake == 0 || ClientContext.ctrl.player.getPlayerId() == 1735) {
                return true;
            }
            return false;
        }

    }
}