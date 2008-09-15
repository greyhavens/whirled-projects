package joingame.net
{
    import flash.events.Event;

    public class JoinGameEvent extends Event
    {
        public function JoinGameEvent(playerid :int, type:String)
        {
            super(type, false, false);
            boardPlayerID = playerid;
            toFall = new Array();
            oldIndices = new Array();
            newIndices = new Array();
            indices = new Array();
            newColors = new Array();
        }
        
        override public function toString():String
        {
            return this.type;
        }
        
        //The player ID that is actively playing the game
//        public var clientPlayerID :int;
        //The player ID of the board that needs to update.  Not always the same as clientPlayerID
        //because clients show the boards to the left and right
        public var boardPlayerID :int;
        
//        public var boardRepresentation :Array;
        
//        public var joins :Array;
        public var joins :Array;
        
        public var oldIndices :Array;
        public var newIndices :Array;
        
        public var indices :Array;
        public var newColors :Array;
        
        public var deltaPiece1X :int;
        public var deltaPiece1Y :int;
        public var deltaPiece2X :int;
        public var deltaPiece2Y :int;
        
        public var toFall :Array;
        
        public var boardAttacked :int;
        public var row :int;
        public var damage: int;
        public var side :int;
        
        /* For vertical joins */
        public var col :int;
        
        
        public static const BOARD_UPDATED :String = "JoinGame Event: Board Updated";
        public static const RECEIVED_BOARDS_FROM_SERVER :String = "JoinGame Event: Boards Received From Server";
        
        public static const ATTACKING_JOINS :String = "JoinGame Event: Attacking Joins";
        
        public static const PLAYER_KNOCKED_OUT :String = "JoinGame Event: Player Knocked Out";
        
        public static const GAME_OVER :String = "JoinGame Event: Game Over";
        
        
        public static const DELTA_CONFIRM :String = "JoinGame Event: Delta Confirm";
        
        //Animations
        public static const CREATE_ANIMATION_PIECE_FALLING :String = "JoinGame Event: Animate Piece Falling";
        public static const CREATE_ANIMATION_HORIZONTAL_JOIN_ATTACK :String = "JoinGame Event: Animate Horizontal Join Attack";
        
        public static const DO_JOIN_VISUALIZATIONS :String = "JoinGame Event: Do Join Visualizations";
        
        public static const DO_PIECES_FALL :String = "JoinGame Event: Do Pieces Fall";
        
        public static const ADD_NEW_PIECES :String = "JoinGame Event: Add New Pieces";
        
        public static const VERTICAL_JOIN :String = "JoinGame Event: Vertical Join";
        
        public static const DO_DEAD_PIECES :String = "JoinGame Event: Show Dead Pieces";
        
        public static const REMOVE_ROW_PIECES :String = "JoinGame Event: Remove Row Pieces";
        public static const REMOVE_ROW_NOTIFICATION :String = "JoinGame Event: Remove Row Notification";//Server side only
        
        public static const DELETE_ROW_FROM_VIEW :String = "JoinGame Event: Delete Top From View";
        
        public static const REMOVE_BOTTOM_ROW_AND_DROP_PIECES :String = "JoinGame Event: Remove Bottom Row And Drop Pieces";
        
        public static const RESET_VIEW_FROM_MODEL :String = "JoinGame Event: Reset View From Model";
    }
}