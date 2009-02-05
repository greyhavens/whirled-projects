package vampire.client.actions.hierarchy
{
    
    import com.threerings.flash.GraphicsUtil;
    import com.threerings.flash.TextFieldUtil;
    import com.threerings.flash.Vector2;
    import com.threerings.util.Command;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    
    import vampire.client.ClientContext;
    import vampire.client.VampireController;
    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.Constants;
    import vampire.data.MinionHierarchy;
    
    
    public class HierarchyView extends SceneObject
    {
        protected static const log :Log = Log.getLog( HierarchyView );
        protected var _border :Sprite;
        protected var _vis :Sprite;
        protected var _text :TextField;
        
        public var _hierarchy :MinionHierarchy;
        
        protected static const yInc :int = 30;
//        protected static const xInc :int = 40;
        protected static const maxWidth :int = 200;
        public var _selectedPlayerIdCenter :int;
        
        public function HierarchyView() 
        {
            _border = new Sprite();
            _vis = new Sprite();
            _border.addChild( _vis );
            
//            _text = TextFieldUtil.createField( "No hierarchy yet", {y:120, width:300, height:400, selectable:false})
//            _vis.addChild( _text );
            
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
                updateHierarchy(3);
            }
            
            _events.registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED, updateHierarchyEvent);
        }
        
        override public function get displayObject () :DisplayObject
        {
            return _border;
        }
        
        protected function updateHierarchyEvent( e :HierarchyUpdatedEvent) :void
        {
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
            
            
            _selectedPlayerIdCenter = playerIdToCenter;
            
            var playerX :int = 150;
            var playerY :int = 150;
            
            _vis.graphics.clear();
            while( _vis.numChildren > 0 ) { _vis.removeChildAt(0); }
            
//            if( Constants.LOCAL_DEBUG_MODE) {
//                playerIdToCenter = 1;
//            }
            
            //Draw links
            recursivelyDrawSires( _vis, playerIdToCenter, playerX, playerY, true, 0);
            recursivelyDrawMinions( _vis, playerIdToCenter, playerX, playerY, true, 0);
            
            //Draw labels
            recursivelyDrawSires( _vis, playerIdToCenter, playerX, playerY, false, 0);
            recursivelyDrawMinions( _vis, playerIdToCenter, playerX, playerY, false, 0);
        }
        
        protected function recursivelyDrawSires( s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int) :void
        {
            depth++;
            if( playerId < 1) {
                return;
            }
            
            if( depth < 4) {
                drawPlayerWithSireLink( s, playerId, startX, startY, startX, startY - yInc, linkOnly);
                var sireId :int = _hierarchy.getSireId( playerId );
                recursivelyDrawSires( s, sireId, startX, startY - yInc, linkOnly, depth);
            }
            else {
                if(linkOnly) {
//                    drawLineFrom( s, startX, startY, startX, startY - yInc);
                }
                else {
                    s.addChild( getTextFieldCenteredOn( (1 + _hierarchy.getSireProgressionCount(playerId)) + " GrandSires", startX, startY) );
                }
            }
            
        }
        
        protected function recursivelyDrawMinions(  s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int) :void
        {
            depth++;
            if( playerId < 1) {
                return;
            }
//            trace("recursivelyDrawMinions(" + playerId + "), depth="+depth);
            var minionIds :Array = _hierarchy.isHavingMinions(playerId) ? _hierarchy.getMinionIds( playerId ).toArray() : [];
            var locations :Array = computeMinionLocations( startX, startY, minionIds.length );
            
            if( depth <= 1 || minionIds.length <= 1) {
//                trace("  drawing all");
                for( var i :int = 0; i < locations.length; i++) {
                    drawPlayerWithSireLink( s, minionIds[i], locations[i].x, locations[i].y, startX, startY, linkOnly);
                    recursivelyDrawMinions( s, minionIds[i], locations[i].x, locations[i].y, linkOnly, ++depth);
                }
            }
            else {
//                trace("  drawing subset");
                if(linkOnly) {
                    drawLineFrom( s, startX, startY, startX, startY + yInc);
                }
                else {
                    s.addChild( getTextFieldCenteredOn( _hierarchy.getAllMinionsAndSubminions(playerId).size() + " Minions", startX, startY + yInc) );
                }
            }
        }
        
        protected function computeMinionLocations( myX :int, myY:int, minions :int) :Array
        {
            
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
                locations.push( new Vector2( xStart + i * (maxWidth / (minions - 1)) ,  myY + yInc + i*20));
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
        
        protected function drawPlayerWithSireLink( s :Sprite, playerId :int, playerX :int, playerY :int, sireX :int, sireY :int, linkOnly :Boolean) :void
        {
            s.graphics.lineStyle(1, 0x000000);
            if( linkOnly && _hierarchy.getSireProgressionCount(playerId) > 0 ) {
                drawLineFrom( s, playerX, playerY, sireX, sireY);
            }
            else {
                drawPlayerNameCenteredOn( s, playerId, playerX, playerY );
            }
        }
        
        protected function drawPlayerNameCenteredOn( s :Sprite, playerId :int, centerX :int, centerY :int) :void
        {
            var playerName :String = null;
            if( _hierarchy._playerId2Name.containsKey( playerId ) ) {
                playerName = _hierarchy._playerId2Name.get( playerId ) as String;
            }
            if( playerName == null || playerName.length == 0 ) {
                playerName = ClientContext.getPlayerName(playerId);
            }
            var tf :TextField = getTextFieldCenteredOn( playerName, centerX, centerY);
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
        }
        
        protected function getTextFieldCenteredOn( text :String, centerX :int, centerY :int) :TextField
        {
            var tf :TextField = TextFieldUtil.createField(text, 
                {selectable:false, 
                tabEnabled:false, 
                background:true, 
                backgroundColor:0xffffff});
            tf.width = tf.textWidth + 5// + 40;
            tf.height = tf.textHeight + 4// + 10;
            
            tf.x = centerX - tf.width / 2;
            tf.y = centerY - tf.height / 2;
            return tf;
        }
        
        protected function drawLineFrom( s :Sprite, x1 :int, y1 :int, x2 :int, y2 :int) :void
        {
            GraphicsUtil.dashTo(s.graphics, x1, y1, x2, y2); 
        }


    } 
}