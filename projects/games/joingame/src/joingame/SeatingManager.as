package joingame {

	import com.threerings.util.ArrayUtil;
	import com.whirled.game.GameControl;
	import com.whirled.game.OccupantChangedEvent;

//import flash.display.DisplayObject;
//import flash.display.Graphics;
//import flash.display.Shape;
//import flash.display.Sprite;
//
//import flash.text.TextField;
//import flash.text.TextFieldAutoSize;
//import flash.text.TextFormat;

	public class SeatingManager
	{
	    public static function init (gameControl:GameControl) :void
	    {
	    	_gameControl = gameControl;
	    	
	        if (_gameControl.isConnected()) {
	            _numExpectedPlayers = _gameControl.game.seating.getPlayerIds().length;
	            _headshots = ArrayUtil.create(_numExpectedPlayers, null);
	            _playersPresent = ArrayUtil.create(_numExpectedPlayers, false);
	            _localPlayerSeat = _gameControl.game.seating.getMyPosition();
	            updatePlayers();
	
	            // Use a high priority for these event handlers. We want to process them before
	            // anyone else does.
	            _gameControl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, updatePlayers);
	            _gameControl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, updatePlayers);
	
	        } else {
	            _numExpectedPlayers = 1;
	            _headshots = [ null ];
	            _numPlayers = 1;
	            _localPlayerSeat = 0;
	            _lowestOccupiedSeat = 0;
	        }
	    }
	
	    public static function get numExpectedPlayers () :int
	    {
	        return _numExpectedPlayers;
	    }
	
	    public static function get numPlayers () :int
	    {
	        return _numPlayers;
	    }
	
	    public static function get allPlayersPresent () :Boolean
	    {
	        return _numExpectedPlayers == _numPlayers;
	    }
	
	    public static function get localPlayerSeat () :int
	    {
	        return _localPlayerSeat;
	    }
	
	    public static function get localPlayerOccupantId () :int
	    {
	        return getPlayerOccupantId(_localPlayerSeat);
	    }
	
	    public static function isPlayerPresent (playerSeat :int) :Boolean
	    {
	        return _playersPresent[playerSeat];
	    }
	
	    public static function getPlayerName (playerSeat :int) :String
	    {
	        var playerName :String;
	        if (_gameControl.isConnected() && playerSeat < _numExpectedPlayers) {
	            playerName = _gameControl.game.seating.getPlayerNames()[playerSeat];
	        }
	
	        return (null != playerName ? playerName : "[Unknown Player: " + playerSeat + "]");
	    }
	
	    public static function getPlayerOccupantId (playerSeat :int) :int
	    {
	        if (_gameControl.isConnected() && playerSeat < _numExpectedPlayers) {
	            return _gameControl.game.seating.getPlayerIds()[playerSeat];
	        } else {
	            return 0;
	        }
	    }
	
	//    public static function getPlayerHeadshot (playerSeat :int) :DisplayObject
	//    {
	//        var headshot :DisplayObject;
	//
	//        if (playerSeat < _numExpectedPlayers) {
	//            headshot = _headshots[playerSeat];
	//        }
	//
	//        if (null == headshot) {
	//            // construct a default headshot (box with an X through it)
	//            var shape :Sprite = new Sprite();
	//            var g :Graphics = shape.graphics;
	//            g.lineStyle(2, 0);
	//            g.beginFill(0xffffff);
	//            g.drawRect(0, 0, 80, 60);
	//            g.endFill();
	//            g.lineStyle(2, 0xFF0000);
	//            g.moveTo(2, 2);
	//            g.lineTo(78, 58);
	//            g.moveTo(78, 2);
	//            g.lineTo(2, 58);
	//
	//
	//			//Adding name, remove in full game
	//			var label :TextField = new TextField();
	//	        label.text = getPlayerName(playerSeat);
	//	        label.autoSize = TextFieldAutoSize.LEFT;
	//	        shape.addChild(label);
	//	        
	//	        var label2 :TextField = new TextField();
	//	        label2.text = "Seat:" + playerSeat;
	//	        label2.autoSize = TextFieldAutoSize.LEFT;
	//	        label2.y = label.height + 10;
	//	        shape.addChild(label2);
	//			
	//            headshot = shape;
	//        }
	//
	//        return headshot;
	//    }
	
	    public static function get isLocalPlayerInControl () :Boolean
	    {
	        return _localPlayerSeat == _lowestOccupiedSeat;
	    }
	
	    protected static function updatePlayers (...ignored) :void
	    {
	    	trace("SeatingManager is updating players");
	        var playerIds :Array = _gameControl.game.seating.getPlayerIds();
	        _numPlayers = 0;
	        _lowestOccupiedSeat = -1;
	        for (var seatIndex :int = 0; seatIndex < playerIds.length; ++seatIndex) {
	            var playerId :int = playerIds[seatIndex];
	            var playerPresent :Boolean = (playerId != 0);
	
	            if (playerPresent) {
	                ++_numPlayers;
	                if (_lowestOccupiedSeat < 0) {
	                    _lowestOccupiedSeat = seatIndex;
	                }
	
	//                if (null == _headshots[seatIndex]) {
	//                    _headshots[seatIndex] = _gameControl.local.getHeadShot(playerId);
	//                }
	            }
	
	            _playersPresent[seatIndex] = playerPresent;
	        }
	        trace(" _playersPresent="+_playersPresent);
	    }
	
	    protected static var _playersPresent :Array;
	    protected static var _numExpectedPlayers :int;  // the number of players who initially joined the game
	    protected static var _numPlayers :int;          // the number of players in the game right now
	    protected static var _lowestOccupiedSeat :int;
	    protected static var _localPlayerSeat :int;
	    protected static var _headshots :Array;
	    
	    protected static var _gameControl :GameControl;
	}

}
