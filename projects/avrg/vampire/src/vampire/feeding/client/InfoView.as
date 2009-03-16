package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.feeding.*;

public class InfoView extends SceneObject
{
    public static function show () :void
    {
        var view :InfoView = ClientCtx.mainLoop.topMode.getObjectNamed(NAME) as InfoView;
        if (view == null) {
            view = new InfoView();
            view.x = LOC.x + (view.width * 0.5);
            view.y = LOC.y + (view.height * 0.5);

            var parent :Sprite = (ClientCtx.mainLoop.topMode == GameCtx.gameMode ?
                                  GameCtx.uiLayer :
                                  ClientCtx.mainLoop.topMode.modeSprite);
            ClientCtx.mainLoop.topMode.addSceneObject(view, parent);
        }

        view.visible = true;
    }

    public static function hide () :void
    {
        var view :InfoView = ClientCtx.mainLoop.topMode.getObjectNamed(NAME) as InfoView;
        if (view != null) {
            view.visible = false;
        }
    }

    public function InfoView (okCallback :Function = null)
    {
        _okCallback = okCallback;
        _movie = ClientCtx.instantiateMovieClip("blood", "info_panel");
        var okBtn :SimpleButton = _movie["button_ok"];
        registerListener(okBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                InfoView.hide();
                if (_okCallback != null) {
                    _okCallback();
                }
            });
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _movie :MovieClip;
    protected var _okCallback :Function;

    protected static const NAME :String = "InfoView";
    protected static const LOC :Vector2 = new Vector2(540, 0);
}

}
