package vampire.client
{
    import com.threerings.flash.DisplayUtil;
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.avrg.DraggableSceneObject;
    import com.whirled.net.ElementChangedEvent;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import vampire.Util;
    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.data.SharedPlayerStateClient;
    import vampire.data.VConstants;
    import vampire.feeding.Constants;
    import vampire.feeding.PlayerFeedingData;

    public class HelpPopup extends DraggableSceneObject
    {
        public function HelpPopup( startframe :String = "intro")
        {
            super(ClientContext.ctrl);

            _hudHelp = ClientContext.instantiateMovieClip("HUD", "popup_help", false);
            _displaySprite.addChild( _hudHelp );

            _lineageView = new LineageView();

            //Go to the first frame where all the buttons are.  Even though not all buttons are
            //visible there, obviously, however they need to be instantiated on the first frame
            //otherwise they cannot be 'found'.
            _hudHelp.gotoAndStop("intro");

            //Wire up the links on the left panel
            registerListener( SimpleButton(findSafely("to_default")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("default");
                });
            registerListener( SimpleButton(findSafely("to_bloodtype")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("bloodtype");
                });
            registerListener( SimpleButton(findSafely("menu_tofeedingonvamps")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("vamps");
                });
            registerListener( SimpleButton(findSafely("menu_tofeedinggame")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("feedinggame");
                });
            registerListener( SimpleButton(findSafely("menu_tointro")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("intro");
                });


            //Wire up the buttons
            registerListener( SimpleButton(findSafely("button_tofeedinggame")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("feedinggame");
                });
            registerListener( SimpleButton(findSafely("button_tolineage")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("lineage");
                });
            registerListener( SimpleButton(findSafely("button_tovamps")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("vamps");
                });
            registerListener( SimpleButton(findSafely("button_tomortals")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("mortals");
                });
            registerListener( SimpleButton(findSafely("button_tobloodbond")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("bloodbond");
                });
            registerListener( SimpleButton(findSafely("button_tomortals")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("mortals");
                });
            registerListener( SimpleButton(findSafely("button_tobloodtype")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("bloodtype");
                });
            registerListener( SimpleButton(findSafely("button_toinstructions")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("instructions");
                });
            registerListener( SimpleButton(findSafely("help_close")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    destroySelf();
                });
            registerListener( SimpleButton(findSafely("button_recruit")), MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    ClientContext.ctrl.local.showInvitePage("Join my Coven!", "" + ClientContext.ourPlayerId);
                });

            registerListener( SimpleButton(findSafely("help_back")), MouseEvent.CLICK,
                backButtonPushed);

            _bondTextAnchor = findSafely("text_bloodbond") as TextField;
            _bloodbondIconAnchor = findSafely("bond_icon");
            registerListener( ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
            _infoTextAnchor = findSafely("text_blood") as TextField;

            _getSiresButton = findSafely("link_tovamps") as SimpleButton;
            _getMinionsButton = findSafely("link_tolineage") as SimpleButton;

            registerListener( _getSiresButton, MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("vamps");
                });
            registerListener( _getMinionsButton, MouseEvent.CLICK,
                function( e :MouseEvent ) :void {
                    gotoFrame("lineage");
                });

            gotoFrame(startframe );


            //Listen for changes to the Lineage.  We will need to redraw the Lineage view.
//            registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED,
//                function(...ignored) :void {
//                    if( _hudHelp.currentLabel == "default" ) {
//                        gotoFrame("default");
//                    }
//                });

            //Listen for changes to the blood or xp or bloodbonded
//            registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED,
//                function(e :ElementChangedEvent) :void {
//                    if( e.name == ClientContext.ourRoomKey && _hudHelp.currentLabel == "default") {
//                        gotoFrame("default");
//                    }
//                });

            init( new Rectangle(-_displaySprite.width/2, _displaySprite.height/2, _displaySprite.width, _displaySprite.height), 0, 0, 0, 100);
            centerOnViewableRoom();
        }


        protected function elementChanged (e :ElementChangedEvent) :void
        {
            var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );

            if( playerIdUpdated == ClientContext.ourPlayerId) {

                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED
                    || e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME) {
                    showBloodBonded();
                }
            }
        }

        protected function showBloodBonded() :void
        {
            if( ClientContext.model.bloodbonded <= 0 ) {
                return;
            }
            redoBloodBondText(ClientContext.model.bloodbondedName);
        }


        protected function addGlowFilter( obj : InteractiveObject ) :void
        {
            registerListener( obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
                obj.filters = [_glowFilter];
            });
            registerListener( obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
                obj.filters = [];
            })
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

        override public function destroySelf():void
        {
            super.destroySelf();
            if( _lineageView != null && _lineageView.isLiveObject ) {
                _lineageView.destroySelf();

            }
        }

        override protected function addedToDB():void
        {

            db.addObject( _lineageView );
            if( _hudHelp.currentFrame == 2 ) {
                _hudHelp.addChild( _lineageView.displayObject );
            }
        }


