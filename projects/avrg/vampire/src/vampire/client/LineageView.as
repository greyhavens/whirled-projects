package vampire.client
{

    import com.threerings.flash.TextFieldUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.Command;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.objects.SceneObject;

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

    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.MinionHierarchy;
    import vampire.data.VConstants;

    public class LineageView extends SceneObject
    {

        public function LineageView()
        {
            _hierarchyTree = new Sprite();

            _displaySprite.addChild( _hierarchyTree );



            _selectedPlayerIdCenter = ClientContext.ourPlayerId;
            _hierarchy = ClientContext.model.lineage;
            if( _hierarchy != null ) {
                updateHierarchy(_selectedPlayerIdCenter);
            }
            else if( VConstants.LOCAL_DEBUG_MODE){
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


        }

        override public function set x( value :Number ) :void
        {
            trace("Setting lineage x=" + value);
            super.x = value;
        }

        override public function get objectName () :String
        {
            return NAME;
        }

        override public function get displayObject () :DisplayObject
        {
            return _displaySprite;
        }

        public function get displaySprite () :Sprite
        {
            return _displaySprite;
        }


        protected function updateHierarchyEvent( e :HierarchyUpdatedEvent) :void
        {
            log.debug(VConstants.DEBUG_MINION + " updateHierarchyEvent", "e", e);
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
                _hierarchy.setPlayerSire( playerIdToCenter, 0);
            }

            //If we change the player to center, revert to page 0;
            if( _selectedPlayerIdCenter != playerIdToCenter) {
                _hierarchyPage = 0;
            }
            _selectedPlayerIdCenter = playerIdToCenter;

            var playerX :int = 0;//150;
            var playerY :int = 0;//150;

            _hierarchyTree.graphics.clear();
            while( _hierarchyTree.numChildren > 0 ) { _hierarchyTree.removeChildAt(0); }


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

            if( playerId < 1) {
                return;
            }

            var minionIds :Array = _hierarchy.isHavingMinions(playerId) ? _hierarchy.getMinionIds( playerId ).toArray() : [];

            var minionCount :int = minionIds.length;

            var startMinionViewIndex :int = 0;

            if( minionCount > MAX_MINIONS_SHOWN) {
                startMinionViewIndex = _hierarchyPage * MAX_MINIONS_SHOWN;

                //Delete minions after the last entry in the 'page'
                minionIds.splice( startMinionViewIndex + MAX_MINIONS_SHOWN );


                //Delete minions before the first entry in the 'page'
                minionIds = minionIds.slice( startMinionViewIndex  );

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
                addGlowFilter( button_page_left );
                //The text
                var textPageLeft :TextField = getTextFieldCenteredOn( "More", locations[0].x - 10, startY + yInc - 40, true, left);
                textPageLeft.mouseEnabled = true;
                s.addChild( textPageLeft );
                Command.bind( textPageLeft, MouseEvent.CLICK, showPreviousPage);
                addGlowFilter( textPageLeft );
            }
            //Show the more sub minions button
            if( startMinionViewIndex + MAX_MINIONS_SHOWN < minionCount ) {
                var button_page_right :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
                button_page_right.x = locations[locations.length - 1].x + 10;
                button_page_right.y = startY + yInc;
                s.addChild( button_page_right );
                Command.bind( button_page_right, MouseEvent.CLICK, showNextPage);
                addGlowFilter( button_page_right );
                //The text
                var textPageRight :TextField = getTextFieldCenteredOn( "More", locations[locations.length - 1].x + 10, startY + yInc - 40, true, left);
                textPageRight.mouseEnabled = true;
                s.addChild( textPageRight );
                Command.bind( textPageRight, MouseEvent.CLICK, showNextPage);
                addGlowFilter( textPageRight );
            }



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

                    drawPlayerWithSireLink( s, minionIds[i], locations[i].x, locations[i].y, locations[i].x, horizontalBarY, linkOnly, true, left);

                    var subminionCount :int = _hierarchy.getAllMinionsAndSubminions(minionIds[i]).size();
                    if( subminionCount) {
                        if(linkOnly) {
                            drawLineFrom( s, locations[i].x, locations[i].y, locations[i].x, locations[i].y - yInc);
                        }
                        else {
                            var button_hiararchy :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
                            button_hiararchy.x = locations[i].x - button_hiararchy.width;
                            button_hiararchy.y = locations[i].y + 1.5*yInc;
                            s.addChild( button_hiararchy );
                            Command.bind( button_hiararchy, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
                            addGlowFilter( button_hiararchy );

                            var subminionTextField :TextField = getTextFieldCenteredOn( subminionCount + "", locations[i].x + 4, locations[i].y +1*yInc, true, left);
                            subminionTextField.mouseEnabled = true;
                            s.addChild( subminionTextField );
                            Command.bind( subminionTextField, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
                            addGlowFilter( subminionTextField );
                        }
                    }
                }
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

        protected function computeMinionLocations( myX :int, myY:int, minions :int) :Array
        {
            var maxWidth :int = LINEAGE_PANEL_WIDTH - 160;
            var locations :Array = new Array();
            if( minions == 0) {
                return locations;
            }
            else if( minions == 1) {
                locations.push( new Vector2( myX ,  myY + yInc));
                return locations;
            }

            var xStart :int = myX - maxWidth / 2;
            var xInc :int = maxWidth / (minions - 1);
            for( var i :int = 0; i < minions; i++) {
                locations.push( new Vector2( xStart + i * (maxWidth / (minions - 1)) ,  myY + 2*yInc));
            }
            return locations;
        }

        protected function drawPlayerWithSireLink( s :Sprite, playerId :int, playerX :int, playerY :int, sireX :int, sireY :int, linkOnly :Boolean, below :Boolean, left :Boolean ) :void
        {
            if( linkOnly && _hierarchy.getSireProgressionCount(playerId) > 0 ) {
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

            addGlowFilter( tf );

            Command.bind( tf, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [playerId, this]);
            s.addChild( tf );
            var droplet :MovieClip = ClientContext.instantiateMovieClip("HUD", "droplet", true);
            addGlowFilter( droplet );

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
            var tf :TextField = TextFieldUtil.createField( text );
            tf.selectable = false;
            tf.tabEnabled = false;
            tf.textColor = 0xffffff;
            tf.embedFonts = true;

            tf.setTextFormat( getDefaultFormat() );

            tf.antiAliasType = AntiAliasType.ADVANCED;

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
            return format;
        }

        protected function drawLineFrom( s :Sprite, x1 :int, y1 :int, x2 :int, y2 :int) :void
        {
            s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
            s.graphics.moveTo(x1, y1);
            s.graphics.lineTo( x2, y2 );
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


        protected var _displaySprite :Sprite = new Sprite();

        protected var _hierarchyTree :Sprite;

        public var _hierarchy :MinionHierarchy;

        protected static const yInc :int = 30;
        public var _selectedPlayerIdCenter :int;

        protected var _hierarchyPage :int = 0;//If there are too many minions, scroll by 'pages'


        protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);


        protected static const BLOOD_LINEAGE_LINK_COLOR :int = 0xcc0000;
        protected static const BLOOD_LINEAGE_LINK_THICKNESS :int = 3;

        protected static const MAX_MINIONS_SHOWN :int = 5;
        protected static const MAX_NAME_CHARS :int = 10;

        protected static const LINEAGE_PANEL_WIDTH :int = 490;
        protected static const LINEAGE_PANEL_HEIGHT :int = 350;

        public static const NAME :String = "HierarchySceneObject";
        protected static const log :Log = Log.getLog( LineageView );

    }
}