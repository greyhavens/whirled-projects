package bloodbloom {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Bitmap;
import flash.filters.GlowFilter;
import flash.geom.Point;

public class GameMode extends AppMode
{
    public function GameMode (playerType :int)
    {
        _playerType = playerType;
    }

    override protected function setup () :void
    {
        super.setup();

        ClientCtx.gameMode = this;

        // Setup display layers
        _modeSprite.addChild(ClientCtx.instantiateBitmap("bg"));

        _arteryBottom = ClientCtx.instantiateBitmap("artery_blue");
        _arteryBottom.x = Constants.GAME_CTR.x - (_arteryBottom.width * 0.5);
        _arteryBottom.y = 290;
        _modeSprite.addChild(_arteryBottom);

        _arteryTop = ClientCtx.instantiateBitmap("artery_red");
        _arteryTop.x = Constants.GAME_CTR.x - (_arteryTop.width * 0.5);
        _arteryTop.y = 30;
        _modeSprite.addChild(_arteryTop);

        ClientCtx.cellLayer = SpriteUtil.createSprite();
        ClientCtx.cursorLayer = SpriteUtil.createSprite();
        ClientCtx.effectLayer = SpriteUtil.createSprite();
        _modeSprite.addChild(ClientCtx.cellLayer);
        _modeSprite.addChild(ClientCtx.cursorLayer);
        _modeSprite.addChild(ClientCtx.effectLayer);

        // Setup game objects
        ClientCtx.beat = new Beat();
        addObject(ClientCtx.beat);

        ClientCtx.bloodMeter = new PredatorBloodMeter();
        ClientCtx.bloodMeter.x = BLOOD_METER_LOC.x;
        ClientCtx.bloodMeter.y = BLOOD_METER_LOC.y;
        addObject(ClientCtx.bloodMeter, ClientCtx.effectLayer);

        var heart :Heart = new Heart();
        heart.x = Constants.GAME_CTR.x;
        heart.y = Constants.GAME_CTR.y;
        addObject(heart, ClientCtx.cellLayer);

        // setup cells
        /*var cellSpawnRadius :NumRange = new NumRange(50, 170, Rand.STREAM_GAME);
        for (var type :int = 0; type < Constants.CELL__LIMIT; ++type) {
            // create initial cells
            for (var ii :int = 0; ii < Constants.INITIAL_CELL_COUNT[type]; ++ii) {
                spawnCell(type, cellSpawnRadius.next(), false);
            }

            // spawn new cells on a timer
            var spawnRate :NumRange = Constants.CELL_SPAWN_RATE[type];
            var spawner :SimObject = new SimObject();
            spawner.addTask(new RepeatingTask(
                new VariableTimedTask(spawnRate.min, spawnRate.max, Rand.STREAM_GAME),
                new FunctionTask(createCellSpawnCallback(type))));
            addObject(spawner);
        }*/

        // spawn cells when the heart beats
        registerListener(ClientCtx.beat, GameEvent.HEARTBEAT,
            function (...ignored) :void {
                var count :int = Constants.BEAT_CELL_BIRTH_COUNT.next();
                count = Math.min(count, Constants.MAX_CELL_COUNT - Cell.getCellCount());
                for (var ii :int = 0; ii < count; ++ii) {
                    var cellType :int =
                        (Rand.nextNumber(Rand.STREAM_GAME) <= Constants.RED_CELL_PROBABILITY ?
                            Constants.CELL_RED : Constants.CELL_WHITE);

                    addObject(new Cell(cellType, true), ClientCtx.cellLayer);
                }
            });

        // cursors
        ClientCtx.prey = new PreyCursor(_playerType == Constants.PLAYER_PREY);
        addObject(ClientCtx.prey, ClientCtx.cursorLayer);
        addObject(new PredatorCursor(_playerType == Constants.PLAYER_PREDATOR), ClientCtx.cursorLayer);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        _modeTime += dt;
    }

    public function gameOver (reason :String) :void
    {
        if (!_gameOver) {
            ClientCtx.mainLoop.changeMode(new GameOverMode(reason));
            _gameOver = true;
        }
    }

    public function get modeTime () :Number
    {
        return _modeTime;
    }

    public function hiliteArteries (hiliteTop :Boolean, hiliteBottom :Boolean) :void
    {
        _arteryTop.filters = (hiliteTop ? [ new GlowFilter(0x00ff00) ] : []);
        _arteryBottom.filters = (hiliteBottom ? [ new GlowFilter(0x00ff00) ] : []);
    }

    protected var _playerType :int;
    protected var _modeTime :Number = 0;
    protected var _gameOver :Boolean;
    protected var _arteryTop :Bitmap;
    protected var _arteryBottom :Bitmap;

    protected static const BLOOD_METER_LOC :Point = new Point(550, 75);
}

}
