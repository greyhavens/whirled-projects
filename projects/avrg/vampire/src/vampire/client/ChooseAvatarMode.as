package vampire.client
{
    import com.whirled.contrib.simplegame.AppMode;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;

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
            modeSprite.visible = false;

            var infoPanel :MovieClip = ClientContext.instantiateMovieClip("HUD", "popup_avatar", false);

            modeSprite.addChild(infoPanel);
            ClientContext.centerOnViewableRoom(infoPanel);

            registerListener(infoPanel["choose_female"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_MESSAGE_CHOOSE_FEMALE);
                ClientContext.game.ctx.mainLoop.popMode();
            });

            registerListener(infoPanel["choose_male"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_MESSAGE_CHOOSE_MALE);
                ClientContext.game.ctx.mainLoop.popMode();
            });

            registerListener(infoPanel["avatar_close"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.player.deactivateGame();
            });

            infoPanel.gotoAndStop(1);
        }
        override protected function enter():void
        {
            if (!isFirstTimePlayer() || VConstants.LOCAL_DEBUG_MODE) {
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
                Codes.PLAYER_PROP_LAST_TIME_AWAKE));

            //The last is debugging in whirled dev
            if (isNaN(lastTimeAwake) || lastTimeAwake == 0 || ClientContext.ctrl.player.getPlayerId() == 1735) {
                return true;
            }
            return false;
        }

    }
}