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

    import vampire.data.Logic;
    import vampire.feeding.Constants;
    import vampire.feeding.PlayerFeedingData;

    public class HelpPopup extends DraggableSceneObject
    {
        public function HelpPopup( startframe :String = "intro")
        {
            super(ClientContext.ctrl);

            _hudHelp = ClientContext.instantiateMovieClip("HUD", "popup_help", false);
            _displaySprite.addChild( _hudHelp );
            _displaySprite.addChild( _bloodTypeOverlay );

            //Make sure the blood strain page shows current data
            updateBloodStrainPage();




            //Wire up the buttons
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

            if( startframe != null ) {
                _hudHelp.gotoAndStop(startframe);
            }

            init( new Rectangle(-_displaySprite.width/2, _displaySprite.height/2, _displaySprite.width, _displaySprite.height), 0, 0, 0, 100);
            centerOnViewableRoom();
        }

        protected function updateBloodStrainPage() :void
        {
            var feedingData :PlayerFeedingData = ClientContext.model.playerFeedingData;
            if( feedingData == null ) {
                log.error("updateBloodStrainPage, feedingData == null");
                return;
            }
            while(_bloodTypeOverlay.numChildren) { _bloodTypeOverlay.removeChildAt(0);}

            for( var i :int = 1; i < 13; i++) {
                var numberAsText :String = String(i);
                if( numberAsText.length == 1) {
                    numberAsText = "0" + numberAsText;
                }
                var textFieldName :String = "indicator_" + numberAsText;

                var tf :MovieClip = _hudHelp[textFieldName] as MovieClip;
                if( tf == null ) {
                    log.error(textFieldName + " is null");
                    continue;
                }

                if( Logic.getPlayerBloodStrain( ClientContext.ourPlayerId ) == i) {
                    tf.gotoAndStop(3);
                }

                if( Logic.getPlayerPreferredBloodStrain( ClientContext.ourPlayerId ) == i) {
                    tf.gotoAndStop(2);
                }

                TextField(tf["tally"]).text = "";
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


                var starsignTextField :TextField = new TextField();
                starsignTextField.text = BLOOD_STRAIN_NAMES[i - 1];
                starsignTextField.x = tally.x - 130;
                starsignTextField.y = tally.y;

                var starSignformat :TextFormat = new TextFormat();
                starSignformat.size = 16;
                starSignformat.color = 0xffffff;
                starSignformat.align = TextFormatAlign.RIGHT;
                starSignformat.bold = true;
                starsignTextField.setTextFormat( starSignformat );
                tf.addChild( starsignTextField);
            }
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
                updateBloodStrainPage();
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

        protected static const BLOOD_STRAIN_NAMES :Array = [
            "Aries",
            "Taurus",
            "Gemini",
            "Cancer",
            "Leo",
            "Virgo",
            "Libra",
            "Scorpio",
            "Sagittarius",
            "Capricorn",
            "Aquarius",
            "Pisces"
        ];

    }
}