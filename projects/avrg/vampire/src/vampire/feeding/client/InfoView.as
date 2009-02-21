package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import vampire.feeding.*;

public class InfoView extends SceneObject
{
    public static function show () :void
    {
        var view :InfoView = GameCtx.gameMode.getObjectNamed(NAME) as InfoView;
        if (view == null) {
            view = new InfoView();
            view.x = LOC.x;
            view.y = LOC.y;
            GameCtx.gameMode.addObject(view, GameCtx.uiLayer);
        }

        view.visible = true;
    }

    public static function hide () :void
    {
        var view :InfoView = GameCtx.gameMode.getObjectNamed(NAME) as InfoView;
        if (view != null) {
            view.visible = false;
        }
    }

    public function InfoView ()
    {
        _movie = ClientCtx.instantiateMovieClip("blood", "info_panel");
        var hideBtn :SimpleButton = _movie["button_close"];
        registerListener(hideBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                InfoView.hide();
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

    protected static const NAME :String = "InfoView";
    protected static const LOC :Vector2 = new Vector2(750, 267);
}

}
