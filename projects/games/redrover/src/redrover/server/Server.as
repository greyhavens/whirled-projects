package redrover.server {

import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.ServerObject;
import com.whirled.contrib.LevelPackManager;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

import flash.utils.ByteArray;

import redrover.util.GameUtil;
import redrover.data.*;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this);
        ServerCtx.seatingMgr.init(ServerCtx.gameCtrl);

        // We don't have anything to do in single-player games
        if (ServerCtx.seatingMgr.numExpectedPlayers < 2) {
            log.info("Singleplayer game. Not starting server.");
            //return;
        }

        // load our levels
        var levelPacks :LevelPackManager = new LevelPackManager();
        levelPacks.init(ServerCtx.gameCtrl.game.getLevelPacks());
        log.info("Read level packs: " + levelPacks.getAvailableIdents());
        for each (var levelPackName :String in levelPacks.getAvailableIdents()) {
            if (GameUtil.isLevelDataLevelPack(levelPackName)) {
                loadLevel(levelPackName);
            } else {
                log.info("Skipping level pack (doesn't look like a level)", "name", levelPackName);
            }
        }

        log.info("Starting server");

        // We want to shutdown the lobby when the game starts, and start it up
        // when the game ends.
        ServerCtx.gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                startGame();
            });

        ServerCtx.gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                stopGame();
            });
    }

    protected function loadLevel (levelPackName :String) :void
    {
        var levelIdx :int = GameUtil.getLevelPackLevelIdx(levelPackName);
        if (levelIdx < 0) {
            log.warning("Not loading level pack (unexpected name)", "name", levelPackName);
            return;
        }

        log.info("Loading level", "name", levelPackName, "idx", levelIdx);

        ServerCtx.gameCtrl.game.loadLevelPackData(
            levelPackName,
            function (bytes :ByteArray) :void {
                onLevelPackLoaded(levelIdx, bytes);
            },
            function (e :Error) :void {
                onLevelPackErr(levelIdx, e);
            });
    }

    protected function startGame () :void
    {
        log.info("Game started");
    }

    protected function stopGame () :void
    {
        log.info("Game ended");
    }

    protected function onLevelPackLoaded (levelIdx :int, data :ByteArray) :void
    {
        var levelData :LevelData;
        try {
            data.position = 0;
            var xml :XML = Util.newXML(data.readUTFBytes(data.length));
            levelData = LevelData.fromXml(xml.Level[0]);

        } catch (e :Error) {
            onLevelPackErr(levelIdx, e);
            return;
        }

        ServerCtx.levels[levelIdx] = levelData;
        log.info("Loaded level", "idx", levelIdx);
    }

    protected function onLevelPackErr (levelIdx :int, e :Error) :void
    {
        log.error("Error loading level", "levelIdx", levelIdx, e);
    }

    protected var _loadingData :int;

    protected const log :Log = Log.getLog(this);
}

}
