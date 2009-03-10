package vampire.client
{
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.DraggableSceneObject;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * Shows a customisable popup, optionally with an arrow showing a link something else,
 * e.g. an avatar HUD or a GUI component.
 *
 */
public class PopupMessage extends DraggableSceneObject
{
    public function PopupMessage(ctrl :AVRGameControl, message :String, target :SceneObject = null)
    {
        super(ctrl, NAME);
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _popupPanel.mouseEnabled = true;
        _popupPanel.mouseChildren = true;
        _displaySprite.addChild( _popupPanel );

        registerListener( _popupPanel["popup_close"], MouseEvent.CLICK,
            function( e :MouseEvent ) :void {
                destroySelf();
            });

//        init( new Rectangle(-_popupPanel.width/2, _popupPanel.height/2, _popupPanel.width, _popupPanel.height), 0, 0, 0, 0);
        init( new Rectangle(-10, -10, 20, 20), 0, 0, 0, 0);
        centerOnViewableRoom();
        _target = target;

        if( _target != null ) {
            _target.displayObject.filters = [glowFilter];
        }
    }


    override protected function destroyed():void
    {
        if( _target != null ) {
            _target.displayObject.filters = [];
        }
    }


    override protected function update(dt:Number):void
    {
        super.update(dt);
    }

    protected var _popupPanel :MovieClip;
    protected var _target :SceneObject;

    public static const glowFilter :GlowFilter = new GlowFilter(0xffffff, 1, 32, 32, 2, 1);
    public static const NAME :String = "Popup Message";

}
}