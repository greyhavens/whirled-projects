package joingame.view
{
    import com.threerings.util.*;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.tasks.*;
    import com.whirled.game.*;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    
    
    public class AllOpponentsView extends SceneObject
    {
        public function AllOpponentsView(control:GameControl, playerids :Array)
        {
            _control = control;
            _playerIDsInOrderOfPlay = playerids;
            _sprite = new Sprite();
            _playerIdToHeadShotMap = new HashMap();
            _playerIdToNameMap = new HashMap();
            _playerHeadshotPositionInPyramid = new Array();
            _playerIDsEliminated = new Array();
            
            // send property change notifications to the propertyChanged() method
//            _control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
            _control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            var format :TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 12;
            format.color = 0xff0033;
            format.bold = true;
            
            
            _textFieldActivePlayers = new TextField();
            _textFieldActivePlayers.defaultTextFormat = format;
            _textFieldActivePlayers.text = "Active players:     ";
            _textFieldActivePlayers.x = 2;
            _textFieldActivePlayers.y = 2;
            _textFieldActivePlayers.width = 100;
            _textFieldActivePlayers.height = _textFieldActivePlayers.textHeight + 2;
            _textFieldActivePlayers.type = TextFieldType.DYNAMIC;
            _textFieldActivePlayers.border = false;
            _sprite.addChild(_textFieldActivePlayers);
            
            _textFieldEliminatedPlayers = new TextField();
            _textFieldEliminatedPlayers.defaultTextFormat = format;
            _textFieldEliminatedPlayers.text = "Eliminated players: ";
            _textFieldEliminatedPlayers.x = 2;
            _textFieldEliminatedPlayers.y = 60;
            _textFieldEliminatedPlayers.width = 100;
            _textFieldEliminatedPlayers.height = _textFieldEliminatedPlayers.textHeight + 2;
            _textFieldEliminatedPlayers.type = TextFieldType.DYNAMIC;
            _textFieldEliminatedPlayers.border = false;        
            _sprite.addChild(_textFieldEliminatedPlayers);
            
            _textFieldMouseOverPlayer = new TextField();
            _textFieldMouseOverPlayer.defaultTextFormat = format;
            _textFieldMouseOverPlayer.text = "Eliminated players: ";
            _textFieldMouseOverPlayer.x = 2;
            _textFieldMouseOverPlayer.y = 60;
            _textFieldMouseOverPlayer.width = 100;
            _textFieldMouseOverPlayer.height = _textFieldMouseOverPlayer.textHeight + 2;
            _textFieldMouseOverPlayer.type = TextFieldType.DYNAMIC;
            _textFieldMouseOverPlayer.border = false;
            _textFieldMouseOverPlayer.backgroundColor = 0;
            
            
            
            
        }
        
        
        public function init() :void
        {
            getHeadShotsAndNames();
            /* Now add the player headshots */
            updateDisplay();
        }
        
//        protected function getHeadShots() :void
//        {
//            for(var i: int = 0; i < _playerIDsInOrderOfPlay.length; i++) {
//                var id:int = _playerIDsInOrderOfPlay[i] as int;
//                if( !_playerIdToHeadShotMap.containsKey(id)) {
//                    var headshot :DisplayObject = _control.local.getHeadShot( id);
//                    headshot.name
//                    headshot.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
//                    headshot.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
//                    var sceneobject :SimpleSceneObject = new SimpleSceneObject( headshot );
//                    _playerIdToHeadShotMap.put(id, sceneobject);
//                    _playerHeadShotToIdMap.put( sceneobject, id);
//                    
//                    db.addObject(sceneobject, _sprite);
//                }
//                    
//            }
//        }
        
        protected function getHeadShotsAndNames() :void
        {
            var playerids :Array = _control.game.seating.getPlayerIds();
            var playernames :Array = _control.game.seating.getPlayerNames();
            for(var i: int = 0; i < playerids.length; i++) {
                var id:int = playerids[i] as int;
                if( !_playerIdToNameMap.containsKey(id)) {
                    _playerIdToNameMap.put(id, playernames[i]);
                }
                
                if( !_playerIdToHeadShotMap.containsKey(id)) {
                    var headshot :DisplayObject = _control.local.getHeadShot( id);
                    headshot.name = playernames[i];
                    headshot.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
                    headshot.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
                    var sceneobject :SimpleSceneObject = new SimpleSceneObject( headshot );
                    _playerIdToHeadShotMap.put(id, sceneobject);
                    
                    db.addObject(sceneobject, _sprite);
                }
                
                    
            }
        }
        
        protected function getIDForHeadShot( query :DisplayObject ) :int 
        {
            var ids :Array = _playerIdToHeadShotMap.keys();
            for( var i :int = 0; i < ids.length; i++) {
                var headshot :SceneObject = _playerIdToHeadShotMap.get( ids[i] ) as SceneObject;
                if( headshot != null) {
                    if( query == headshot.displayObject ) {
                        return ids[i] as int;
                    }
                }
            } 
            return -1;
        }
        
        protected function messageReceived (event :MessageReceivedEvent) :void
        {
//            if (event.name == Server.ALL_PLAYERS_READY) {//we are too late for this
//                
//            }
        }
//        /** Responds to property changes. */
//        public function propertyChanged (event :PropertyChangedEvent) :void
//        {
//            if (event.name == Server.PLAYER_ORDER)
//            {
////                LOG("\nReceived player order ");
//                _playerIDsInOrderOfPlay = event.newValue as Array;
////                LOG("_playerIDsInOrderOfPlay="+_playerIDsInOrderOfPlay);
//                
//                for(var i: int = 0; i < _playerIDsInOrderOfPlay.length;i++)
//                {
//                    var id:int = _playerIDsInOrderOfPlay[i] as int;
//                    if( !_playerIdToHeadShotMap.containsKey(id))
//                    {
//                        _playerIdToHeadShotMap.put(id, _control.local.getHeadShot( id));
//                    }
//                    
//                }
//                 
//                 //Make sure there are arrays smaller than this one
//                 for(var v:int = 0; v < _playerIDsInOrderOfPlay.length; v++)
//                {
//                    if(_playerHeadshotPositionInPyramid[v] == null)
//                    {
//                        var tmpArray: Array = new Array();
//                        for(var k: int = 0; k < v+1; k++)
//                        {
//                            tmpArray.push(null);
//                        }
//                        _playerHeadshotPositionInPyramid[v] = tmpArray;
//                    }
//                }
//                 _playerHeadshotPositionInPyramid[_playerIDsInOrderOfPlay.length - 1] = ArrayUtil.copyOf(_playerIDsInOrderOfPlay);
//                 
//                 createOrUpdateOtherPlayerDisplay();     
//                
//            }
//            
//            
//        }
        
        
        protected function updateDisplay() :void
        {
            var headshot: SceneObject;
            var currentX :int = _textFieldActivePlayers.width + 2;
            var headshotHeight:int = 80;
            var toX :Number;
            var toY :Number;
            
            var ids:Array = _playerIdToHeadShotMap.keys();
            for( var i:int = 0; i < ids.length;i++)
            {
                var id:int = ids[i] as int;
                if( ! ArrayUtil.contains( _playerIDsEliminated, id)) {
                    headshot = _playerIdToHeadShotMap.get(id) as SceneObject; 
                
                    if( headshot != null)
                    {
                        toX = currentX;
                        toY = _textFieldActivePlayers.y;
        
                        headshot.addNamedTask(MOVE_TASK_NAME, LocationTask.CreateEaseIn(toX, toY, 2.0), true);  
                        currentX += headshot.width + 2;
                    
                    
                    }    
                }
                
            }
            
            currentX = _textFieldEliminatedPlayers.width + 2;
            for( i = 0; i < ids.length;i++)
            {
                id = ids[i] as int;
                if( ArrayUtil.contains( _playerIDsEliminated, id)) {
                    headshot = _playerIdToHeadShotMap.get(id) as SceneObject; 
                
                    if( headshot != null)
                    {
                        toX = currentX;
                        toY = _textFieldEliminatedPlayers.y;
        
                        headshot.addNamedTask(MOVE_TASK_NAME, LocationTask.CreateEaseIn(toX, toY, 2.0), true); 
                        currentX += headshot.width + 2;
                    }    
                }
                
            }
            
        }
        
        protected function mouseMoved( e :MouseEvent ) :void
        {
            var headshot :DisplayObject = e.target as DisplayObject;
            if( headshot != null ) {
                /* Add the mouseover text and position it */
                _textFieldMouseOverPlayer.x = headshot.x + e.localX;
                _textFieldMouseOverPlayer.y = headshot.y + e.localY;
                
                var id :int = getIDForHeadShot( headshot );
                if( id > -1) {
                    _textFieldMouseOverPlayer.text = headshot.name;
                }
                else {
                    _textFieldMouseOverPlayer.text = "No name found";
                }
                
                if( !_sprite.contains( _textFieldMouseOverPlayer )) {
                    _sprite.addChild( _textFieldMouseOverPlayer);
                }
                
                
            }
            else {
                trace("headshot is null");
            }
        }
        
        protected function mouseOut( e :MouseEvent ) :void
        {
            if( _sprite.contains( _textFieldMouseOverPlayer )) {
                    _sprite.removeChild( _textFieldMouseOverPlayer);
            }
        }
        
        protected function XXXDELETEcreateOrUpdateOtherPlayerDisplay(): void
        {
/*             this.x = 30;
            this.y = 80;
            this.scaleX = 0.3;
            this.scaleY = 0.3;
                
            var headshot: DisplayObject;
            
            var ids:Array = _playerIdToHeadShotMap.keys();
            for( var i:int = 0; i < ids.length;i++)
            {
                var id:int = ids[i] as int;
                headshot = _playerIdToHeadShotMap.get(id) as DisplayObject; 
                
                if( headshot != null)
                {
                    this.addChild(headshot);
                }
            }
        
        
            //Start drawing the players at the bottom, updating for the higher levels
            var HEADSHOT_SIZE:int = 80;
            var currentXAddition: int  = 0;
            for(var pyramidIndex:int = _playerHeadshotPositionInPyramid.length - 1; pyramidIndex >= 0; pyramidIndex--)
            {
                var playerIDArray: Array = _playerHeadshotPositionInPyramid[ pyramidIndex] as Array;
                
                if(playerIDArray != null)
                {
                    for( var headshotArrayIndex: int = 0; headshotArrayIndex < playerIDArray.length; headshotArrayIndex++)
                    {
                        this.graphics
//                        _playersDisplay.graphics.beginFill( 0xab6300, 1 );
                        this.graphics.lineStyle(2, 0x000000);
                        var boxsize: int = 15;
                        this.graphics.drawRect( headshotArrayIndex*HEADSHOT_SIZE+currentXAddition - boxsize/2, pyramidIndex*HEADSHOT_SIZE -boxsize/2 ,boxsize, boxsize);
                        this.graphics.endFill();
                        
                        
                        headshot = _playerIdToHeadShotMap.get( playerIDArray[headshotArrayIndex] ) as DisplayObject;
                        if(headshot != null)
                        {
                            headshot.x = headshotArrayIndex*HEADSHOT_SIZE+ currentXAddition - headshot.width/2;
                            headshot.y = pyramidIndex*HEADSHOT_SIZE - headshot.height/2;
                        }
                        
                        
                    }
                }
                
                //If there is a player at the top, draw the winner sign
                if(pyramidIndex == 0 && playerIDArray[0] != null)
                {
                    // Text format
                        var format :TextFormat = new TextFormat();
                        format.font = "Arial";
                        format.size = 12;
                        format.color = 0xff0033;
                        format.bold = true;
                        
                        
                        // Input field
                        var winnerText:TextField= new TextField();
                        winnerText.defaultTextFormat = format;
                        winnerText.text = "WINNER!!!!!";
                        winnerText.x = headshotArrayIndex*HEADSHOT_SIZE+ currentXAddition - 200;
                        winnerText.y = pyramidIndex*HEADSHOT_SIZE - 40;
                        winnerText.width = 100;
                        winnerText.height = winnerText.textHeight + 2;
                        winnerText.type = TextFieldType.DYNAMIC;
                        winnerText.border = false;
                        this.addChild(winnerText);

                }
                currentXAddition += HEADSHOT_SIZE/2;
            }
 */        }
        
        
        override public function get displayObject () :DisplayObject
        {
            return _sprite;
        }
    
        protected var _control :GameControl;
        protected var _sprite :Sprite;
    
    
        //The game is played in a circle.  As players are eliminated.        
        protected var _playerIDsInOrderOfPlay: Array;    
        protected var _playerIDsEliminated: Array; 
        
        protected var _playerIdToHeadShotMap: HashMap;
        
        protected var _playerIdToNameMap: HashMap;
        
        
        protected var _textFieldActivePlayers :TextField;
        protected var _textFieldEliminatedPlayers :TextField;
        protected var _textFieldMouseOverPlayer :TextField;
        
        //Array of arrays of headshots.  The first array is length 1, each other array is bigger by 1.  This 
        //represents a pyramid, with losing players remaining where they are, and others ascending 
        //to a level one smaller than the previous.
        protected var _playerHeadshotPositionInPyramid: Array;
        
        protected static const MOVE_TASK_NAME :String = "move";
    }
}