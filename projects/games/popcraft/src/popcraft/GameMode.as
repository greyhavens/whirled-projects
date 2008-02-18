package popcraft {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.threerings.util.HashSet;
import com.threerings.util.RingBuffer;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.net.*;
import com.whirled.contrib.core.util.*;

import flash.display.DisplayObjectContainer;
import flash.events.KeyboardEvent;

import popcraft.battle.*;
import popcraft.battle.geom.AttractRepulseGrid;
import popcraft.net.*;
import popcraft.puzzle.*;

public class GameMode extends AppMode
{
    public static function get instance () :GameMode
    {
        var instance :GameMode = (MainLoop.instance.topMode as GameMode);

        Assert.isNotNull(instance);

        return instance;
    }
    
    public static function getNetObjectNamed (objectName :String) :SimObject
    {
        return GameMode.instance.netObjects.getObjectNamed(objectName);
    }
    
    public static function getNetObjectRefsInGroup (groupName :String) :Array
    {
        return GameMode.instance.netObjects.getObjectRefsInGroup(groupName);
    }

    public function GameMode ()
    {
    }

    // from com.whirled.contrib.core.AppMode
    override protected function setup () :void
    {
        _numPlayers = PopCraft.instance.gameControl.game.seating.getPlayerIds().length;
        
        var myPosition :int = PopCraft.instance.gameControl.game.seating.getMyPosition();
        var isAPlayer :Boolean = (myPosition >= 0);
        

        // everyone gets to see the BattleBoard
        _battleBoard = new BattleBoard(Constants.BATTLE_WIDTH, Constants.BATTLE_HEIGHT);

        _battleBoard.displayObject.x = Constants.BATTLE_BOARD_LOC.x;
        _battleBoard.displayObject.y = Constants.BATTLE_BOARD_LOC.y;

        this.addObject(_battleBoard, this.modeSprite);

        // only players get puzzles
        if (isAPlayer) {
            _playerData = new PlayerData(uint(myPosition));

            var resourceDisplay :ResourceDisplay = new ResourceDisplay();
            resourceDisplay.displayObject.x = Constants.RESOURCE_DISPLAY_LOC.x;
            resourceDisplay.displayObject.y = Constants.RESOURCE_DISPLAY_LOC.y;

            this.addObject(resourceDisplay, this.modeSprite);

            _puzzleBoard = new PuzzleBoard(
                Constants.PUZZLE_COLS,
                Constants.PUZZLE_ROWS,
                Constants.PUZZLE_TILE_SIZE);

            _puzzleBoard.displayObject.x = Constants.PUZZLE_BOARD_LOC.x;
            _puzzleBoard.displayObject.y = Constants.PUZZLE_BOARD_LOC.y;

            this.addObject(_puzzleBoard, this.modeSprite);

            // create the unit purchase buttons
            this.addObject(new UnitPurchaseButtonManager());
       }

        // set up some network stuff
        _messageMgr = new TickedMessageManager(PopCraft.instance.gameControl);
        _messageMgr.addMessageFactory(CreateUnitMessage.messageName, CreateUnitMessage.createFactory());

        if (Constants.DEBUG_LEVEL >= 1) {
            _messageMgr.addMessageFactory(ChecksumMessage.messageName, ChecksumMessage.createFactory());
        }

        _messageMgr.setup((0 == _playerData.playerId), TICK_INTERVAL_MS);

        // create a special ObjectDB for all objects that are synchronized over the network.
        _netObjects = new NetObjectDB();

        // create the player bases & waypoints
        var baseLocs :Array = Constants.getPlayerBaseLocations(numPlayers);
        var playerId :uint = 0;
        var n :int = baseLocs.length;
        for (var i :int = 0; i < n; ++i) {
            var baseLoc :Vector2 = (baseLocs[i] as Vector2);
            
            var base :PlayerBaseUnit = (UnitFactory.createUnit(Constants.UNIT_TYPE_BASE, playerId) as PlayerBaseUnit);
            base.unitSpawnLoc = baseLoc;
            base.x = baseLoc.x;
            base.y = baseLoc.y;
            
            _playerBaseRefs.push(base.ref);

            ++playerId;
        }

        // Listen for all keydowns.
        // The suggested way to do this is to attach an event listener to the stage,
        // but that's a security violation. The GameControl re-dispatches global key events for us instead.
        PopCraft.instance.gameControl.local.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, false);
    }

    // from com.whirled.contrib.core.AppMode
    override protected function destroy () :void
    {
        PopCraft.instance.gameControl.local.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);

        if (null != _messageMgr) {
            _messageMgr.shutdown();
            _messageMgr = null;
        }
    }

    // there has to be a better way to figure out charCodes
    protected static const KEY_4 :uint = "4".charCodeAt(0);
    protected function onKeyDown (e :KeyboardEvent) :void
    {
        if (Constants.CHEATS_ENABLED) {
            switch (e.charCode) {
            case KEY_4:
                for (var i :uint = 0; i < Constants.RESOURCE__LIMIT; ++i) {
                    _playerData.offsetResourceAmount(i, 100);
                }
                break;
            }
        }
    }

    // from AppMode
    override public function update (dt :Number) :void
    {
        // don't start doing anything until the messageMgr is ready
        if (!_gameIsRunning && _messageMgr.isReady) {
            trace("Starting game. randomSeed: " + _messageMgr.randomSeed);
            Rand.seedStream(Rand.STREAM_GAME, _messageMgr.randomSeed);
            _gameIsRunning = true;
        }

        if (!_gameIsRunning) {
            return;
        }

        // update the network
        _messageMgr.update(dt);

        while (_messageMgr.hasUnprocessedTicks) {

            // process all messages from this tick
            var messageArray: Array = _messageMgr.getNextTick();
            for each (var msg :Message in messageArray) {
                handleMessage(msg);
            }

            // run the simulation the appropriate amount
            // (our network update time is unrelated to the application's update time.
            // network timeslices are always the same distance apart)
            _netObjects.update(TICK_INTERVAL_S);

            if (Constants.DEBUG_LEVEL >= 1) {
                debugNetwork(messageArray);
            }

            ++_tickCount;

            // @TODO - remove this temporary hack that allows a single player
            // to play the game for testing purposes
            if (_numPlayers > 1) {
                
                // end the game when all bases but one have been destroyed
                var livingPlayers :HashSet = new HashSet();
                var n :uint = _playerBaseRefs.length;
                for (var playerId :uint = 0; playerId < n; ++playerId) {
                    if (null != getPlayerBase(playerId)) {
                        livingPlayers.add(playerId);
    
                        // if there's > 1 living player, the game can't be over
                        if (livingPlayers.size() > 1) {
                            break;
                        }
                    }
                }
    
                if (livingPlayers.size() <= 1) {
                    var winningPlayer :int = (livingPlayers.size() == 1 ? livingPlayers.toArray()[0] : -1);
                    MainLoop.instance.changeMode(new GameOverMode(winningPlayer));
                }
            }
        }

        // update all non-net objects
        super.update(dt);
    }

    public function getRandomEnemyPlayerId (myId :uint) :uint
    {
        var numPlayers :int = PopCraft.instance.gameControl.game.seating.getPlayerIds().length;
        var playerId :int = Rand.nextIntRange(0, numPlayers - 1, Rand.STREAM_GAME);
        if (playerId == myId) {
            playerId = numPlayers - 1;
        }

        return uint(playerId);
    }

    public function getPlayerBase (player :uint) :PlayerBaseUnit
    {
        return (_playerBaseRefs[player] as SimObjectRef).object as PlayerBaseUnit;
    }

    protected function debugNetwork (messageArray :Array) :void
    {
        // process all messages from this tick
        var messageStatus :String = new String();
        var needsBreak :Boolean = false;
        for each (var msg :Message in messageArray) {
            if (msg.name != ChecksumMessage.messageName) {
                if (needsBreak) {
                    messageStatus += " ** ";
                }
                messageStatus += msg.toString();
                needsBreak = true;
            }
        }

        if (messageStatus.length > 0) {
            trace("PLAYER: " + _playerData.playerId + " TICK: " + _tickCount + " MESSAGES: " + messageStatus);
        }

        // calculate a checksum for this frame
        var csumMessage :ChecksumMessage = calculateChecksum();

        // player 1 saves his checksums, player 0 sends his checksums
        if (_playerData.playerId == 1) {
            _myChecksums.unshift(csumMessage);
            _lastCachedChecksumTick = _tickCount;
        } else if ((_tickCount % 2) == 0) {
            _messageMgr.sendMessage(csumMessage);
        }
    }

    protected function calculateChecksum () :ChecksumMessage
    {
        var msg :ChecksumMessage = new ChecksumMessage(0, 0, 0, "");

        // iterate over all the shared state and calculate
        // a simple checksum for it
        var csum :Checksum = new Checksum();

        var i :int = 0;

        // random state
        add(Rand.nextInt(Rand.STREAM_GAME), "Rand state");

        // units
        /*var unitIds :Array = _netObjects.getObjectIdsInGroup(Unit.GROUP_NAME);
        add(unitIds.length, "units.length");
        for (i = 0; i < unitIds.length; ++i) {
            var unit :Unit = _netObjects.get(units[i] as Unit);
            add(unit.owningPlayerId, "unit.owningPlayerId - " + i);
            add(unit.unitType, "unit.unitType - " + i);
            add(unit.displayObject.x, "unit.displayObject.x - " + i);
            add(unit.displayObject.y, "unit.displayObject.y - " + i);
            add(unit.health, "unit.health - " + i);
        }*/

        msg.playerId = _playerData.playerId;
        msg.tick = _tickCount;
        msg.checksum = csum.value;

        return msg;

        var needsLinebreak :Boolean = false;

        function add (val :*, desc :String) :void
        {
            csum.add(val);

            if (Constants.DEBUG_LEVEL >= 2) {
                if (needsLinebreak) {
                    msg.details += "\n";
                }

                msg.details += String("csum : " + csum.value + "\t(desc: " + desc + ")\t(val: " + val + ")");
                needsLinebreak = true;
            }
        }
    }

    protected function handleMessage (msg :Message) :void
    {
        switch (msg.name) {
        case CreateUnitMessage.messageName:
            var createUnitMsg :CreateUnitMessage = (msg as CreateUnitMessage);
            UnitFactory.createUnit(createUnitMsg.unitType, createUnitMsg.owningPlayer);
            break;

        case ChecksumMessage.messageName:
            this.handleChecksumMessage(msg as ChecksumMessage);
            break;
        }

    }

    protected function handleChecksumMessage (msg :ChecksumMessage) :void
    {
        if (msg.playerId != _playerData.playerId) {
            // check this checksum against our checksum buffer
            if (msg.tick > _lastCachedChecksumTick || msg.tick <= (_lastCachedChecksumTick - _myChecksums.length)) {
                trace("discarding checksum message (too old or too new)");
            } else {
                var index :uint = (_lastCachedChecksumTick - msg.tick);
                var myChecksum :ChecksumMessage = (_myChecksums.at(index) as ChecksumMessage);
                if (myChecksum.checksum != msg.checksum) {
                    trace("** WARNING ** Mismatched checksums at tick " + msg.tick + "!");

                    // only dump the details once
                    if (!_syncError) {
                        trace("-- PLAYER " + myChecksum.playerId + " --");
                        trace(myChecksum.details);
                        trace("-- PLAYER " + msg.playerId + " --");
                        trace(msg.details);
                        _syncError = true;
                    }
                }
            }
        }
    }

    public function canPurchaseUnit (unitType :uint) :Boolean
    {
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        var n :uint = creatureCosts.length;
        for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
            var cost :int = creatureCosts[resourceType];
            if (cost > 0 && cost > playerData.getResourceAmount(resourceType)) {
                return false;
            }
        }

        return true;
    }

    public function purchaseUnit (unitType :uint) :void
    {
        if (!canPurchaseUnit(unitType)) {
            return;
        }

        // deduct the cost of the unit from the player's holdings
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
            _playerData.offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
        }

        // send a message!
        _messageMgr.sendMessage(new CreateUnitMessage(unitType, _playerData.playerId));
    }

    public function get playerData () :PlayerData
    {
        return _playerData;
    }

    public function get netObjects () :ObjectDB
    {
        return _netObjects;
    }

    public function get messageManager () :TickedMessageManager
    {
        return _messageMgr;
    }
    
    public function get battleUnitDisplayParent () :DisplayObjectContainer
    {
        return _battleBoard.unitDisplayParent;
    }
    
    public function get battleCollisionGrid () :AttractRepulseGrid
    {
        return _battleBoard.collisionGrid;
    }
    
    public function get numPlayers () :int
    {
        return _numPlayers;
    }

    protected var _gameIsRunning :Boolean;

    protected var _messageMgr :TickedMessageManager;
    protected var _puzzleBoard :PuzzleBoard;
    protected var _battleBoard :BattleBoard;
    protected var _playerData :PlayerData;

    protected var _netObjects :ObjectDB;

    protected var _playerBaseRefs :Array = new Array();
    protected var _numPlayers :int;

    protected var _tickCount :uint;
    protected var _myChecksums :RingBuffer = new RingBuffer(CHECKSUM_BUFFER_LENGTH);
    protected var _lastCachedChecksumTick :int;
    protected var _syncError :Boolean;

    protected static const TICK_INTERVAL_MS :int = 100; // 1/10 of a second
    protected static const TICK_INTERVAL_S :Number = (Number(TICK_INTERVAL_MS) / Number(1000));

    protected static const CHECKSUM_BUFFER_LENGTH :int = 10;
}

}
