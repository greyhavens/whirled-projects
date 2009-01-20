package joingame
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.Log;
    import com.threerings.util.Random;
    import com.whirled.game.GameControl;
    import com.whirled.game.GameSubControl;
    import com.whirled.game.OccupantChangedEvent;
    import com.whirled.net.MessageReceivedEvent;
    
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import joingame.model.JoinGameBoardRepresentation;
    import joingame.model.JoinGameJoin;
    import joingame.model.JoinGameModel;
    import joingame.net.AddPlayerMessage;
    import joingame.net.AllPlayersReadyMessage;
    import joingame.net.BoardUpdateConfirmMessage;
    import joingame.net.BoardUpdateRequestMessage;
    import joingame.net.BottomRowRemovalConfirmMessage;
    import joingame.net.BottomRowRemovalRequestMessage;
    import joingame.net.DeltaRequestMessage;
    import joingame.net.GameOverMessage;
    import joingame.net.InternalJoinGameEvent;
    import joingame.net.ModelConfirmMessage;
    import joingame.net.PlayerDestroyedMessage;
    import joingame.net.PlayerReadyMessage;
    import joingame.net.PlayerReceivedGameStateMessage;
    import joingame.net.PlayerRemovedMessage;
    import joingame.net.RegisterPlayerMessage;
    import joingame.net.ReplayConfirmMessage;
    import joingame.net.ReplayRequestMessage;
    import joingame.net.ResetViewToModelMessage;
    import joingame.net.StartPlayMessage;
    import joingame.net.StartSinglePlayerGameMessage;
    import joingame.net.StartSinglePlayerWaveMessage;
    
    public class JoingameServer
    {
        private static const log :Log = Log.getLog(JoingameServer);
        
        public function JoingameServer(gameControl: GameControl = null)
        {
            if( gameControl == null ) {
                throw new Error("GameControl cannot be null for the server, even if it's not connected");
            }
            _gameCtrl = gameControl;//new GameControl(this);
            
            SeatingManager.init(_gameCtrl);
            
            if( AppContext.isConnected ) { //A local game, therefore listen to the MessageManager
                _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
                _gameCtrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, occupantEntered);
            }
            
            AppContext.messageManager.addEventListener( MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
            
            _gameModel = new JoinGameModel(_gameCtrl, true);
            _gameModel.addEventListener(InternalJoinGameEvent.GAME_OVER, handleGameOver);
            _gameModel.addEventListener(InternalJoinGameEvent.PLAYER_REMOVED, handlePlayerRemoved);
            
            
            
            _firstGame = true;
            _currentActivePlayers = new Array();
            _playersReady = new Array();
            _playersReceivedStartGameState = new Array();
            _playersThatWantToPlayAgain = new Array();
            
            _gameRestartTimer = new Timer(1000, 0);
            _gameRestartTimer.addEventListener(TimerEvent.TIMER, gameTimer);
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
            
            log.info("Hello world! I'm your Politik server!");
            
            _ai = new SinglePlayerServerPlugin( _gameModel, this);
            
        }
        
        protected function handleStartSinglePlayerWave ( event :StartSinglePlayerWaveMessage) :void
        {
            log.debug("handleStartSinglePlayerWave()");
            _ai.createNewSinglePlayerModel( _gameModel.humanPlayerId, Constants.SINGLE_PLAYER_GAME_TYPE_WAVES, event.userCookieData, -1);
            _gameModel.gameOver = false;
            if(AppContext.isConnected) {
//                _gameModel.singlePlayerLevel = Trophies.getPlayerLevelBasedOnTrophies(  _gameModel.humanPlayerId, _gameModel, event.userCookieData);
//                _gameModel.singlePlayerLevel = event.userCookieData.highestRobotLevelDefeated;
            }
            
            _ai.startAI();
            AppContext.messageManager.sendMessage( new ReplayConfirmMessage( _gameModel.currentSeatingOrder, _gameModel.getModelMemento()) );
        }

        protected function panic() :void
        {
            Log.setLevel(ClassUtil.getClassName(JoingameServer), Log.DEBUG);
        }
        
        
        
        protected function handleAddPlayer( event :AddPlayerMessage ) :void
        {
            if( !event.fromServer ) {
                log.debug("Server adding player NOT");
//                _ai.addNewComputerPlayer();

//                AppContext.messageManager.sendMessage( new AddPlayerMessage( 100, true));
            }
        }
        
        protected function handleStartSinglePlayerGame( event :StartSinglePlayerGameMessage ) :void
        {
            AppContext.isMultiplayer = false;
            
            if( _ai == null) {
                _ai = new SinglePlayerServerPlugin( _gameModel, this);
            }
            
            _ai.createNewSinglePlayerModel(event.playerId, event.gameType, event.userCookieData, event.requestedLevel);
            log.debug("Server sending singlepplayer" + AllPlayersReadyMessage.NAME );
            
            AppContext.messageManager.sendMessage( new AllPlayersReadyMessage( _gameModel.getModelMemento()) );
            _ai.startAI();
        }
        
        protected function handleRegisterPlayer( event :RegisterPlayerMessage ) :void
        {
            if(!ArrayUtil.contains( _currentActivePlayers, event.playerId))
                {
                    _currentActivePlayers.push( event.playerId );
                    log.debug("adding "  + event.playerId + " to " + _currentActivePlayers);
                    
                    if(AppContext.isSinglePlayer) {//The message means different 
                        
                    }
                    
                    //Start the game if the number of registered players equals expected players.
                    if( _currentActivePlayers.length >=  SeatingManager.numExpectedPlayers)
                    {
                        log.debug("ok start the game");
                        /* We send all the random number generator seeds to the players.
                           This is to ease the sync requirements.  That way, new pieces are still 
                           random, but identical on server and client. */
                           
                           
                        var playerids:Array = AppContext.isConnected ? _gameCtrl.game.seating.getPlayerIds() : [event.playerId];
                        
//                        _gameModel.potentialPlayerIds = playerids;
                        
                        _currentActivePlayers = playerids;
                        
                        AppContext.isMultiplayer = AppContext.isConnected ? _gameCtrl.game.seating.getPlayerIds().length > 1 : false;
                        
                        if(AppContext.isMultiplayer) {
                            createNewMultiPlayerModel();
                            log.debug("Server sending multiplayer" + ReplayConfirmMessage.NAME);
                            AppContext.messageManager.sendMessage( new ReplayConfirmMessage( _currentActivePlayers, _gameModel.getModelMemento()) );
                        }
                        else {
                            log.error("handleRegisterPlayer(), should be multi player game, but we're single player");
//                            if( _ai == null) {
//                                _ai = new SinglePlayerServerPlugin( _gameModel, this);
//                            }
//                            _ai.createNewSinglePlayerModel(event.playerId, event.gameType, event.level);
//                            log.debug("Server sending singlepplayer" + AllPlayersReadyMessage.NAME );
//                            
//                            AppContext.messageManager.sendMessage( new AllPlayersReadyMessage( _gameModel.getModelMemento()) );
                        }
    
                    }
                }
        }
        
        protected function handlePlayerReady( event :PlayerReadyMessage ) :void
        {
            if(!ArrayUtil.contains( _playersReady, event.playerId)) {
                _playersReady.push( event.playerId );
                if( _playersReady.length >= _currentActivePlayers.length ) {
                    AppContext.messageManager.sendMessage( new AllPlayersReadyMessage( _gameModel.getModelMemento()) );
                }
            }
        }
        
        protected function handlePlayerReceivedGameState( event :PlayerReceivedGameStateMessage ) :void
        {
            if(!ArrayUtil.contains( _playersReceivedStartGameState, event.playerId) && ArrayUtil.contains( _currentActivePlayers, event.playerId) ) {
                _playersReceivedStartGameState.push( event.playerId );
                if( _playersReceivedStartGameState.length >= _currentActivePlayers.length) {
                    AppContext.messageManager.sendMessage( new StartPlayMessage() );
                    
                    if(AppContext.isSinglePlayer) {
                        if( _ai == null ) {
                            _ai = new SinglePlayerServerPlugin( _gameModel, this);
                        }
                        _ai.startAI();
                    }
                }
            }
        }
        
        internal function handleDeltaRequest( event :DeltaRequestMessage ) :void
        {
            log.debug(event);
            
            
//            log.debug("testing");
//            log.debug("server board: " + _gameModel.getBoardForPlayerID( event.playerId ));
//            log.debug("client board: " + GameContext.gameModel.getBoardForPlayerID( event.playerId ));
//            
//            log.debug("change");
//            (_gameModel.getBoardForPlayerID( event.playerId ) as JoinGameBoardRepresentation)._boardPieceColors[0] = 8;
//            
//            log.debug("server board: " + _gameModel.getBoardForPlayerID( event.playerId ));
//            log.debug("client board: " + GameContext.gameModel.getBoardForPlayerID( event.playerId ));
            
            
            deltaRequest(event.playerId, event.fromX, event.fromY, event.toX, event.toY);
        }
            
        protected function handleBottomRowRemovalRequest( event :BottomRowRemovalRequestMessage ) :void
        {
            if(_gameModel.doRemoveBottomRow( _gameModel.getBoardForPlayerID( event.playerId) ) ) {
                AppContext.messageManager.sendMessage( new BottomRowRemovalConfirmMessage( event.playerId));
            }
        }
        
        protected function handleBoardUpdateRequest( event :BoardUpdateRequestMessage ) :void
        {
            var clientid :int = event.playerId;
            var boardplayerid:int =  event.boardId;
            
            if(boardplayerid >= 0 && isPlayerActive(boardplayerid))
            {
            
                //If there is no board we have to generate one.
                var board:JoinGameBoardRepresentation;
                if(!_gameModel.isPlayer(boardplayerid))//This also means we haven't registered the player
                {
                    board = createNewRandomBoard(boardplayerid);
                    _gameModel.addPlayer(boardplayerid, board, true);
                }
                board = _gameModel.getBoardForPlayerID(boardplayerid);
                AppContext.messageManager.sendMessage( new BoardUpdateConfirmMessage( clientid, boardplayerid, board.getBoardAsCompactRepresentation()));
            }
            else//If the player ID doesn't exist, send a dead board.
            {
                board = new JoinGameBoardRepresentation();
                board._rows = Constants.PUZZLE_STARTING_ROWS;
                board._cols = Constants.PUZZLE_STARTING_COLS;
                for(var k :int = 0; k < board._rows*board._cols; k++)
                {
                    board._boardPieceColors[k] = 0;
                    board._boardPieceTypes[k] = Constants.PIECE_TYPE_DEAD;
                }
                AppContext.messageManager.sendMessage( new BoardUpdateConfirmMessage( clientid, boardplayerid, board.getBoardAsCompactRepresentation()));
            }
        }
        
        protected function handleReplayRequest( event :ReplayRequestMessage ) :void
        {
            log.debug("server handleReplayRequest");
            var id :int = event.playerId;
            if( AppContext.isMultiplayer ) {
                log.debug("id=" + id + ", _playersThatWantToPlayAgain=" + _playersThatWantToPlayAgain + ", _currentActivePlayers="+_currentActivePlayers);
                if(id >= 0 && !ArrayUtil.contains(_playersThatWantToPlayAgain, id) && ArrayUtil.contains(_currentActivePlayers, id))
                {
                    _playersThatWantToPlayAgain.push( id);
                    _totalTimeElapsedSinceNewGameTimerStarted = 0;
                    if( _playersThatWantToPlayAgain.length == _currentActivePlayers.length && _currentActivePlayers.length > 1 ) {
                        createNewMultiPlayerModel();
                        log.debug("sending multiplayer" + ReplayConfirmMessage.NAME);
                        AppContext.messageManager.sendMessage( new ReplayConfirmMessage( _currentActivePlayers, _gameModel.getModelMemento()) );
                    }
                }
            }
            else {
                _ai.handleReplayRequest(event.playerId, event.userCookieData, event.requestedLevel);
            }
        }
                
        protected function gameTimer(  e :TimerEvent) :void
        {
            _totalTimeElapsedSinceNewGameTimerStarted++;
            if(_totalTimeElapsedSinceNewGameTimerStarted >= Constants.GAME_RESTART_TIME) {
                restartGameTimerComplete(e);
            }
        }

        protected function restartGameTimerComplete( e :TimerEvent) :void
        {
            _totalTimeElapsedSinceNewGameTimerStarted = 0;
            _gameRestartTimer.reset();
            
            if(_playersThatWantToPlayAgain.length > 1) {
                _currentActivePlayers = _playersThatWantToPlayAgain;
                createNewMultiPlayerModel();
            }
        }
    
        internal function handleGameOver( e: InternalJoinGameEvent) :void
        {
            trace("handleGameOver");
            if( _gameModel.gameOver ) {
                log.warning("gameOver(), but game is already over");
//                return;
            }
            
            _gameModel.gameOver = true;
            
            if( AppContext.isSinglePlayer) {
                _ai.handleGameOver();
            }
            else {
                
                /* We assign scores according to an exponential scale, so the winner gets a big pot,
                while those knocked out early get very little. The winner gets half the pot, followed
                by 2nd place getting a quarter, 3rd gets 1/8 and so on.*/
                
    //            var totalScore :int = 1000*_gameModel._initialSeatedPlayerIds.length;
                var playerIds :Array = new Array();
                var scores :Array = new Array();
                var playerIdsInOrderOfLoss :Array = _gameModel._playerIdsInOrderOfLoss.slice();
                playerIdsInOrderOfLoss.push( _gameModel.currentSeatingOrder[0]);
                
                for( var k :int = 0; k < playerIdsInOrderOfLoss.length; k++) {
                    playerIds.push( playerIdsInOrderOfLoss[k] );
    //                scores.push( scoreFunction(k+1) );
                    scores.push( (k+1) * 100 );
                }
                
    //            function scoreFunction( playersDefeated :int) :int{
    //                return playersDefeated*( 1.0 + (playersDefeated*1.1));
    //            }
                
                /* Changed the score due losers in two player games not getting anything. */
                
                
                
                
                trace("Multiplayer:\nAwarding scores:\nPlayer\t|\tScore");
                for(var i :int = playerIds.length - 1; i >=0; i--) {
                    trace(playerIds[i] + "\t|\t" + scores[i] );
                }
                
                if( AppContext.gameCtrl.isConnected()) {
                    _gameCtrl.game.endGameWithScores(playerIds, scores, GameSubControl.TO_EACH_THEIR_OWN);
                }
//                log.debug("Stopping AI because of game over");
//                _ai.stopAI();
                
                AppContext.messageManager.sendMessage( new GameOverMessage());
                
    //            var msg :Object = new Object;
    //            msg[0] = playerIds;
    //            msg[1] = scores;
    //            _gameCtrl.net.sendMessage( GAME_OVER, msg);
    //            _gameRestartTimer.start();
            }
            
        }




        protected function messageReceived (event :MessageReceivedEvent) :void
        {
            if (event.value is DeltaRequestMessage) {
                handleDeltaRequest( DeltaRequestMessage(event.value) );
            }
            else if (event.value is BoardUpdateRequestMessage) {
                handleBoardUpdateRequest( BoardUpdateRequestMessage(event.value) );
            }
            else if (event.value is BottomRowRemovalRequestMessage) {
                handleBottomRowRemovalRequest( BottomRowRemovalRequestMessage(event.value) );
            }
            else if (event.value is RegisterPlayerMessage) {
                handleRegisterPlayer( RegisterPlayerMessage(event.value) );
            }
            else if (event.value is PlayerReadyMessage) {
                handlePlayerReady( PlayerReadyMessage(event.value) );
            }
            else if (event.value is PlayerReceivedGameStateMessage) {
                handlePlayerReceivedGameState( PlayerReceivedGameStateMessage(event.value) );
            }
            else if (event.value is AddPlayerMessage) {
                handleAddPlayer( AddPlayerMessage(event.value) );
            }
            else if (event.value is StartSinglePlayerWaveMessage) {
                handleStartSinglePlayerWave( StartSinglePlayerWaveMessage(event.value) );
            }
            else if (event.value is ReplayRequestMessage) {
                handleReplayRequest( ReplayRequestMessage(event.value) );
            }
            else if (event.value is StartSinglePlayerGameMessage) {
                handleStartSinglePlayerGame( StartSinglePlayerGameMessage(event.value) );
            }
            else if (event.value is GameOverMessage) {
                if( AppContext.isSinglePlayer) {
                    _ai.handleGameOver();
                }
            }
            else {
                log.info("Message recieved but not handled: " + event.value );
            }
            
            //            AppContext.messageManager.addEventListener( DeltaRequestMessage.NAME, handleDeltaRequest);
//            AppContext.messageManager.addEventListener( BoardUpdateRequestMessage.NAME, handleBoardUpdateRequest);
//            AppContext.messageManager.addEventListener( BottomRowRemovalRequestMessage.NAME, handleBottomRowRemovalRequest);
//            AppContext.messageManager.addEventListener( RegisterPlayerMessage.NAME, handleRegisterPlayer);
//            AppContext.messageManager.addEventListener( PlayerReadyMessage.NAME, handlePlayerReady);
//            AppContext.messageManager.addEventListener( PlayerReceivedGameStateMessage.NAME, handlePlayerReceivedGameState);
//            AppContext.messageManager.addEventListener( AddPlayerMessage.NAME, handleAddPlayer);
//            AppContext.messageManager.addEventListener( StartSinglePlayerWave.NAME, handleStartSinglePlayerWave);
//            AppContext.messageManager.addEventListener( ReplayRequestMessage.NAME, handleReplayRequest);


//            log.debug("Deprecated, should not be here..." + event.name);
            
            
//            var msg :Object;
//            var k: int;
//            var id :int;
//            var clientid :int;

            
            /* If all players have registered that they are ready, send the game state to all.*/   
//            if (event.name == REGISTER_PLAYER)
//            {
//                if(!ArrayUtil.contains( _currentActivePlayers, event.senderId))
//                {
//                    _currentActivePlayers.push( event.senderId );
//                    log.debug("adding "  + event.senderId + " to " + _currentActivePlayers);
//                    if( _currentActivePlayers.length >= SeatingManager.numExpectedPlayers)
//                    {
//                        log.debug("ok start the game");
//                        /* We send all the random number generator seeds to the players.
//                           This is to ease the sync requirements.  That way, new pieces are still 
//                           random, but identical on server and client. */
//                        var playerids:Array = _gameCtrl.game.seating.getPlayerIds();
//                        
//                        _gameCtrl.net.set( POTENTIAL_PLAYERS, playerids);
//                        _currentActivePlayers = playerids;
//                        
//                        Constants.isMultiplayer = _gameCtrl.game.seating.getPlayerIds().length > 1;
//                        
//                        if(Constants.isMultiplayer) {
//                            createNewMultiPlayerModel();
//                            
//                            msg = new Object;
//                            msg[0] = _currentActivePlayers;
//                            msg[1] = _gameModel.getModelMemento();
//                            log.debug("sending multiplayer" + REPLAY_CONFIRM);
//                            _gameCtrl.net.sendMessage(REPLAY_CONFIRM, msg);
//                        }
//                        else {
//                            log.debug("sending singlepplayer" + ALL_PLAYERS_READY);
//                            createNewSinglePlayerModel();
//                            msg = new Object;
//                            msg[0] = _gameModel.getModelMemento();
//                            _gameCtrl.net.sendMessage(ALL_PLAYERS_READY, msg);
//                        }
//    
//                    }
//                }
//                
//            }
//            else if (event.name == PLAYER_READY)
//            {
//                if(!ArrayUtil.contains( _playersReady, event.senderId))
//                {
//                    _playersReady.push( event.senderId );
//                    
//                    if( _playersReady.length >= _currentActivePlayers.length )
//                    {
//                        msg = new Object;
//                        msg[0] = _gameModel.getModelMemento();
//                        _gameCtrl.net.sendMessage(ALL_PLAYERS_READY, msg );
//                    }
//                }
//            }
//            if (event.name == PLAYER_RECEIVED_START_GAME_STATE)
//            {
//                
//                if(!ArrayUtil.contains( _playersReceivedStartGameState, event.senderId) && ArrayUtil.contains( _currentActivePlayers, event.senderId) )
//                {
//                    _playersReceivedStartGameState.push( event.senderId );
//                    
//                    if( _playersReceivedStartGameState.length >= _currentActivePlayers.length)//SeatingManager.numExpectedPlayers
//                    {
//                        _gameCtrl.net.sendMessage( START_PLAY, {});
//                    }
//                }
//            }
//            else if (event.name == BOARD_DELTA_REQUEST)
//            {
//                //Only the owner can change her own board.
//                if(event.senderId == event.value[0])
//                {
//                    deltaRequest(int(event.value[0]), int(event.value[2]), int(event.value[3]), int(event.value[4]), int(event.value[5]));
//                }
//            }
//            else if (event.name == BOARD_BOTTOM_ROW_REMOVAL_REQUEST_FROM_BUTTON)
//            {
//                //Only the owner can change her own board.
//                if(event.senderId == event.value[0])
//                {
//                    msg = new Object();
//                    msg[0] = event.senderId;
//                    if(_gameModel.doRemoveBottomRow( _gameModel.getBoardForPlayerID( event.senderId) ) ) {
//                        _gameCtrl.net.sendMessage(BOARD_REMOVE_ROW_CONFIRM, msg);
//                    }
//                }
//            }
//            else if (event.name == BOARD_REMOVE_ROW_CONFIRM_TO_SERVER)
//            {
//                id = int(event.value[0]);
//                if(id >= 0)
//                {
//                    msg = new Object();
//                    msg[0] = id;
//                    if(_gameModel.doRemoveBottomRow( _gameModel.getBoardForPlayerID( id) ) ) {
//                        _gameCtrl.net.sendMessage(BOARD_REMOVE_ROW_CONFIRM, msg);
//                    }
//                    
//                }
//            }
//            else if (event.name == BOARD_UPDATE_REQUEST)
//            {
//                
//                clientid = int(event.value[0]);
//                var boardplayerid:int =  int(event.value[1]);
//                
//                if(boardplayerid >= 0 && isPlayerActive(boardplayerid))
//                {
//                
//                    //If there is no board we have to generate one.
//                    var board:JoinGameBoardRepresentation;
//                    if(!_gameModel.isPlayer(boardplayerid))//This also means we haven't registered the player
//                    {
//                        board = createNewRandomBoard(boardplayerid);
//                        _gameModel.addPlayer(boardplayerid, board);
//                    }
//                    board = _gameModel.getBoardForPlayerID(boardplayerid);
//                    
//                    msg = new Object;
//                    msg[0] = clientid;
//                    msg[1] = boardplayerid;
//                    msg[2] = board.getBoardAsCompactRepresentation();
//                    
//                    _gameCtrl.net.sendMessage(BOARD_UPDATE_CONFIRM, msg, clientid );
//                }
//                else//If the player ID doesn't exist, send a dead board.
//                {
//                    board = new JoinGameBoardRepresentation();
//                    board._rows = Constants.PUZZLE_STARTING_ROWS;
//                    board._cols = Constants.PUZZLE_STARTING_COLS;
//                    for(k = 0; k < board._rows*board._cols; k++)
//                    {
//                        board._boardPieceColors[k] = 0;
//                        board._boardPieceTypes[k] = Constants.PIECE_TYPE_DEAD;
//                    }
//                        
//                    msg = new Object;
//                    msg[0] = clientid;
//                    msg[1] = boardplayerid;
//                    msg[2] = board.getBoardAsCompactRepresentation();
//                    _gameCtrl.net.sendMessage(BOARD_UPDATE_CONFIRM, msg, clientid );
//                }
//            }
//            else if (event.name == MODEL_REQUEST)
//            {
//                msg = new Object;
//                msg[0] = _gameModel.getModelMemento();
//                _gameCtrl.net.sendMessage(MODEL_CONFIRM, msg);//, event.senderId );
//            }
//            else if (event.name == REPLAY_REQUEST)
//            {
//                id = event.senderId;
//                log.debug("id=" + id + ", _playersThatWantToPlayAgain=" + _playersThatWantToPlayAgain + ", _currentActivePlayers="+_currentActivePlayers);
//                if(id >= 0 && !ArrayUtil.contains(_playersThatWantToPlayAgain, id) && ArrayUtil.contains(_currentActivePlayers, id))
//                {
//                    _playersThatWantToPlayAgain.push( id);
//                    _totalTimeElapsedSinceNewGameTimerStarted = 0;
////                    _gameRestartTimer.reset();
////                    _gameRestartTimer.start();
//                    if( _playersThatWantToPlayAgain.length == _currentActivePlayers.length && _currentActivePlayers.length > 1 ) {
////                        _gameRestartTimer.reset();
//                        createNewMultiPlayerModel();
//                        
//                        msg = new Object;
//                        msg[0] = _currentActivePlayers;
//                        msg[1] = _gameModel.getModelMemento();
//                        log.debug("sending multiplayer" + REPLAY_CONFIRM);
//                        _gameCtrl.net.sendMessage(REPLAY_CONFIRM, msg);
//                            
//                    }
//                }
//            }
        }


        protected function createNewMultiPlayerModel() :void
        {
            var k :int;
            
            _playersThatWantToPlayAgain = new Array();
            _playersReceivedStartGameState = new Array();
            _currentActivePlayers = randomizeArray(_currentActivePlayers);
            _playersReady = new Array();
            _gameModel.removeAllPlayers();
            
            for(k = 0; k < _currentActivePlayers.length; k++)
            {
                _gameModel.addPlayer(_currentActivePlayers[k], createNewRandomBoard(_currentActivePlayers[k]), true);
            }
            
            _gameModel._initialSeatedPlayerIds = _currentActivePlayers.slice();
            _gameModel.currentSeatingOrder = _currentActivePlayers.slice();
            _gameModel.setModelIntoPropertySpaces();
            
            AppContext.database.clearAll();
        }
        
//        protected function createNewSinglePlayerModel() :void
//        {
//            _gameModel.removeAllPlayers();
//            _gameModel.addPlayer(_currentActivePlayers[0], createNewRandomBoard(_currentActivePlayers[0]));
//            /* Add 1 players to left and right.  These will get regenerated as they are killed */
//            /* Use ids below -1 to indicate computer players */
//            for( var level :int = _ai.playerLevel; level < level + Constants.SINGLE_PLAYER_NUMBER_OF_OPPONENTS_PER_WAVE; level++) {
//                
//            }
//            for each ( var id :int in [-2, -3]) {
//                _gameModel.addPlayer(id, createNewRandomBoard(id));
//            } 
//            _gameModel._initialSeatedPlayerIds = [_currentActivePlayers[0], -2, -3];
//            _gameModel.currentSeatingOrder = _gameModel._initialSeatedPlayerIds.slice();
//           _gameModel.setModelIntoPropertySpaces();
//           _ai.currentLowestComputerId = -3;
//            
//        }


        protected function randomizeArray( array :Array) :Array {
            var l:Number = array.length-1;
            for (var it :int = 0; it<l; it++) {
                var r :int = Math.round(Math.random()*l)
                var tmp :int = array[it] as int;
                array[it] = array[r];
                array[r] = tmp;
            }
            return array;
        }
            
        internal function createNewRandomBoard(playerid:int): JoinGameBoardRepresentation
        {
            var board:JoinGameBoardRepresentation = new JoinGameBoardRepresentation();
            board.playerID = playerid;
            board._rows = Constants.PUZZLE_STARTING_ROWS;
            board._cols = Constants.PUZZLE_STARTING_COLS;
            board.randomSeed = int(Math.random()*1000);
            board._isComputerPlayer = false;
            while(board.randomSeed == 0)
            {
                board.randomSeed = int(Math.random()*1000); 
            }
            board._numberOfCallsToRandom = 0;
            for(var k:int = 0; k < board._rows*board._cols; k++)
            {
                board._boardPieceColors[k] = generateRandomPieceColor();
                board._boardPieceTypes[k] = Constants.PIECE_TYPE_NORMAL;
            }
            var joins:Array = board.checkForJoins();
            while(joins.length > 0)
            {
                joins = board.checkForJoins();
                for(var i :int = 0; i < joins.length; i++)
                {
                    var join :JoinGameJoin = joins[i] as JoinGameJoin;
                    /* Remove pieces in the join */
                    for(var piecei :int = 0; piecei < join._piecesX.length; piecei++)
                    {
                        board._boardPieceTypes[ board.coordsToIdx( join._piecesX[piecei], board.convertFromBottomYToFromTopY(join._piecesYFromBottom[piecei])) ]  = Constants.PIECE_TYPE_EMPTY;
                    }
                }
                _gameModel.doPiecesFall(board, 0, 0);
                _gameModel.addNewPieces(board, 0, 0);
                joins = board.checkForJoins();
            }
            return board;
        }
        protected static function generateRandomBoardRepresentation(rows:int, cols:int): Array
        {
            var rep: Array = new Array();
            rep[0] = rows;
            rep[1] = cols;
            
            var colors:Array = new Array();
            var types:Array = new Array();
            
            for(var k: int = 0; k < rows*cols; k++)
            {
                colors[k] = generateRandomPieceColor();
                types[k] = Constants.PIECE_TYPE_NORMAL;
            }
            rep[2] = colors;
            rep[3] = types;
            
            return rep;
        }

        //If someone leaves the game, they are eliminated immediately
        protected function occupantLeft( event: OccupantChangedEvent): void
        {
            if(event.player)//If a player and not a spectator.
            {
                playerLeftOrKnockedOut( event.occupantId );
                
//                var ids :Array = _gameModel.potentialPlayerIds;
//                if( ArrayUtil.contains( ids, event.occupantId ) ) {
//                    ids.splice( ArrayUtil.indexOf( ids, event.occupantId), 1);
//                    _gameModel.potentialPlayerIds = ids;
//                }
            
                /* Remove the possibility of this player replaying*/
                if( ArrayUtil.contains( _currentActivePlayers, event.occupantId )) {
                    _currentActivePlayers.splice( _currentActivePlayers.indexOf( event.occupantId ), 1 );
                }
                
                if( _gameModel.currentSeatingOrder.length <= 0) {
                    _gameRestartTimer.removeEventListener(TimerEvent.TIMER, gameTimer);
                }
            }
            
            
            
        }    
        
        
        protected function destroy() :void
        {
            _gameRestartTimer.removeEventListener(TimerEvent.TIMER, gameTimer);
            if( _gameRestartTimer.running ) {
                _gameRestartTimer.stop();
            }
            _ai.destroy();
            
        }
        
        protected function occupantEntered( event: OccupantChangedEvent): void
        {
            if(!event.player)//If a player and not a spectator.
            {
                
                AppContext.messageManager.sendMessage( new ModelConfirmMessage(event.occupantId, _gameModel.getModelMemento()), event.occupantId);
//                var msg :Object = new Object;
//                msg[0] = _gameModel.getModelMemento();
//                _gameCtrl.net.sendMessage(MODEL_CONFIRM, msg, event.occupantId );
            }
            
        } 

        
        protected static function generateRandomPieceColor(): int
        {
            return randomNumber(1, Constants.PIECE_COLORS_ARRAY.length);
        }

        /** 
        * Generate a random number
        * @return Random Number
        * @error throws Error if low or high is not provided
        */  
        private static function randomNumber(low:Number=NaN, high:Number=NaN):Number
        {
            var low:Number = low;
            var high:Number = high;
        
            if(isNaN(low))
            {
                throw new Error("low must be defined");
            }
            if(isNaN(high))
            {
                throw new Error("high must be defined");
            }
        
            return Math.round(Math.random() * (high - low)) + low;
        }
        

        
        
        protected function deltaRequest(playerID:int, oldX:int, oldY:int, newX:int, newY:int): void
        {
            log.debug("SERVER deltaRequest");
            var board: JoinGameBoardRepresentation = _gameModel.getBoardForPlayerID(playerID);
            
            if( board == null ) {
                log.error("deltaRequest, but no board for player=" + playerID);
                panic();
                return;
            }
            
            
            var fromIndex:int = board.coordsToIdx( oldX, oldY);
            var toIndex:int = board.coordsToIdx( newX, newY);
            
            var msg :Object = new Object;
            
            if( isLegalMove(playerID, fromIndex, toIndex)){
                
//                log.debug("SERVER server board before: " + board);
//                log.debug("SERVER client board before: " + GameContext.gameModel.getBoardForPlayerID(playerID));
                
                _gameModel.deltaConfirm(playerID, fromIndex, toIndex);
                
//                log.debug("SERVER server board after: " + board);
//                log.debug("SERVER client board after: " + GameContext.gameModel.getBoardForPlayerID(playerID));
                
                
                //Send updates to players 
                
                
                            }
            else{
                log.warning("Illegal move, sending board reset to player " + playerID);
                AppContext.messageManager.sendMessage( new ResetViewToModelMessage( playerID));
                
            }
        }
        
        

        
        
        
        /**
         * This is the main role of the server: checking the validity of moves
         * to prevent cheating.  Only valid moves are returned approved.
         */
        protected function isLegalMove(playerID:int, fromIndex:int, toIndex:int): Boolean
        {
            
            if(!isPlayerActive(playerID))
            {
                log.debug("  isLegalMove(), player not active");
                return false;
            }
            var board: JoinGameBoardRepresentation = _gameModel.getBoardForPlayerID(playerID);
            if(board == null)
            {
                log.debug("  isLegalMove(), player board == null");
                return false;
            }
            
            return board.isLegalMove(fromIndex, toIndex);
//            //Make sure the pieces are in the same column
//            var i:int = board.idxToX(fromIndex);
//            if(i < 0 || i != board.idxToX(toIndex) )
//            {
//                log.debug("  isLegalMove(), pieces not in same column");
//                return false;
//            }
//            
//            //And finally check that both pieces are valid, and all the inbetween pieces.
//            for(var j:int =  Math.min( board.idxToY( fromIndex), board.idxToY(toIndex)); j <=  Math.max( board.idxToY(fromIndex), board.idxToY(toIndex)); j++)
//            {
//                if( board._boardPieceTypes[ board.coordsToIdx( i, j)] != Constants.PIECE_TYPE_NORMAL)
//                {
//                    return false;    
//                }
//            }
//            return true;
        }
        


        protected function isPlayerActive(playerID:int): Boolean
        {
            
            if(_gameModel.currentSeatingOrder == null)
            {
                log.warning("isPlayerActive( " + playerID + "), but _gameModel.currentSeatingOrder == null");
                return false;
            }
            
            return ArrayUtil.contains(_gameModel.currentSeatingOrder, playerID);
        }

        protected function handlePlayerRemoved( event :InternalJoinGameEvent ) :void 
        {
            log.debug("handlePlayerRemoved( " + event.boardPlayerID+ ")");
            if(ArrayUtil.contains( _gameModel.currentSeatingOrder, event.boardPlayerID))//If a player and not a spectator.
            {
                playerLeftOrKnockedOut( event.boardPlayerID );
            }
            else {
                log.warning("handlePlayerRemoved( " + event.boardPlayerID + " ), but not in seating order so playerLeftOrKnockedOut() not called.");
            }
        }

        protected function playerLeftOrKnockedOut( playerid :int) :void
        {
            log.debug("playerLeftOrKnockedOut()");
            if( _gameModel == null ) {
                log.error("playerLeftOrKnockedOut(), _gameModel == null");
                return;
            }
            var time :int = getTimer();
            var removePlayerOutAfterDelayTimer :Timer;
            
            if(AppContext.isMultiplayer) {
                
                if( ArrayUtil.contains(_gameModel.currentSeatingOrder, playerid)) {
                    AppContext.messageManager.sendMessage( new PlayerDestroyedMessage( playerid));
                    removePlayerOutAfterDelayTimer = new Timer( Constants.BOARD_DISTRUCTION_TIME * 1000, 1);
                    removePlayerOutAfterDelayTimer.addEventListener(TimerEvent.TIMER, removePlayer);
                    removePlayerOutAfterDelayTimer.start();
                }
                
                function removePlayer( e :TimerEvent ) :void
                {
                    removePlayerOutAfterDelayTimer.removeEventListener(TimerEvent.TIMER, removePlayer);
                    _gameModel.removePlayer(playerid);
                    AppContext.messageManager.sendMessage( new PlayerRemovedMessage( playerid));
                }
                
            }
            else {
                if( _ai != null) {
                    _ai.playerLeftOrKnockedOut( playerid );
                }
            }
        }
            
        
                





        public var _gameCtrl :GameControl;
        
        //This variable represents the entire game state
        private var _gameModel: JoinGameModel;
        
        //When all players have received the start game state
        public var _playersReceivedStartGameState: Array;
        
        //Players that quit during the game are not eligible to play again
        public var _currentActivePlayers: Array;
        public var _playersThatWantToPlayAgain: Array;
        
        public var _playersReady: Array;
        
        private var _random: Random = new Random();
        
        protected var _gameRestartTimer :Timer;
        
        protected var _firstGame :Boolean;
        
        protected var _totalTimeElapsedSinceNewGameTimerStarted :int;
        
//        protected var _singlePlayerData :SinglePlayerData = new SinglePlayerData();
        protected var _ai :SinglePlayerServerPlugin;
        
        
        
//        public static const BOARD_DELTA_REQUEST :String = "Server:Board Delta Request";
//        public static const BOARD_DELTA_CONFIRM :String = "Server:Board Delta Confirm"; 
//        public static const BOARD_UPDATE_REQUEST :String = "Server:Board Update Request";
//        public static const BOARD_UPDATE_CONFIRM :String = "Server:Board Update Confirm";
        
//        public static const BOARD_BOTTOM_ROW_REMOVAL_REQUEST_FROM_BUTTON :String = "Server:Board Bottom Row Removal Request From Button";
//        public static const BOARD_BOTTOM_ROW_REMOVAL_CONFIRM_FROM_BUTTON :String = "Server:Board Bottom Row Removal Confirm From Button";
        
        
//        public static const MODEL_REQUEST :String = "Server:Model Request";
//        public static const MODEL_CONFIRM :String = "Server:Model Confirm";
        
        /**
        * If conflicts occur due to timing of events, tell a board to reset it's view.
        */
//        public static const BOARD_REMOVE_ROW_CONFIRM :String = "Server:Board Remove Row Confirm";
//        public static const BOARD_REMOVE_ROW_CONFIRM_TO_SERVER :String = "Server:Board Remove Row Confirm Server Only";
        
        
//        public static const RESET_VIEW_TO_MODEL :String = "Server:Reset View To Model";   
        
//        public static const ALL_PLAYERS_READY :String = "Server:All Players Ready";
//        public static const PLAYER_READY :String = "Server:Player Ready";
//        public static const PLAYER_RECEIVED_START_GAME_STATE :String = "Server:Player Recieved Start Game State";
//        public static const START_PLAY :String = "Server:Start Play";
//        public static const GAME_OVER :String = "Server:Game Over";   
        
//        public static const REPLAY_REQUEST :String = "Server:Request Replay";
//        public static const REPLAY_CONFIRM :String = "Server:Confirm Replay"; 
//        public static const REGISTER_PLAYER :String = "Server:Register Player"; 
        
        
//        public static const PLAYER_DESTROYED :String = "Server:Player Destroyed";
//        public static const PLAYER_REMOVED :String = "Server:Player Removed";
        
        /** Request the entire game state */
        public static const REQUEST_START_STATE :String = "Server:Request Start State";
        
        /** All players that have not permamnently left the game */
//        public static const POTENTIAL_PLAYERS :String = "Server:Potential Players";
        
        private var LOG_TO_GAME:Boolean = false;
        

    }
}