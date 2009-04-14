package vampire.client
{
    import com.threerings.flash.DisplayUtil;
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.util.Log;
    import com.whirled.contrib.avrg.RoomDragger;
    import com.whirled.contrib.simplegame.objects.DraggableObject;
    import com.whirled.contrib.simplegame.objects.Dragger;
    import com.whirled.net.PropertyChangedEvent;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import vampire.Util;
    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.data.VConstants;
    import vampire.feeding.Constants;
    import vampire.feeding.PlayerFeedingData;

    public class HelpPopup extends DraggableObject
    {
        public function HelpPopup (startframe :String = "intro")
        {
            _hudHelp = ClientContext.instantiateMovieClip("HUD", "popup_help", false);
            _displaySprite.addChild(_hudHelp);

            _lineageView = new LineageView();

            //Go to the first frame where all the buttons are.  Even though not all buttons are
            //visible there, obviously, however they need to be instantiated on the first frame
            //otherwise they cannot be 'found'.
            _hudHelp.gotoAndStop("intro");

            //Wire up the links on the left panel
            registerListener(SimpleButton(findSafely("to_default")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    ClientContext.tutorial.clickedLineage();
                    gotoFrame("default");
                });
            registerListener(SimpleButton(findSafely("to_bloodtype")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    ClientContext.tutorial.clickedStrains();
                    gotoFrame("bloodtype");
                });
            registerListener(SimpleButton(findSafely("menu_tointro")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("intro");
                });
            registerListener(SimpleButton(findSafely("menu_tofeedinggame")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("feedinggame");
                });
            registerListener(SimpleButton(findSafely("menu_toinstructions")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("instructions");
                });
            registerListener(SimpleButton(findSafely("menu_toblood")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("blood");
                });
            registerListener(SimpleButton(findSafely("menu_tovamps")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("vamps");
                });
            registerListener(SimpleButton(findSafely("menu_tolineage")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("lineage");
                });
            registerListener(SimpleButton(findSafely("menu_tobloodbond")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("bloodbond");
                });




            //Wire up the buttons
            registerListener(SimpleButton(findSafely("button_toinstructions")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("instructions");
                });

            registerListener(SimpleButton(findSafely("button_tofeedinggame")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("feedinggame");
                });
            registerListener(SimpleButton(findSafely("button_tolineage")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("lineage");
                });
            registerListener(SimpleButton(findSafely("button_tovamps")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("vamps");
                });
            registerListener(SimpleButton(findSafely("button_totutorial")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    destroySelf();
                    if (ClientContext.model.xp == 0) {
                        ClientContext.tutorial.activateTutorial();
//                        showTututorialOnClose = false;
                    }
//                    showTututorialOnClose = false;
//                    ClientContext.tutorial.activateTutorial();
                });
            registerListener(SimpleButton(findSafely("button_tobloodbond")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("bloodbond");
                });
            registerListener(SimpleButton(findSafely("button_tobloodtype")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    gotoFrame("bloodtype");
                });
            registerListener(SimpleButton(findSafely("help_close")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    destroySelf();
                    //If you don't have any xp, start the tutorial regardless.
//                    if (ClientContext.model.xp == 0 && showTututorialOnClose) {
//                        ClientContext.tutorial.activateTutorial();
//                        showTututorialOnClose = false;
//                    }
                });
//            registerListener(SimpleButton(findSafely("button_recruit")), MouseEvent.CLICK,
//                function (e :MouseEvent) :void {
//                    ClientContext.tutorial.clickedRecruit();
//                    ClientContext.controller.handleRecruit();
//                });

            //RECRUIT RIP
//            var recruitButton :DisplayObject = findSafely("button_torecruiting");
//            ClientUtil.detach(recruitButton);
            registerListener(SimpleButton(findSafely("button_torecruiting")), MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    ClientContext.tutorial.clickedRecruit();
                    ClientContext.controller.handleRecruit();
                });

            registerListener(SimpleButton(findSafely("help_back")), MouseEvent.CLICK,
                backButtonPushed);

            _bondTextAnchor = findSafely("text_bloodbond") as TextField;
            _bloodbondIconAnchor = findSafely("bond_icon");

            //Listen for the bloodbond changing
            registerListener(ClientContext.ctrl.player.props,
                PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
            _infoTextAnchor = findSafely("text_blood") as TextField;

            _getSiresButton = findSafely("link_tovamps") as SimpleButton;
            _getDescendentsButton = findSafely("link_tolineage") as SimpleButton;

            registerListener(_getSiresButton, MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    ClientContext.tutorial.clickedBlood();
                    gotoFrame("vamps");
                });
            registerListener(_getDescendentsButton, MouseEvent.CLICK,
                function (e :MouseEvent) :void {
                    ClientContext.tutorial.clickedBuildLineage();
                    gotoFrame("lineage");
                });

            gotoFrame(startframe);


        }

//        public function get lineageView () :LineageView
//        {
//            return _lineageView;
//        }

        override public function get displayObject () :DisplayObject
        {
            return _displaySprite;
        }


        protected function propertyChanged (e :PropertyChangedEvent) :void
        {
            if (e.name == Codes.PLAYER_PROP_BLOODBOND
                || e.name == Codes.PLAYER_PROP_BLOODBOND_NAME) {

                showBloodBonded();
            }
        }

        protected function showBloodBonded () :void
        {
            if (VConstants.LOCAL_DEBUG_MODE) {
                redoBloodBondText("Test bb name");
            }
            else {
                if (ClientContext.model.bloodbond <= 0) {
                    return;
                }
                redoBloodBondText(ClientContext.model.bloodbondName);
            }
        }


        protected function addGlowFilter (obj : InteractiveObject) :void
        {
            registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
                obj.filters = [_glowFilter];
            });
            registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
                obj.filters = [];
            })
        }


        protected function updateBloodStrainPage () :void
        {
            var feedingData :PlayerFeedingData = ClientContext.model.playerFeedingData;
            if (feedingData == null) {
                log.error("updateBloodStrainPage, feedingData == null");
                return;
            }
            while(_bloodTypeOverlay.numChildren) { _bloodTypeOverlay.removeChildAt(0);}

            for(var i :int = 0; i < 12; i++) {
                var numberAsText :String = String(i + 1);
                if (numberAsText.length == 1) {
                    numberAsText = "0" + numberAsText;
                }
                var textFieldName :String = "indicator_" + numberAsText;

                var tf :MovieClip = _hudHelp[textFieldName] as MovieClip;
                if (tf == null) {
                    log.error(textFieldName + " is null");
                    continue;
                }
                tf.gotoAndStop(1);

                if (Logic.getPlayerBloodStrain(ClientContext.ourPlayerId) == i) {
                    tf.gotoAndStop(3);
                }

//                if (Logic.getPlayerPreferredBloodStrain(ClientContext.ourPlayerId) == i) {
//                    tf.gotoAndStop(2);
//                }

                TextField(tf["tally"]).text = "";
                var tally :TextField = TextField(tf["tally"]);

                var replacementTextField :TextField = new TextField();
                replacementTextField.text = feedingData.getStrainCount(i) + " / " + Constants.MAX_COLLECTIONS_PER_STRAIN;
                replacementTextField.x = tally.x;
                replacementTextField.y = tally.y;
                replacementTextField.textColor = 0xffffff;

                var format :TextFormat = new TextFormat();
                format.size = 16;
                format.color = 0xffffff;
                format.align = TextFormatAlign.LEFT;
                format.bold = true;
                replacementTextField.setTextFormat(format);
                tf.addChild(replacementTextField);


                var starsignTextField :TextField = new TextField();
                starsignTextField.text = VConstants.BLOOD_STRAIN_NAMES[i];
                starsignTextField.x = tally.x - 130;
                starsignTextField.y = tally.y;

                var starSignformat :TextFormat = new TextFormat();
                starSignformat.size = 16;
                starSignformat.color = 0xffffff;
                starSignformat.align = TextFormatAlign.RIGHT;
                starSignformat.bold = true;
                starsignTextField.setTextFormat(starSignformat);
                tf.addChild(starsignTextField);
            }
        }

        override public function destroySelf ():void
        {
            super.destroySelf();
            if (_lineageView != null && _lineageView.isLiveObject) {
                _lineageView.destroySelf();

            }
            ClientContext.tutorial.clickedVWButtonCloseHelp();
        }

        override protected function addedToDB ():void
        {
            super.addedToDB();
            db.addObject(_lineageView);
            if (_hudHelp.currentFrame == 2) {
                _hudHelp.addChild(_lineageView.displayObject);
            }
        }

        public function findSafely (name :String) :DisplayObject
        {
            var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
            if (o == null) {
                throw new Error("Cannot find object: " + name);
            }
            return o;
        }

        protected function removeExtraHelpPanels () :void
        {
            if (_hudHelp.contains(_bloodTypeOverlay)) {
                _hudHelp.removeChild(_bloodTypeOverlay);
            }

            if (_hudHelp.contains(_lineageView.displayObject)) {
                _hudHelp.removeChild(_lineageView.displayObject);
            }

            if (_bondText != null && _bondText.parent != null
                && _bondText.parent.contains(_bondText)) {

                _bondText.parent.removeChild(_bondText);
            }

            if (_infoText != null && _infoText.parent != null) {
                _infoText.parent.removeChild(_infoText);
            }


        }

        public function gotoFrame (frame :String, addFrameToHistory :Boolean = true) :void
        {
            if (frame == null) {
                frame = "default";
            }

            if (addFrameToHistory && (_frameHistory.length == 0 || _frameHistory[ _frameHistory.length - 1] != _hudHelp.currentLabel)) {
                _frameHistory.push(_hudHelp.currentLabel);
            }
            _hudHelp.gotoAndStop(frame);

            removeExtraHelpPanels();

            switch(frame) {
                case "bloodtype":
                    updateBloodStrainPage();
                    _hudHelp.addChild(_bloodTypeOverlay);
                    break;
                case "default":

                    //Center the lineage view on the anchor created for it.
                    var lineage_center :MovieClip = findSafely("lineage_center") as MovieClip;
                    lineage_center.parent.addChild(_lineageView.displayObject);
                    _lineageView.x = lineage_center.x;
                    _lineageView.y = lineage_center.y;// - 20;
                    centerLineageOnPlayer(ClientContext.ourPlayerId);

                    //Add the clickable, glowable bloodbond icon
                    var bloodbondIcon :MovieClip = ClientContext.instantiateMovieClip("HUD", "bond_icon", false);

                    registerListener(bloodbondIcon, MouseEvent.CLICK,
                        function (e :MouseEvent) :void {
                            if (bloodbondIcon.parent != null) {
                                bloodbondIcon.parent.removeChild(bloodbondIcon);
                            }
                            gotoFrame("bloodbond");
                        });

                    addGlowFilter(bloodbondIcon);
                    bloodbondIcon.scaleX = bloodbondIcon.scaleY = 2;
                    bloodbondIcon.x = _bloodbondIconAnchor.x - bloodbondIcon.width/2;
                    bloodbondIcon.y = _bloodbondIconAnchor.y;
                    _lineageView.displaySprite.addChild(bloodbondIcon);

                    //Actually show your blondbond, if you have one
                    showBloodBonded();

                    //Show the top info text
                    createInfoText();


                default:
                    break;
            }
        }

        public function centerLineageOnPlayer (playerId :int) :void
        {
            if (ClientContext.ourPlayerId == playerId &&
                ClientContext.model.lineage.getSireId(ClientContext.ourPlayerId) == 0
                && ClientContext.model.lineage.getProgenyCount(ClientContext.ourPlayerId) == 0) {

                _getSiresButton.mouseEnabled = true;
                _getSiresButton.visible = true;
                _getDescendentsButton.mouseEnabled = true;
                _getDescendentsButton.visible = true;
            }
            else {
                _getSiresButton.mouseEnabled = false;
                _getSiresButton.visible = false;
                _getDescendentsButton.mouseEnabled = false;
                _getDescendentsButton.visible = false;
            }
            _lineageView.updateLineage(playerId);
        }

        protected function backButtonPushed (...ignored) :void
        {
            if (_frameHistory.length > 0) {
                ClientContext.tutorial.clickedBack();
                var previousFrame :String = _frameHistory.pop();
                gotoFrame(previousFrame, false);
            }
        }


        override public function get objectName () :String
        {
            return NAME;
        }

        override protected function get draggableObject () :InteractiveObject
        {
            return _displaySprite;//_movie["draggable"];
        }

        override protected function createDragger () :Dragger
        {
            return new RoomDragger(ClientContext.ctrl, this.draggableObject, this.displayObject);
        }

        /**
        * Using the embedded font disallows dynamically changing the text.
        */
        protected function redoBloodBondText (bloodbondName :String) :void
        {
            if (bloodbondName == null || bloodbondName == "") {
                bloodbondName = "No bloodbond yet.";
            }
            if (_bondText != null && _bondText.parent != null
                && _bondText.parent.contains(_bondText)) {

                _bondText.parent.removeChild(_bondText);
            }

            _bondText = TextFieldUtil.createField(bloodbondName);
            _bondText.selectable = false;
            _bondText.tabEnabled = false;
            _bondText.textColor = 0xffffff;
            _bondText.embedFonts = true;
            var format :TextFormat = getJuiceFormat();
            format.align = TextFormatAlign.LEFT;
            _bondText.setTextFormat(format);

            _bondText.antiAliasType = AntiAliasType.ADVANCED;
            _bondText.width = _bondText.textWidth + 10;
            _bondText.height = 30;
            _bondText.x = _bondTextAnchor.x;
            _bondText.y = _bondTextAnchor.y - 3;
            _bondTextAnchor.parent.addChild(_bondText);


            addGlowFilter(_bondText);
            var bondTextClick :Function = function(...ignored) :void {
                unregisterListener(_bondText, MouseEvent.CLICK, bondTextClick);
                _bondText.parent.removeChild(_bondText);
                gotoFrame("bloodbond");
            }
            registerListener(_bondText, MouseEvent.CLICK, bondTextClick);

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

        protected function createInfoText () :void
        {
            if (_infoText != null && _infoText.parent != null) {
                _infoText.parent.removeChild(_infoText);
            }

            var xpNeededForCurrentLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level);
            var xpNeededForNextLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level + 1);
            var xpGap :Number = xpNeededForNextLevel - xpNeededForCurrentLevel;
            var ourXPForOurLevel :Number = ClientContext.model.xp - xpNeededForCurrentLevel;
            ourXPForOurLevel = Math.max(ourXPForOurLevel, 0);
            _infoText = new TextField();
            var level :int = ClientContext.model.level;


            var inviteText :String = level >= VConstants.MAXIMUM_VAMPIRE_LEVEL ? "Max Level" :
                "Your Invites/Invites needed for next level: " + ClientContext.model.invites + "/" +
                    Logic.invitesNeededForLevel(level + 1);

            _infoText.text =
                "       Level: " + level
                + "    Experience: " + Util.formatNumberForFeedback(ourXPForOurLevel) + " / " + xpGap + "\n"
                + inviteText;
            _infoText.selectable = false;
            _infoText.tabEnabled = false;
            _infoText.multiline = true;
            _infoText.textColor = 0xffffff;
            _infoText.embedFonts = true;
            var format :TextFormat = getJuiceFormat();
            format.align = TextFormatAlign.CENTER;
            format.size = 20;
            _infoText.setTextFormat(format);

            _infoText.antiAliasType = AntiAliasType.ADVANCED;
            _infoText.width = 450;
            _infoText.height = 60;
            _infoText.x = _infoTextAnchor.x;
            _infoText.y = _infoTextAnchor.y - 3;
            _infoTextAnchor.parent.addChild(_infoText);
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
        protected var _getDescendentsButton :SimpleButton;

        public static const NAME :String = "HelpPopup";
        protected static const log :Log = Log.getLog(HelpPopup);

        protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);
        protected var _displaySprite :Sprite = new Sprite();

//        public static var showTututorialOnClose :Boolean = true;



    }
}