//        protected function getFullCellSprite() :DisplayObject
//        {
//            var s :Shape = new Shape();
//            s.graphics.beginFill(0);
//            s.graphics.drawCircle(0, 0, 10 );
//            s.graphics.endFill();
//            return s;
//        }
//
//        protected function getEmptyCellSprite() :DisplayObject
//        {
//            var s :Shape = new Shape();
//            s.graphics.lineStyle(1);
//            s.graphics.drawCircle(0, 0, 10 );
//            return s;
//        }

        protected function findSafely (name :String) :DisplayObject
        {
            var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
            if (o == null) {
                throw new Error("Cannot find object: " + name);
            }
            return o;
        }

        protected function removeExtraHelpPanels() :void
        {
            if( _hudHelp.contains( _bloodTypeOverlay ) ) {
                _hudHelp.removeChild( _bloodTypeOverlay );
            }

            if( _hudHelp.contains( _lineageView.displayObject ) ) {
                _hudHelp.removeChild( _lineageView.displayObject );
            }

            if( _bondText != null && _bondText.parent != null
                && _bondText.parent.contains(_bondText)) {

                _bondText.parent.removeChild( _bondText );
            }

            if( _infoText != null && _infoText.parent != null) {
                _infoText.parent.removeChild( _infoText );
            }


        }

        public function gotoFrame( frame :String, addFrameToHistory :Boolean = true ) :void
        {
            if( frame == null) {
                frame = "default";
            }

            if( addFrameToHistory && (_frameHistory.length == 0 || _frameHistory[ _frameHistory.length - 1] != _hudHelp.currentLabel)) {
                _frameHistory.push( _hudHelp.currentLabel );
            }
            _hudHelp.gotoAndStop(frame);

            removeExtraHelpPanels();

            switch( frame ) {
                case "bloodtype":
                    updateBloodStrainPage();
                    _hudHelp.addChild( _bloodTypeOverlay );
                    break;
                case "default":

                    //Center the lineage view on the anchor created for it.
                    var lineage_center :MovieClip = findSafely("lineage_center") as MovieClip;
                    lineage_center.parent.addChild( _lineageView.displayObject );
                    _lineageView.x = lineage_center.x;
                    _lineageView.y = lineage_center.y;// - 20;

                    //Add the clickable, glowable bloodbond icon
                    var bloodbondIcon :MovieClip = ClientContext.instantiateMovieClip("HUD", "bond_icon", false);

                    registerListener( bloodbondIcon, MouseEvent.CLICK,
                        function( e :MouseEvent ) :void {
                            if( bloodbondIcon.parent != null ) {
                                bloodbondIcon.parent.removeChild( bloodbondIcon );
                            }
                            gotoFrame("bloodbond");
                        });

                    addGlowFilter( bloodbondIcon );
                    bloodbondIcon.scaleX = bloodbondIcon.scaleY = 2;
                    bloodbondIcon.x = _bloodbondIconAnchor.x - bloodbondIcon.width/2;
                    bloodbondIcon.y = _bloodbondIconAnchor.y;
                    _lineageView.displaySprite.addChild( bloodbondIcon );

                    //Actually show your blondbond, if you have one
                    showBloodBonded();

                    //Show the top info text
                    createInfoText();

                    //Add the extra help bits for sires and minion recruiting, if relevant
                    //First, if there's no Lineage yet, jsut add the links
                    if( ClientContext.model.lineage == null ) {
                        _getSiresButton.mouseEnabled = true;
                        _getSiresButton.visible = true;
                        _getMinionsButton.mouseEnabled = true;
                        _getMinionsButton.visible = true;
                    }
                    else {
                        //Check if we need to show the sires link
                        if( ClientContext.model.lineage.getSireId( ClientContext.ourPlayerId ) == 0) {
                            _getSiresButton.mouseEnabled = true;
                            _getSiresButton.visible = true;
                        }
                        else {
                            _getSiresButton.mouseEnabled = false;
                            _getSiresButton.visible = false;
                        }
                        //Check if we need to show the minions link
                        if( ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId) == 0) {
                            _getMinionsButton.mouseEnabled = true;
                            _getMinionsButton.visible = true;
                        }
                        else {
                            _getMinionsButton.mouseEnabled = false;
                            _getMinionsButton.visible = false;
                        }
                    }

                default:
                    break;
            }
        }

        protected function backButtonPushed(...ignored) :void
        {
            if( _frameHistory.length > 0) {
                var previousFrame :String = _frameHistory.pop();
                gotoFrame( previousFrame, false);
            }
        }


        override public function get objectName () :String
        {
            return NAME;
        }


        /**
        * Using the embedded font disallows dynamically changing the text.
        */
        protected function redoBloodBondText( bloodbondName :String ) :void
        {
            if( bloodbondName == null || bloodbondName == "") {
                bloodbondName = "No bloodbond yet.";
            }
            if( _bondText != null && _bondText.parent != null
                && _bondText.parent.contains(_bondText)) {

                _bondText.parent.removeChild( _bondText );
            }

            _bondText = TextFieldUtil.createField(bloodbondName);
            _bondText.selectable = false;
            _bondText.tabEnabled = false;
            _bondText.textColor = 0xffffff;
            _bondText.embedFonts = true;
            var format :TextFormat = getJuiceFormat();
            format.align = TextFormatAlign.LEFT;
            _bondText.setTextFormat( format );

            _bondText.antiAliasType = AntiAliasType.ADVANCED;
            _bondText.width = 200;
            _bondText.height = 60;
            _bondText.x = _bondTextAnchor.x;
            _bondText.y = _bondTextAnchor.y - 3;
            _bondTextAnchor.parent.addChild( _bondText );


            addGlowFilter( _bondText );
            var bondTextClick :Function = function(...ignored) :void {
                unregisterListener(_bondText, MouseEvent.CLICK, bondTextClick);
                _bondText.parent.removeChild( _bondText );
                gotoFrame("bloodbond");
            }
            registerListener( _bondText, MouseEvent.CLICK, bondTextClick );

        }

        protected function getJuiceFormat () :TextFormat
        {
            var format :TextFormat = new TextFormat();
            format.font = "JuiceEmbedded";
            format.size = 26;
            format.color = 0xffffff;
            format.align = TextFormatAlign.CENTER;
            format.bold = true;
            return format;
        }

        protected function createInfoText() :void
        {
            if( _infoText != null && _infoText.parent != null) {
                _infoText.parent.removeChild( _infoText );
            }

            var xpNeededForCurrentLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level);
            var xpNeededForNextLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level + 1);
            var xpGap :Number = xpNeededForNextLevel - xpNeededForCurrentLevel;
            var ourXPForOurLevel :Number = ClientContext.model.xp - xpNeededForCurrentLevel;
            ourXPForOurLevel = Math.max(ourXPForOurLevel, 0);
            _infoText = new TextField();
            var level :int = ClientContext.model.level;


            var inviteText :String = level >= VConstants.MAXIMUM_VAMPIRE_LEVEL ? "Max Level" :
                "Your Recruits/Recruits needed for next level: " + ClientContext.model.invites + "/" +
                    Logic.invitesNeededForLevel( level + 1 );

            _infoText.text =
                "Blood: " + Util.formatNumberForFeedback(ClientContext.model.blood) + "/"
                + ClientContext.model.maxblood
                + "       Level: " + level
                + "    Experience: " + Util.formatNumberForFeedback(ourXPForOurLevel) + " / " + xpGap + "\n"
                + inviteText
                + ""
                ;
