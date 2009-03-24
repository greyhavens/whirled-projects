package vampire.avatar {

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.contrib.ColorMatrix;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.utils.ByteArray;

public class VampireBody extends NewBody
{
    /**
     * configOptions should be of the form:
     * var configOptions :Object = {
     *       topRemix: [
     *          [ "torso", "shirt" ],
     *          // ...
     *       ],
     *       hairRemix: [],
     *       shoesRemix: [],
     *       skinRecolor: [],
     *       hairRecolor: [],
     *       topRecolor: [],
     *       pantsRecolor: [],
     *       shoesColor: []
     *  };
     */
    public function VampireBody (ctrl :AvatarControl,
                                 media :MovieClip,
                                 isConfigurable :Boolean,
                                 configOptions :Object,
                                 width :int, height :int = -1)
    {
        super(ctrl, media, width, height);

        _configOptions = configOptions;

        // Entity memory-based configuration
        loadConfig();
        if (isConfigurable && _ctrl.hasControl()) {
            _ctrl.registerCustomConfig(createConfigPanel);

        }

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED,
            function (e :ControlEvent) :void {
                if (e.name == MEMORY_CONFIG) {
                    loadConfig();
                }
            });
    }

    protected function createConfigPanel () :VampatarConfigPanel
    {
        return new VampatarConfigPanel(
            _curConfig,
            function (newConfig :VampatarConfig) :void {
                saveConfig(newConfig);
                applyConfig(newConfig);
            });
    }

    protected function loadConfig () :void
    {
        var config :VampatarConfig = new VampatarConfig();
        var bytes :ByteArray = _ctrl.getMemory(MEMORY_CONFIG) as ByteArray;
        if (bytes != null) {
            try {
                bytes.position = 0;
                config.fromBytes(bytes);
            } catch (e :Error) {
                log.warning("Error loading VampatarConfig", e);
            }
        }

        applyConfig(config);
    }

    protected function saveConfig (config :VampatarConfig) :void
    {
        _ctrl.setMemory(MEMORY_CONFIG, config.toBytes(),
            function (success :Boolean) :void {
                if (!success) {
                    log.warning("Failed to save VampatarConfig!");
                }
            });
    }

    protected function applyConfig (config :VampatarConfig) :void
    {
        _curConfig = config;
        var allMovies :Array = getAllMovies();
        selectCurConfigFrames(allMovies);
        applyCurConfigFilters(allMovies);
    }

    protected function selectCurConfigFrames (movies :Array) :void
    {
        //log.info("Selecting frames for " + movies.length + " movies");
        for each (var movie :MovieClip in movies) {
            selectFrames(movie, "topRemix", _curConfig.topNumber);
            selectFrames(movie, "hairRemix", _curConfig.hairNumber);
            selectFrames(movie, "shoesRemix", _curConfig.shoesNumber);
        }
    }

    protected function selectFrames (movie :MovieClip, optionName :String, frameNumber :int) :void
    {
        if (!_configOptions.hasOwnProperty(optionName) || !(_configOptions[optionName] is Array)) {
            log.warning("missing config options", "optionName", optionName);
            return;
        }

        for each (var path :Array in _configOptions[optionName]) {
            selectFrame(movie, path, frameNumber);
        }
    }

    protected function applyCurConfigFilters (movies :Array) :void
    {
        //log.info("Applying filters to " + movies.length + " movies");

        for each (var movie :MovieClip in movies) {
            recolorElements(movie, "skinRecolor", _curConfig.skinColor);
            recolorElements(movie, "hairRecolor", _curConfig.hairColor);
            recolorElements(movie, "topRecolor", _curConfig.topColor);
            recolorElements(movie, "pantsRecolor", _curConfig.pantsColor);
            recolorElements(movie, "shoesRecolor", _curConfig.shoesColor);
        }
    }

    protected function recolorElements (movie :MovieClip, optionName :String, color :uint) :void
    {
        if (!_configOptions.hasOwnProperty(optionName) || !(_configOptions[optionName] is Array)) {
            log.warning("missing config options", "optionName", optionName);
            return;
        }

        var filter :ColorMatrixFilter = createColorFilter(color);
        for each (var path :Array in _configOptions[optionName]) {
            applyFilter(movie, path, filter);
        }
    }

    override protected function playMovie (movie :MovieClip) :void
    {
        super.playMovie(movie);

        if (movie != null) {
            //log.info("Restarting movies");
            // recursively restart all movies
            restartAllMovies(movie);
            // and reselect our configurations
            selectCurConfigFrames([ movie ]);
        }
    }

    protected static function restartAllMovies (disp :DisplayObjectContainer) :void
    {
        if (disp is MovieClip) {
            (disp as MovieClip).gotoAndPlay(1);
        }

        for (var ii :int = 0; ii < disp.numChildren; ++ii) {
            var child :DisplayObject = disp.getChildAt(ii);
            if (child is DisplayObjectContainer) {
                restartAllMovies(child as DisplayObjectContainer);
            }
        }
    }

    protected static function findChild (movie :MovieClip, childPath :Array) :MovieClip
    {
        var child :MovieClip = movie;
        for each (var pathElt :String in childPath) {
            child = child[pathElt];
            if (child == null) {
                break;
            }
        }

        return child;
    }

    protected static function selectFrame (movie :MovieClip, childPath :Array,
                                           frameNumber :int) :void
    {
        var child :MovieClip = findChild(movie, childPath);
        if (child != null) {
            child.gotoAndStop(frameNumber);
        }
    }

    protected static function applyFilter (movie :MovieClip, childPath :Array,
                                           filter :BitmapFilter) :void
    {
        var child :MovieClip = findChild(movie, childPath);
        if (child != null) {
            child.filters = [ filter ];
        }
    }

    protected static function createColorFilter (color :uint) :ColorMatrixFilter
    {
        return new ColorMatrix().colorize(color).createFilter();
    }

    protected var _curConfig :VampatarConfig;
    protected var _configOptions :Object;

    protected static const MEMORY_CONFIG :String = "VampatarConfig";
}

}
