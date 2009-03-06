package vampire.client
{
    import com.threerings.flash.DisplayUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.avrg.DraggableSceneObject;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import vampire.feeding.Constants;
    import vampire.feeding.PlayerFeedingData;

    public class HelpPopup extends DraggableSceneObject
    {
        public function HelpPopup( startframe :String = "intro")
        {
            super(ClientContext.ctrl);

//            _displaySprite.addChild( _bloodTypeOverlay );
//            _bloodTypeOverlay.graphics.beginFill(1);
//            _bloodTypeOverlay.graphics.drawCircle(0, 0, 30);
//            _bloodTypeOverlay.graphics.endFill();
//
//            init( new Rectangle(-_displaySprite.width/2, _displaySprite.height/2, _displaySprite.width, _displaySprite.height), 0, 0, 0, 100);
//
//            return;
//            _sceneObjectSprite = new DraggableSprite(ClientContext.ctrl, NAME);
//            _sceneObjectSprite = new Sprite();
//            _displaySprite.addChild( _sceneObjectSprite );

//            registerListener( _sceneObjectSprite, MouseEvent.CLICK, function(...ignored) :void {
//                trace("_sceneObjectSprite clicked");
//            });
//            _sceneObjectSprite.init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
//            _sceneObjectSprite.x = 20;
//            _sceneObjectSprite.y = 20;

//            _sceneObjectSprite.x = 20;
//            _sceneObjectSprite.y = 20;



            _hudHelp = ClientContext.instantiateMovieClip("HUD", "popup_help", false);
            _displaySprite.addChild( _hudHelp );
            _displaySprite.addChild( _bloodTypeOverlay );
//            _bloodTypeOverlay.graphics.beginFill(1);
//            _bloodTypeOverlay.graphics.drawCircle(0, 0, 30);
//            _bloodTypeOverlay.graphics.endFill();
//            _hudHelp.x += _hudHelp.width / 2 + 20;
//            _hudHelp.y += _hudHelp.height / 2 + 20;
//            _sceneObjectSprite.addChild( _hudHelp );

            //Debugging
            function listChildren( mv :MovieClip ) :void
            {
                for( var i :int = 0; i < mv.numChildren; i++) {
                    trace("Child " + mv.getChildAt(i).name);
                }
            }
//            listChildren(_hudHelp);



            //Wire up the buttons
            //On Introduction
//            updateBloodStrainPage();




            _hudHelp.gotoAndStop("intro");
            registerListener( SimpleButton(findSafely("button_tofeedinggame")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("feedinggame");
                });
            registerListener( SimpleButton(findSafely("button_tolineage")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("lineage");
                });
            registerListener( SimpleButton(findSafely("button_tovamps")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("vamps");
                });
            registerListener( SimpleButton(findSafely("button_tomortals")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("mortals");
                });
            registerListener( SimpleButton(findSafely("button_tobloodbond")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("bloodbond");
                });
            registerListener( SimpleButton(findSafely("button_tomortals")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("mortals");
                });
            registerListener( SimpleButton(findSafely("button_tobloodtype")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    _frameHistory.push( _hudHelp.currentFrame );
                    _hudHelp.gotoAndStop("bloodtype");
                });
            registerListener( SimpleButton(findSafely("help_close")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    destroySelf();
                });
            registerListener( SimpleButton(findSafely("button_torecruiting")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    ClientContext.ctrl.local.showInvitePage("Join my Coven!", "" + ClientContext.ourPlayerId);
                });


            registerListener( SimpleButton(findSafely("help_back")), MouseEvent.CLICK,
                backButtonPushed);




            //Update the strains collected

//            gotoFrame("bloodtype");
//            updateBloodStrainPage();
            if( startframe != null ) {
                _hudHelp.gotoAndStop(startframe);
            }


//            if( ClientContext.ctrl.local.getPaintableArea() != null) {
//                //Workaround as roombounds can be bigger than the paintable area
//                if( ClientContext.ctrl.local
//
//                this.x = ClientContext.ctrl.local.getRoomBounds()[0]/2;// - _displaySprite.width/2;
//                this.y = ClientContext.ctrl.local.getRoomBounds().height/2;// - _displaySprite.height/2;
//            }
//            registerListener( ClientContext.ctrl.local, AVRGameControlEvent.SIZE_CHANGED, function(...ignored) :void {
//                if( ClientContext.ctrl.local.getPaintableArea() != null) {
//                    _sceneObjectSprite.x = ClientContext.ctrl.local.getPaintableArea().width/2 - _sceneObjectSprite.width/2;
//                    _sceneObjectSprite.y = ClientContext.ctrl.local.getPaintableArea().height/2 - _sceneObjectSprite.height/2;
//                }
//            });

            init( new Rectangle(-_displaySprite.width/2, _displaySprite.height/2, _displaySprite.width, _displaySprite.height), 0, 0, 0, 100);
            centerOnViewableRoom();
        }

        protected function updateBloodStrainPage() :void
        {
//            _hudHelp.gotoAndStop("bloodtype");
            var feedingData :PlayerFeedingData = ClientContext.model.playerFeedingData;
            if( feedingData == null ) {
                log.error("updateBloodStrainPage, feedingData == null");
                return;
            }
//            _hudHelp.gotoAndStop("intro");
            while(_bloodTypeOverlay.numChildren) { _bloodTypeOverlay.removeChildAt(0);}

            for( var i :int = 1; i < 13; i++) {
                var numberAsText :String = String(i);
                if( numberAsText.length == 1) {
                    numberAsText = "0" + numberAsText;
                }
                var textFieldName :String = "indicator_" + numberAsText;

//                var tf :TextField = findSafely(textFieldName) as TextField;
                var tf :MovieClip = _hudHelp[textFieldName] as MovieClip;
                if( tf == null ) {
                    log.error(textFieldName + " is null");
                    continue;
                }
//                trace("\n" + textFieldName);
//                listChildren(tf);
                TextField(tf["tally"]).text = "asdfsadfdsf";
                var tally :TextField = TextField(tf["tally"]);

                var replacementTextField :TextField = new TextField();
                replacementTextField.text = feedingData.getStrainCount( i - 1 ) + " / " + Constants.MAX_COLLECTIONS_PER_STRAIN;
                replacementTextField.x = tally.x;
                replacementTextField.y = tally.y;
                replacementTextField.textColor = 0xffffff;

                var format :TextFormat = new TextFormat();
                format.size = 16;
                format.color = 0xffffff;
                format.align = TextFormatAlign.LEFT;
                format.bold = true;
                replacementTextField.setTextFormat( format );
                tf.addChild( replacementTextField);

//                trace("\n" + tf.name + ", text before=" + tf.text + ", loc=(" + tf.x + ", " + tf.y);
//                tf.selectable = false;
//                trace("Setting new text=" + (feedingData.getStrainCount( i - 1 ) + "/" + Constants.MAX_COLLECTIONS_PER_STRAIN));
//                tf.text = feedingData.getStrainCount( i - 1 ) + "/" + Constants.MAX_COLLECTIONS_PER_STRAIN;
//                trace(tf.name + ", text after=" + tf.text);
//                registerListener(tf, MouseEvent.ROLL_OVER, function(...ignored) :void {
//                   tf.text = "Mouse over"
//                });
//                registerListener(tf, MouseEvent.ROLL_OUT, function(...ignored) :void {
//                   tf.text = "Mouse out"
//                });

//                var tf2 :TextField = new TextField();
//                tf2.text = tf.text;
//                tf2.x = tf.x;
//                tf2.y = tf.y;
//                tf2.name = tf.name;
//                var parent :DisplayObjectContainer = tf.parent;
//                if( parent == null) {
//                    trace("parent is null");
//                }
//                if( parent.contains( tf ) ) {
//                    trace("removing from parent " + tf.parent.name);
//                    parent.removeChild( tf );
//                }

                var startX :int = tf.x;
                var startY :int = tf.y;
                var strainCount :int = feedingData.getStrainCount( i - 1 );

                var cell :DisplayObject;
                var j :int;
                for( j = 0; j < strainCount; j++) {
                    cell = getFullCellSprite();
                    cell.x = startX;
                    cell.y = startY;
                    _bloodTypeOverlay.addChild( cell );
                    startX += cell.width + 5;
//                    trace("drawing full cell for " + tf.name);
//                    trace(startX + ", " + startY);
                }
                for( ; j < Constants.MAX_COLLECTIONS_PER_STRAIN; j++) {
                    cell = getEmptyCellSprite();
                    cell.x = startX;
                    cell.y = startY;
//                    trace("drawing empty cell for " + tf.name);
                    _bloodTypeOverlay.addChild( cell );
                    startX += cell.width + 5;
//                    trace(startX + ", " + startY);
                }




            }

            function listChildren( mv :DisplayObjectContainer ) :void
            {
                for( var i :int = 0; i < mv.numChildren; i++) {
                    trace("Child " + mv.getChildAt(i).name);
                }
            }
//            listChildren(_hudHelp);
        }

        protected function getFullCellSprite() :DisplayObject
        {
            var s :Shape = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawCircle(0, 0, 10 );
            s.graphics.endFill();
            return s;
        }

        protected function getEmptyCellSprite() :DisplayObject
        {
            var s :Shape = new Shape();
            s.graphics.lineStyle(1);
            s.graphics.drawCircle(0, 0, 10 );
            return s;
        }

        protected function findSafely (name :String) :DisplayObject
        {
            var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
            if (o == null) {
                throw new Error("Cannot find object: " + name);
            }
            return o;
        }

        public function gotoFrame( frame :String ) :void
        {
            _hudHelp.gotoAndStop(frame);
            if( frame == "bloodtype") {
//                _hudHelp.addChild( _bloodTypeOverlay );
//                updateBloodStrainPage();
            }
            else {
//                if( _hudHelp.contains( _bloodTypeOverlay ) ) {
//                    _hudHelp.removeChild( _bloodTypeOverlay );
//                }
            }
        }

        protected function backButtonPushed(...ignored) :void
        {
            if( _frameHistory.length > 0) {
                var nextFrame :int = _frameHistory.pop();
                _hudHelp.gotoAndStop( nextFrame );
            }
        }

//        override public function get displayObject () :DisplayObject
//        {
//            return _sceneObjectSprite;
//        }

        override public function get objectName () :String
        {
            return NAME;
        }

        protected var _hudHelp :MovieClip;
//        protected var _sceneObjectSprite :DraggableSprite;
//        protected var _sceneObjectSprite :Sprite;
        protected var _frameHistory :Array = new Array();
        protected var _bloodTypeOverlay :Sprite = new Sprite();

        public static const NAME :String = "HelpPopup";
        protected static const log :Log = Log.getLog( HelpPopup );

    }
}