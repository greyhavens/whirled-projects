package vampire.client.actions.hierarchy
{
    
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.Command;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.net.ElementChangedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    import vampire.client.ClientContext;
    import vampire.client.DraggableSprite;
    import vampire.client.VampireController;
    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.Codes;
    import vampire.data.Constants;
    import vampire.data.MinionHierarchy;
    import vampire.data.SharedPlayerStateClient;
    
    public class HierarchyView extends SceneObject
    {
        protected static const log :Log = Log.getLog( HierarchyView );
        
        
        
        
        protected var _sceneObjectSprite :DraggableSprite;
        protected var _hierarchyPanel :Sprite;
        protected var _hierarchyTree :Sprite;
        protected var _text :TextField;
        
        public var _hierarchy :MinionHierarchy;
        
        protected static const yInc :int = 30;
//        protected static const xInc :int = 40;
//        protected static const maxWidth :int = 450;
        public var _selectedPlayerIdCenter :int;
        
        
        public function HierarchyView(hudMC :MovieClip = null) 
        {
            
            
//            var embeddedFonts:Array = Font.enumerateFonts(true);
//            for each( var font :Font in embeddedFonts) {
//                if( font.fontName == "JuiceEmbedded") {
//                    trace( font.fontName + " is embedded" );
//                }
//            }
            _sceneObjectSprite = new DraggableSprite(ClientContext.gameCtrl, "HierarchyView");
            _sceneObjectSprite.init( new Rectangle(0, 0, 100, 100), 10, 10, 10, 10);
            _sceneObjectSprite.x = 20;
            _sceneObjectSprite.y = 20;
            _hierarchyPanel = new Sprite();
//            _hierarchyPanel.x = 200;
//            _hierarchyPanel.y = 200;
            _sceneObjectSprite.addChild( _hierarchyPanel );
            
            _hierarchyTree = new Sprite();
            
//            var scaleFactor :Number = 1;
//            _hierarchyPanel.scaleX = scaleFactor;
//            _hierarchyPanel.scaleY = scaleFactor;
            _popup = ClientContext.instantiateMovieClip("HUD", "popup_hierarchy", true);
            _popup.width = 550;
            _popup.height = 400;
            
            
//            var bgshape :Shape = popup.getChildAt(0) as Shape;
            _hierarchyPanel.addChild( _popup );
            
            var bg :MovieClip = ClientContext.instantiateMovieClip("HUD", "hierarchyBG", true);
            _popup.addChild( bg );
//            bg.width = 550;
//            bg.height = 400;
            
//            bg.x = popup.x + popup.width/2;
//            bg.y = popup.y + popup.height/2;
//            bg.scaleX = bg.scaleY = 1.5;
            
            _bondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", true);
            _bondIcon.scaleX = _bondIcon.scaleY = 2;
            _bondIcon.x = 25;
            _bondIcon.y = 60;
            _hierarchyPanel.addChild( _bondIcon );
            redoBloodBondText( "Blood Bond mate" ); 
            
            
            var lineageText :TextField = TextFieldUtil.createField("Lineage");
            lineageText.selectable = false;
            lineageText.tabEnabled = false;
            lineageText.embedFonts = true;
            var lineageformat :TextFormat = new TextFormat();
            lineageformat.font = "JuiceEmbedded";
            lineageformat.size = 30;
            lineageformat.color = 0xff0000;
            lineageformat.align = TextFormatAlign.CENTER;
            lineageformat.bold = true;
            lineageText.setTextFormat( lineageformat );
            lineageText.textColor = 0xff0000;
            lineageText.width = 200;
            lineageText.height = 60;
            lineageText.x = 160;//_hierarchyPanel.width/2;
            lineageText.y = 0 ;
            _hierarchyPanel.addChild( lineageText );
            
            
            var instructionText :TextField = TextFieldUtil.createField("Click a player (or drop) to re-center the tree.");
            instructionText.selectable = false;
            instructionText.tabEnabled = false;
//            instructionText.embedFonts = true;
            var instructionTextformat :TextFormat = new TextFormat();
//            instructionTextformat.font = "Arial";
            instructionTextformat.size = 14;
            instructionTextformat.color = 0xffffff;
            instructionTextformat.align = TextFormatAlign.CENTER;
            instructionTextformat.bold = true;
            
            instructionText.setTextFormat( instructionTextformat );
            instructionText.width = 400;
            instructionText.height = 60;
            instructionText.x = -50;//_hierarchyPanel.width/2;
            instructionText.y = 350 ;
            _hierarchyPanel.addChild( instructionText );
            
            
            
            
            _hierarchyPanel.addChild( _hierarchyTree );
            _hierarchyTree.x = 120;
            _hierarchyTree.y = 30;
            
            //The close button
            var button_close :SimpleButton = ClientContext.instantiateButton("HUD", "button_close");
//            var button_close :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy");
            button_close.scaleX = button_close.scaleY = 2.0; 
            _hierarchyPanel.addChild( button_close );
            button_close.x = _popup.width - button_close.width - 10;
            button_close.y = 9;
            _events.registerListener( button_close, MouseEvent.CLICK, function(...ignored) :void {
                destroySelf();    
            });
            
            
            _selectedPlayerIdCenter = ClientContext.ourPlayerId;
            _hierarchy = ClientContext.model.hierarchy;
            if( _hierarchy != null ) {
                updateHierarchy(_selectedPlayerIdCenter);
            }
            else if( Constants.LOCAL_DEBUG_MODE){
                trace("SHowing test hierarchy");
                _hierarchy = new MinionHierarchy();
                _hierarchy.setPlayerSire(1, 2);
                _hierarchy.setPlayerSire(3, 1);
                _hierarchy.setPlayerSire(4, 1);
                _hierarchy.setPlayerSire(5, 1);
                _hierarchy.setPlayerSire(6, 5);
                _hierarchy.setPlayerSire(7, 6);
                _hierarchy.setPlayerSire(8, 6);
                _hierarchy.setPlayerSire(9, 1);
                _hierarchy.setPlayerSire(10, 1);
                _hierarchy.setPlayerSire(11, 1);
                _hierarchy.setPlayerSire(12, 1);
                _hierarchy.setPlayerSire(13, 1);
                _hierarchy.setPlayerSire(14, 1);
                updateHierarchy(3);
            }
            
            _events.registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED, updateHierarchyEvent);
            
//            var makeSireButton :SimpleTextButton = new SimpleTextButton( "Make Sire" );
//            makeSireButton.x = 10;
//            makeSireButton.y = 50;
//            
//            makeSireButton.addEventListener( MouseEvent.CLICK, ClientContext.controller.makeSire);
//            _sceneObjectSprite.addChild( makeSireButton );
//            
//            var makeMinionButton :SimpleTextButton = new SimpleTextButton( "Make Minion" );
//            makeMinionButton.x = 10;
//            makeMinionButton.y = 80;
//            makeMinionButton.addEventListener( MouseEvent.CLICK, ClientContext.controller.makeMinion);
//            _sceneObjectSprite.addChild( makeMinionButton );
//            
//            
//            
//            
//            var closeButton :SimpleTextButton = new SimpleTextButton( "Close Hierarchy View" );
//            closeButton.x = _sceneObjectSprite.width - 50;
//            closeButton.y = 0;
//            _events.registerListener( closeButton, MouseEvent.CLICK, function(...ignored) :void {
//                destroySelf();    
//            });
//            _sceneObjectSprite.addChild( closeButton );
////            
//            
            
            
            
            //Add the blood bond stuff
//            _sceneObjectSprite.addChild( _bloodBondedView );
            _events.registerListener( ClientContext.gameCtrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
//            
//            var addTargetButton :SimpleTextButton = new SimpleTextButton("BloodBond Target");
//            Command.bind( addTargetButton, MouseEvent.CLICK, VampireController.ADD_BLOODBOND);
//            _sceneObjectSprite.addChild( addTargetBbutton );
//            addTargetButton.x = 220;
//            addTargetButton.y = 60;
//        
            showBloodBonded();
        
        }
        
        override public function get objectName () :String
        {
            return NAME;
        }
        
        override public function get displayObject () :DisplayObject
        {
            return _sceneObjectSprite;
        }
        
        /**
        * Using the embedded font disallows dynamically changing the text.
        */
        protected function redoBloodBondText( bloodbondName :String ) :void
        {
            if( _bondText != null && _hierarchyPanel.contains( _bondText)) {
                _hierarchyPanel.removeChild( _bondText );
            }
            
            _bondText = TextFieldUtil.createField(bloodbondName);
            _bondText.selectable = false;
            _bondText.tabEnabled = false;
            _bondText.textColor = 0xffffff;
            _bondText.embedFonts = true;
            _bondText.setTextFormat( getDefaultFormat() );
            _bondText.width = 200;
            _bondText.height = 60;
            _bondText.x = _bondIcon.x - 20;
            _bondText.y = _bondIcon.y - 20 ;
            _hierarchyPanel.addChild( _bondText );
        }
        
        protected function updateHierarchyEvent( e :HierarchyUpdatedEvent) :void
        {
            log.debug(Constants.DEBUG_MINION + " updateHierarchyEvent", "e", e);
            _hierarchy = e.hierarchy;
            if( _hierarchy == null) {
                log.error("updateHierarchyEvent(), but hierarchy is null :-(");
            }
            updateHierarchy( _selectedPlayerIdCenter );
        }
        
        public function updateHierarchy( playerIdToCenter :int) :void
        {
            if( _hierarchy == null) {
                _hierarchy = new MinionHierarchy();
                _hierarchy.setPlayerSire( playerIdToCenter, -1);
            }
//            trace("updateHierarchy(" + playerIdToCenter + ")" );
            
            
            //If we change the player to center, revert to page 0;
            if( _selectedPlayerIdCenter != playerIdToCenter) {
                _hierarchyPage = 0;
            }
            _selectedPlayerIdCenter = playerIdToCenter;
            
            var playerX :int = 150;
            var playerY :int = 150;
            
            _hierarchyTree.graphics.clear();
            while( _hierarchyTree.numChildren > 0 ) { _hierarchyTree.removeChildAt(0); }
            
//            if( Constants.LOCAL_DEBUG_MODE) {
//                playerIdToCenter = 1;
//            }
            
            //Draw links
            recursivelyDrawSires( _hierarchyTree, playerIdToCenter, playerX, playerY, true, 0);
            drawMinions( _hierarchyTree, playerIdToCenter, playerX, playerY, true, 0);
            
            //Draw labels
            recursivelyDrawSires( _hierarchyTree, playerIdToCenter, playerX, playerY, false, 0);
            drawMinions( _hierarchyTree, playerIdToCenter, playerX, playerY, false, 0);
        }
        
        protected function recursivelyDrawSires( s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int, left :Boolean = false) :void
        {
            depth++;
            if( playerId < 1) {
                return;
            }
            
            if( depth < 4) {
                drawPlayerWithSireLink( s, playerId, startX, startY, startX, startY - yInc, linkOnly, false, left);
                var sireId :int = _hierarchy.getSireId( playerId );
                recursivelyDrawSires( s, sireId, startX, startY - yInc, linkOnly, depth, !left);
            }
            else {
                if(linkOnly) {
//                    drawLineFrom( s, startX, startY, startX, startY - yInc);
                }
                else {
                    var grandSireCount :int = _hierarchy.getSireProgressionCount(playerId);
                    
                    s.addChild( getTextFieldCenteredOn( (1 + grandSireCount) + " Superior GrandSire" + (grandSireCount > 1 ? "s" : ""), startX, startY, false, !left) );
                }
            }
            
        }
        
        protected function drawMinions(  s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int, left :Boolean = false) :void
        {
            var i :int;
            
//            depth++;
            if( playerId < 1) {
                return;
            }
            
//            trace("recursivelyDrawMinions(" + playerId + "), depth="+depth);
            var minionIds :Array = _hierarchy.isHavingMinions(playerId) ? _hierarchy.getMinionIds( playerId ).toArray() : [];
            
            var minionCount :int = minionIds.length;
            
            var startMinionViewIndex :int = 0;
            
            if( minionCount > MAX_MINIONS_SHOWN) {
                startMinionViewIndex = _hierarchyPage * MAX_MINIONS_SHOWN;
                
                //Delete minions after the last entry in the 'page' 
                minionIds.splice( startMinionViewIndex + MAX_MINIONS_SHOWN );
//                locations.splice( startMinionViewIndex + MAX_MINIONS_SHOWN );
                
                
                //Delete minions before the first entry in the 'page' 
                minionIds = minionIds.slice( startMinionViewIndex  );
//                locations = locations.slice( startMinionViewIndex  );
                
            }
            var locations :Array = computeMinionLocations( startX, startY, minionIds.length );
            
            //Draw the page left/right buttons.
            if( startMinionViewIndex > 0 ) {
                //The button
                var button_page_left :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
                button_page_left.x = locations[0].x - 10;
                button_page_left.y = startY + yInc;
                s.addChild( button_page_left );
                Command.bind( button_page_left, MouseEvent.CLICK, showPreviousPage);
                //The text
                var textPageLeft :TextField = getTextFieldCenteredOn( "More", locations[0].x - 10, startY + yInc - 40, true, left);
                textPageLeft.mouseEnabled = true;
                s.addChild( textPageLeft );
                Command.bind( textPageLeft, MouseEvent.CLICK, showPreviousPage);
            }
            if( startMinionViewIndex + MAX_MINIONS_SHOWN < minionCount ) {
                var button_page_right :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
                button_page_right.x = locations[locations.length - 1].x + 10;
                button_page_right.y = startY + yInc;
                s.addChild( button_page_right );
                Command.bind( button_page_right, MouseEvent.CLICK, showNextPage);
                //The text
                var textPageRight :TextField = getTextFieldCenteredOn( "More", locations[locations.length - 1].x + 10, startY + yInc - 40, true, left);
                textPageRight.mouseEnabled = true;
                s.addChild( textPageRight );
                Command.bind( textPageRight, MouseEvent.CLICK, showNextPage);
            }
                            
                            
            
//            if( depth <= 1){// || minionIds.length <= 1) {
//                trace("  drawing all");

                var horizontalBarY :int = startY + yInc;
                
                if( minionIds.length > 1) {
                    
                    var minX :Number = Number.MAX_VALUE;
                    var maxX :Number = Number.MIN_VALUE;
                    for( i = 0; i < locations.length; i++) {
                        minX = Math.min( minX, locations[i].x);
                        maxX = Math.max( maxX, locations[i].x);
                    }
                    s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
                    s.graphics.moveTo( minX, horizontalBarY );
                    s.graphics.lineTo( maxX, horizontalBarY );
                    
                }
                
                if( minionIds.length >= 1) {
                    s.graphics.moveTo( startX, startY );
                    s.graphics.lineTo( startX, horizontalBarY );
                }
                

                for( i = 0; i < locations.length; i++) {
//                    drawPlayerWithSireLink( s, minionIds[i], locations[i].x, locations[i].y, startX, startY, linkOnly, true, left);
//                    recursivelyDrawMinions( s, minionIds[i], locations[i].x, locations[i].y, linkOnly, ++depth, !left);
                    
                    drawPlayerWithSireLink( s, minionIds[i], locations[i].x, locations[i].y, locations[i].x, horizontalBarY, linkOnly, true, left);
                    
                    var subminionCount :int = _hierarchy.getAllMinionsAndSubminions(minionIds[i]).size();
                    if( subminionCount) {
        //                trace("  drawing subset");
                        if(linkOnly) {
        //                    drawLineFrom( s, startX, startY, startX, startY + yInc);
                            drawLineFrom( s, locations[i].x, locations[i].y, locations[i].x, locations[i].y - yInc);
                        }
                        else {
                            var button_hiararchy :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
                            button_hiararchy.x = locations[i].x - button_hiararchy.width;
                            button_hiararchy.y = locations[i].y + 1.5*yInc;
//                            button_hiararchy.mouseEnabled = true;
                            s.addChild( button_hiararchy );
                            Command.bind( button_hiararchy, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
                            var subminionTextField :TextField = getTextFieldCenteredOn( subminionCount + "", locations[i].x + 4, locations[i].y +1*yInc, true, left);
                            subminionTextField.mouseEnabled = true;
                            s.addChild( subminionTextField );
                            Command.bind( subminionTextField, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
                        }
                    }
//                    drawMinions( s, minionIds[i], locations[i].x, locations[i].y, linkOnly, ++depth, !left);
                }
//            }
//            else {
//                var subminionCount :int = _hierarchy.getAllMinionsAndSubminions(playerId).size();
//                if( subminionCount) {
//    //                trace("  drawing subset");
//                    if(linkOnly) {
//    //                    drawLineFrom( s, startX, startY, startX, startY + yInc);
//                        drawLineFrom( s, startX, startY, startX, startY - yInc);
//                    }
//                    else {
//                        s.addChild( getTextFieldCenteredOn( _hierarchy.getAllMinionsAndSubminions(playerId).size() + " SubMinions", startX, startY + yInc, true, left) );
//                    }
//                }
//            }
        }
        
        protected function computeMinionLocations( myX :int, myY:int, minions :int) :Array
        {
            var maxWidth :int = _popup.width - 160;
            var locations :Array = new Array();
            if( minions == 0) {
                return locations;
            }
            else if( minions == 1) {
                locations.push( new Vector2( myX ,  myY + yInc));
                return locations;
            }
            
//            var totalWidth :int = xInc * minions;
            var xStart :int = myX - maxWidth / 2;
            var xInc :int = maxWidth / (minions - 1);
            for( var i :int = 0; i < minions; i++) {
//                locations.push( new Vector2( xStart + i * (maxWidth / (minions - 1)) ,  myY + yInc + i*20));
                locations.push( new Vector2( xStart + i * (maxWidth / (minions - 1)) ,  myY + 2*yInc));
            }
//            if( minions == 1) {
//                trace("  computeMinionLocations(), minions==1");
//                trace("    totalWidth=" + totalWidth);
//                trace("    locations=" + locations);
//                trace("    xStart=" + xStart);
//                
//            }
            return locations;
        }
        
        protected function drawPlayerWithSireLink( s :Sprite, playerId :int, playerX :int, playerY :int, sireX :int, sireY :int, linkOnly :Boolean, below :Boolean, left :Boolean ) :void
        {
//            s.graphics.lineStyle(1, 0x000000);
            if( linkOnly && _hierarchy.getSireProgressionCount(playerId) > 0 ) {
//                drawLineFrom( s, playerX, playerY, sireX, sireY);
                drawLineFrom( s, playerX, playerY, sireX, sireY);
            }
            else {
                drawPlayerNameCenteredOn( s, playerId, playerX, playerY, below, left );
            }
        }
        
        protected function drawPlayerNameCenteredOn( s :Sprite, playerId :int, centerX :int, centerY :int, below :Boolean, left :Boolean ) :void
        {
            var playerName :String = null;
            if( _hierarchy._playerId2Name.containsKey( playerId ) ) {
                playerName = _hierarchy._playerId2Name.get( playerId ) as String;
            }
            if( playerName == null || playerName.length == 0 ) {
                playerName = ClientContext.getPlayerName(playerId);
            }
            
            playerName = playerName.substring(0, MAX_NAME_CHARS);
            
            var tf :TextField = getTextFieldCenteredOn( playerName, centerX, centerY, below, left);
//            var tf :TextField = TextFieldUtil.createField(ClientContext.getPlayerName(playerId), centerX, centerY);
//                {selectable:false, 
//                tabEnabled:false, 
//                background:true, 
//                backgroundColor:0xffffff});
            Command.bind( tf, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [playerId, this]);
//            tf.width = tf.textWidth + 5// + 40;
//            tf.height = tf.textHeight + 4// + 10;
//            
//            tf.x = centerX - tf.width / 2;
//            tf.y = centerY - tf.height / 2;
            s.addChild( tf );
            var droplet :MovieClip = ClientContext.instantiateMovieClip("HUD", "droplet", true);
            droplet.mouseEnabled = true;
            Command.bind( droplet, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [playerId, this]);
            droplet.x = centerX;
            droplet.y = centerY;
            
            droplet.scaleX = below ? 2 : 2.5;
            droplet.scaleX *= left ? 1 : -1;
            droplet.scaleY = below ? 2 : 2.5;
            s.addChild( droplet );
        }
        
        protected function getTextFieldCenteredOn( text :String, centerX :int, centerY :int, below :Boolean, left :Boolean) :TextField
        {
            
            
            
            
//            var styleSheet : StyleSheet = new StyleSheet();
//            styleSheet.parseCSS(
//                "body {" +
//                "  color: #ffffff;" +
//                "}" +
//                ".title {" +
//                "  font-family: JuiceEmbedded;" +
//                "  font-size: 20;" +
//                "  text-decoration: underline;" +
//                "  text-align: left;" +
//                "  margin-left: 20;" +
//                "}" +
//                ".shim {" +
//                "  font-size: 8;" +
//                "}" +
//                ".summary {" +
//                "  font-family: JuiceEmbedded;" +
//                "  font-weight: bold;" +
//                "  font-size: 16;" +
//                "  text-align: left;" +
//                "}" +
//                ".message {" +
//                "  font-family: JuiceEmbedded;" +
//                "  font-size: 16;" +
//                "  text-align: left;" +
//                "}" +
//                ".details {" +
//                "  font-family: JuiceEmbedded;" +
//                "  font-size: 14;" +
//                "  text-align: left;" +
//                "}");

    
    
    
    
            var tf :TextField = TextFieldUtil.createField( text );
//            tf.styleSheet = styleSheet;
            tf.selectable = false;
            tf.tabEnabled = false;
            tf.textColor = 0xffffff;
            tf.embedFonts = true;
//            tf.html = true;
            tf.setTextFormat( getDefaultFormat() );
            
//            tf.antiAliasType = AntiAliasType.ADVANCED;
            
//                {selectable:false 
//                ,tabEnabled:false
//                ,textColor:0xffffff
//                ,embedFonts:true
//                ,background:true 
//                backgroundColor:0xffffff
//                });
            tf.width = tf.textWidth + 40;
            tf.height = tf.textHeight  + 10;
            
            
            tf.x = centerX - tf.width / 2;
            tf.y = centerY - tf.height / 2;
            
            if( below ) {
                tf.y += 20;
            }
            else {
                tf.x += (left ? -(10 + tf.width/2) : (10 + tf.width/2));
            }
            
            return tf;
        }
        protected function getDefaultFormat () :TextFormat
        {
            var format :TextFormat = new TextFormat();
            format.font = "JuiceEmbedded";
            format.size = 26;
            format.color = 0xffffff;
            format.align = TextFormatAlign.CENTER;
            format.bold = true;
            format.kerning = true;
            return format;
        }
        
        protected function drawLineFrom( s :Sprite, x1 :int, y1 :int, x2 :int, y2 :int) :void
        {
            s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
            s.graphics.moveTo(x1, y1);
            s.graphics.lineTo( x2, y2 );
            
//            GraphicsUtil.dashTo(s.graphics, x1, y1, x2, y2); 
        }
        
        protected function showBloodBonded() :void
        {
            if( ClientContext.model.bloodbonded <= 0 ) {
                return;
            }
            redoBloodBondText(ClientContext.model.bloodbondedName);
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
        
        protected function showNextPage() :void
        {
            _hierarchyPage++;
            updateHierarchy( _selectedPlayerIdCenter);
        }
        
        protected function showPreviousPage() :void
        {
            _hierarchyPage--;
            updateHierarchy( _selectedPlayerIdCenter);
        }
        


        protected var _bloodBondedView :Sprite = new Sprite();
        public static const NAME :String = "HierarchySceneObject";
        
        protected var _popup :MovieClip;
        
        protected var _bondIcon :MovieClip;
        protected var _bondText :TextField;
        
        protected var _hierarchyPage :int = 0;//If there are too many minions, scroll by 'pages'
        
        protected static const BLOOD_LINEAGE_LINK_COLOR :int = 0xcc0000;
        protected static const BLOOD_LINEAGE_LINK_THICKNESS :int = 3;
        
        protected static const MAX_MINIONS_SHOWN :int = 5;
        protected static const MAX_NAME_CHARS :int = 10;

    } 
}