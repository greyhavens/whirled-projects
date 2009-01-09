package flashmob.server {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.net.NetConstants;

import flash.utils.ByteArray;

import flashmob.data.*;

public class SpectacleDb
{
    public function load () :void
    {
        init();

        log.info("Loading spectacles");

        // load spectacles from cold storage
        var bytes :ByteArray = ServerContext.gameCtrl.game.props.get(PROP_NAME) as ByteArray;
        if (bytes != null) {
            try {
                bytes.position = 0;
                _nextId = bytes.readInt();
                var numSpectacles :int = bytes.readInt();
                for (var ii :int = 0; ii < numSpectacles; ++ii) {
                    var spectacle :Spectacle = new Spectacle();
                    spectacle.fromBytes(bytes);
                    _spectacles.put(spectacle.id, spectacle);
                }

            } catch (e :Error) {
                log.error("Error loading spectacles!", e);
                init();
            }
        }

        log.info("Spectacles loaded: " + _spectacles.size());
    }

    public function save () :void
    {
        log.info("Saving spectacles");

        if (!_dirty) {
            log.info("No spectacles have changed; skipping save");
            return;
        }

        // write spectacles back to cold storage
        // TODO - cleanup old/unpopular/unused spectacles here?
        try {
            var bytes :ByteArray = new ByteArray();
            bytes.writeInt(_nextId);
            bytes.writeInt(_spectacles.size());
            _spectacles.forEach(
                function (id :int, spectacle :Spectacle) :void {
                    spectacle.toBytes(bytes);
                });

            ServerContext.gameCtrl.game.props.set(PROP_NAME, bytes, true);

        } catch (e :Error) {
            log.error("Error saving spectacles!", e);
        }

        log.info("Spectacles saved: " + _spectacles.size());
        _dirty = false;
    }

    public function addSpectacle (spectacle :Spectacle) :void
    {
        spectacle.id = _nextId++;
        _spectacles.put(spectacle.id, spectacle);
        _dirty = true;
    }

    public function removeSpectacle (id :int) :void
    {
        _spectacles.remove(id);
        _dirty = true;
    }

    public function getSpectacle (id :int) :Spectacle
    {
        return _spectacles.get(id) as Spectacle;
    }

    public function updateSpectacle (spectacle :Spectacle) :void
    {
        if (_spectacles.containsKey(spectacle.id)) {
            _spectacles.put(spectacle.id, spectacle);
        } else {
            addSpectacle(spectacle);
        }

        _dirty = true;
    }

    public function getAvailSpectacles (partySize :int) :SpectacleSet
    {
        var specSet :SpectacleSet = new SpectacleSet();
        specSet.spectacles = _spectacles.values().filter(
            function (spectacle :Spectacle, ...ignored) :Boolean {
                return spectacle.numPlayers == partySize;
            });
        return specSet;
    }

    protected function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected function init () :void
    {
        _nextId = 0;
        _spectacles = new HashMap();
        _dirty = false;
    }

    protected var _nextId :int;
    protected var _spectacles :HashMap;
    protected var _dirty :Boolean;

    protected static const PROP_NAME :String = NetConstants.makePersistent("All_Spectacles");
}

}
