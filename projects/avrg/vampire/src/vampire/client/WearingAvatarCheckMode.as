package vampire.client
{
import com.whirled.avrg.AVRGameControlEvent;
import com.threerings.flashbang.AppMode;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
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

        _infoPanel = ClientContext.instantiateMovieClip("HUD", "popup_avatar", false);
        modeSprite.addChild(_infoPanel);

        //First disable the button
        _infoPanel.gotoAndStop(2);
        var startButton :SimpleButton = SimpleButton(_infoPanel["button_ok"]);
        startButton.enabled = false;
        _buttonGreyout = new Sprite();
        _buttonGreyout.graphics.beginFill(0, 0.6);
        _buttonGreyout.graphics.drawRect(startButton.x - startButton.width / 2 + 4,
                                         startButton.y - startButton.height / 2,
                                         startButton.width,
                                         startButton.height);
        _buttonGreyout.graphics.endFill();
        startButton.parent.addChild(_buttonGreyout);

        registerListener(_infoPanel["avatar_close"], MouseEvent.CLICK, function(...ignored) :void {
            ClientContext.ctrl.player.deactivateGame();
        });

        _infoPanel.x = ClientContext.ctrl.local.getPaintableArea().width/2;//ClientContext.ctrl.local.getRoomBounds()[0]/2;
        _infoPanel.y = ClientContext.ctrl.local.getPaintableArea().height/2;//ClientContext.ctrl.local.getRoomBounds()[1]/2;

        registerListener(ClientContext.ctrl.local, AVRGameControlEvent.SIZE_CHANGED, function(...ignored) :void {
            _infoPanel.x = ClientContext.ctrl.local.getPaintableArea().width/2;
            _infoPanel.y = ClientContext.ctrl.local.getPaintableArea().height/2;
        });

    }

    override public function update (dt:Number) :void
    {
        super.update(dt);

        if (!_isValidAvatar && ClientContext.isWearingValidAvatar) {
            _isValidAvatar = true;
            SimpleButton(_infoPanel["button_ok"]).enabled = true;
            if (_buttonGreyout.parent != null) {
                _buttonGreyout.parent.removeChild(_buttonGreyout);
            }
            registerListener(_infoPanel["button_ok"], MouseEvent.CLICK, function(...ignored) :void {
                tryStarting();
            });
        }
    }

    override protected function enter():void
    {
        if (ClientContext.isWearingValidAvatar){// || VConstants.LOCAL_DEBUG_MODE) {
            ClientContext.game.ctx.mainLoop.popMode();
        }
        else {
            modeSprite.visible = true;
        }
    }

    protected function tryStarting() :void
    {
        if (ClientContext.isWearingValidAvatar) {
            ClientContext.game.ctx.mainLoop.popMode();
        }
        else {
            ClientContext.ctrl.local.feedback("The game cannot start until you are wearing a Vampire Whirled avatar.");
        }
    }

    protected var _infoPanel :MovieClip;
    protected var _buttonGreyout :Sprite;
    protected var _isValidAvatar :Boolean = false;

}
}
