package vampire.client
{
    import com.threerings.flashbang.AppMode;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    import vampire.data.Codes;
    import vampire.data.VConstants;
    import vampire.net.messages.AvatarChosenMsg;

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
                ClientContext.ctrl.agent.sendMessage(AvatarChosenMsg.NAME, new AvatarChosenMsg(
                    ClientContext.ourPlayerId, AvatarChosenMsg.AVATAR_FEMALE).toBytes());
                ClientContext.game.ctx.mainLoop.popMode();
            });

            registerListener(infoPanel["choose_male"], MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.agent.sendMessage(AvatarChosenMsg.NAME, new AvatarChosenMsg(
                    ClientContext.ourPlayerId, AvatarChosenMsg.AVATAR_MALE).toBytes());
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
                Codes.PLAYER_PROP_TIME));

            //The last is debugging in whirled dev
            if (isNaN(lastTimeAwake) || lastTimeAwake == 0) {
                return true;
            }
            return false;
        }

    }
}
