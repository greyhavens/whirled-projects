package testing
{
    import com.threerings.flash.SimpleTextButton;
    import com.whirled.EntityControl;
    import com.whirled.avrg.AVRGameRoomEvent;
    import com.whirled.contrib.simplegame.objects.SceneObject;

    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;

    import vampire.client.ClientContext;

    public class LocationTester extends SceneObject
    {
        public function LocationTester()
        {

            modeSprite.graphics.beginFill(0xffffff);
            modeSprite.graphics.drawRect(0,0,350,200);
            modeSprite.graphics.endFill();


            var quit :SimpleTextButton = new SimpleTextButton("Quit");
            modeSprite.addChild(quit);
            registerListener(quit, MouseEvent.CLICK, function(...ignored) :void {
                ClientContext.ctrl.player.deactivateGame();
            });



            var startX :int = 20;
            var startY :int = 50;
            var yInc :int = 20;
            for each(var text :TextField in _allTexts) {
                modeSprite.addChild(text);
                text.width = 300;
                text.x = startX;
                text.y = startY;
                startY += yInc;
            }

            spot.graphics.beginFill(0xff0000);
            spot.graphics.drawCircle(0,0,20);
            spot.graphics.endFill();
            modeSprite.addChild(spot);

            registerListener(ClientContext.ctrl.room, AVRGameRoomEvent.AVATAR_CHANGED, function(e:AVRGameRoomEvent) :void {
                if(int(e.value) == ClientContext.ourPlayerId) {
                    ClientContext.ctrl.local.feedback("Our avatar changed.");
                    update(0);
                }
            });

        }

        override public function get displayObject () :DisplayObject
        {
            return modeSprite;
        }

        override protected function addedToDB():void
        {
//            registerListener(modeSprite.root, MouseEvent.MOUSE_MOVE, function(e:MouseEvent) :void {
//                ClientContext.ctrl.local.feedback("Mouse : " + e.stageX + ", " +  + e.stageY);
//            });
        }

        override protected function update(dt :Number) :void
        {
            super.update(dt);

            _roomBoundsText.text = "_roomBounds: " + ClientContext.ctrl.local.getRoomBounds();

            _getPaintableAreaFullText.text = "_getPaintableArea, full: " +
                ClientContext.ctrl.local.getPaintableArea(true);

            _getPaintableAreaNotFullText.text = "_getPaintableArea, notfull: " +
                ClientContext.ctrl.local.getPaintableArea(false);

            var location :Array = ClientContext.ctrl.room.getEntityProperty(EntityControl.PROP_LOCATION_LOGICAL, ClientContext.ourEntityId) as Array;

            if(location != null) {

                _locationText.text = "Location=" + location;

                _locationToPaintableText.text = "_locationToPaintable: " +
                    ClientContext.ctrl.local.locationToPaintable(location[0], location[1], location[2]);

                _locationToRoomText.text = "_locationToRoom: " +
                    ClientContext.ctrl.local.locationToRoom(location[0], location[1], location[2]);

                var p :Point = ClientContext.ctrl.local.locationToPaintable(location[0], location[1], location[2]);
                spot.x = p.x;
                spot.y = p.y;
            }


        }

        protected var _roomBoundsText :TextField = new TextField();
        protected var _locationText :TextField = new TextField();
        protected var _locationToPaintableText :TextField = new TextField();
        protected var _locationToRoomText :TextField = new TextField();
        protected var _getPaintableAreaFullText :TextField = new TextField();
        protected var _getPaintableAreaNotFullText :TextField = new TextField();

        protected var _allTexts :Array = [
            _roomBoundsText,
            _locationText,
            _locationToPaintableText,
            _locationToRoomText,
            _getPaintableAreaFullText,
            _getPaintableAreaNotFullText
        ];

        protected var modeSprite :Sprite = new Sprite();

        protected var spot :Shape = new Shape();

    }
}