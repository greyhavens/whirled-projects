package vampire.client
{
import com.whirled.contrib.avrg.RoomDragger;
import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.objects.Dragger;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import vampire.data.Lineage;

public class PopupLineage extends DraggableObject
{
    public function PopupLineage(playerCenter :int)
    {
        super(null, null);
        _playerId = playerCenter;
        trace("PopupLineage " + playerCenter);
        var popupPanel :MovieClip = ClientContext.instantiateMovieClip("HUD", "popup", false);
        ClientUtil.detach(DisplayObject(popupPanel["button_01"]));
        ClientUtil.detach(DisplayObject(popupPanel["button_02"]));
        _displaySprite.addChildAt(popupPanel, 0);
        //Close button shuts the popup
        var closeButton :SimpleButton = popupPanel["button_close"] as SimpleButton;
        registerListener(closeButton, MouseEvent.CLICK, function (e :MouseEvent) :void {
            destroySelf();
        });

        popupPanel.width = 300;
        popupPanel.height = 300;

        ClientContext.centerOnViewableRoom(_displaySprite);

        var lineage :Lineage = ClientContext.gameMode.roomModel.getLineage(playerCenter);

        _lineageView = new LineageViewBase(lineage, playerCenter);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _displaySprite.addChild(_lineageView.displayObject);
        db.addObject(_lineageView);
    }

    override protected function destroyed () :void
    {
        _lineageView.destroySelf();
    }

    override protected function createDragger () :Dragger
    {
        return new RoomDragger(ClientContext.ctrl, this.draggableObject, this.displayObject);
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    override public function get objectName () :String
    {
        return NAME + _playerId;
    }

    protected var _lineageView :LineageViewBase;
    protected var _playerId :int;
    protected var _displaySprite :Sprite = new Sprite();
    public static const NAME :String = "PopupLineage";

}
}