//                "/" + ClientContext.model.
            _infoText.selectable = false;
            _infoText.tabEnabled = false;
            _infoText.multiline = true;
            _infoText.textColor = 0xffffff;
            _infoText.embedFonts = true;
            var format :TextFormat = getJuiceFormat();
            format.align = TextFormatAlign.CENTER;
            format.size = 20;
            _infoText.setTextFormat( format );

            _infoText.antiAliasType = AntiAliasType.ADVANCED;
            _infoText.width = 450;
            _infoText.height = 60;
            _infoText.x = _infoTextAnchor.x;
            _infoText.y = _infoTextAnchor.y - 3;
            _infoTextAnchor.parent.addChild( _infoText );
        }


        protected var _hudHelp :MovieClip;
        protected var _frameHistory :Array = new Array();
        protected var _bloodTypeOverlay :Sprite = new Sprite();
        protected var _bondText :TextField;

        protected var _bondTextAnchor :TextField;
        protected var _bloodbondIconAnchor :DisplayObject;
        protected var _infoTextAnchor :TextField;
        protected var _infoText :TextField;

        protected var _lineageView :LineageView;
        protected var _getSiresButton :SimpleButton;
        protected var _getMinionsButton :SimpleButton;

        public static const NAME :String = "HelpPopup";
        protected static const log :Log = Log.getLog( HelpPopup );

        protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);


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