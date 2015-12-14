package config {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.contrib.ColorMatrix;

public class ConfigBody extends MovieClipBody
{
    public function ConfigBody (ctrl :AvatarControl, media :MovieClip, width :int, height :int = -1)
    {
        super(ctrl, media, width, height);

        // We are configurable only by the player that owns us
        if (_ctrl.hasControl()) {
            _ctrl.registerCustomConfig(createConfigPanel);
        }

        // Load our current config right now, and respond to MEMORY_CHANGED events by
        // reloading it.
        loadConfig();
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED,
            function (e :ControlEvent) :void {
                if (e.name == MEMORY_CONFIG) {
                    loadConfig();
                }
            });
    }

    protected function createConfigPanel () :Sprite
    {
        return new ConfigPanel(
            _curConfigData,
            function (newConfig :ConfigData) :void {
                saveConfig(newConfig);
                applyConfig(newConfig);
            });
    }

    protected function loadConfig () :void
    {
        var configData :ConfigData = new ConfigData();
        configData.fromMemory(_ctrl.getMemory(MEMORY_CONFIG));
        applyConfig(configData);
    }

    protected function saveConfig (configData :ConfigData) :void
    {
        _ctrl.setMemory(MEMORY_CONFIG, configData.toMemory(),
            function (success :Boolean) :void {
                if (!success) {
                    log.warning("Failed to save Config!");
                }
            });
    }

    protected function applyConfig (config :ConfigData) :void
    {
        _curConfigData = config;
        var allMovies :Array = getAllMovies();
        selectCurConfigFrames(allMovies);
        applyCurConfigFilters(allMovies);
    }

    protected function selectCurConfigFrames (movies :Array) :void
    {
        //log.info("Selecting frames for " + movies.length + " movies");

        for each (var movie :MovieClip in movies) {
            // Shirt
            selectFrame(movie, [ "torso", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "neck", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "hips", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "breasts", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "breasts", "skin" ], _curConfigData.topNumber);
            selectFrame(movie, [ "bicepL", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "bicepR", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "bicepL", "skin" ], _curConfigData.topNumber);
            selectFrame(movie, [ "bicepR", "skin" ], _curConfigData.topNumber);
            selectFrame(movie, [ "forearmL", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "forearmR", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "forearmL", "skin" ], _curConfigData.topNumber);
            selectFrame(movie, [ "forearmR", "skin" ], _curConfigData.topNumber);
            selectFrame(movie, [ "handL", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "handR", "shirt" ], _curConfigData.topNumber);
            selectFrame(movie, [ "handL", "skin" ], _curConfigData.topNumber);
            selectFrame(movie, [ "handR", "skin" ], _curConfigData.topNumber);
        }
    }

    protected function applyCurConfigFilters (movies :Array) :void
    {
        //log.info("Applying filters to " + movies.length + " movies");

        var skinFilter :ColorMatrixFilter = createColorFilter(_curConfigData.skinColor);
        var shirtFilter :ColorMatrixFilter = createColorFilter(_curConfigData.topColor);
        var pantsFilter :ColorMatrixFilter = createColorFilter(_curConfigData.pantsColor);

        for each (var movie :MovieClip in movies) {
            // Skin color
            applyFilter(movie, [ "head", "head" ], skinFilter);
            applyFilter(movie, [ "head", "ear" ], skinFilter);
            applyFilter(movie, [ "neck", "skin" ], skinFilter);
            applyFilter(movie, [ "bicepL", "skin" ], skinFilter);
            applyFilter(movie, [ "bicepR", "skin" ], skinFilter);
            applyFilter(movie, [ "forearmL", "skin" ], skinFilter);
            applyFilter(movie, [ "forearmR", "skin" ], skinFilter);
            applyFilter(movie, [ "handL", "skin" ], skinFilter);
            applyFilter(movie, [ "handR", "skin" ], skinFilter);
            applyFilter(movie, [ "breasts", "skin" ], skinFilter);
            applyFilter(movie, [ "torso", "skin" ], skinFilter);
            applyFilter(movie, [ "hips", "skin" ], skinFilter);
            applyFilter(movie, [ "calfL", "skin" ], skinFilter);
            applyFilter(movie, [ "calfR", "skin" ], skinFilter);
            applyFilter(movie, [ "footL", "skin" ], skinFilter);
            applyFilter(movie, [ "footR", "skin" ], skinFilter);

            // Shirt color
            applyFilter(movie, [ "neck", "shirt", ], shirtFilter);
            applyFilter(movie, [ "bicepL", "shirt", ], shirtFilter);
            applyFilter(movie, [ "bicepR", "shirt", ], shirtFilter);
            applyFilter(movie, [ "forearmL", "shirt", ], shirtFilter);
            applyFilter(movie, [ "forearmR", "shirt", ], shirtFilter);
            applyFilter(movie, [ "handL", "shirt", ], shirtFilter);
            applyFilter(movie, [ "handR", "shirt", ], shirtFilter);
            applyFilter(movie, [ "breasts", "shirt", ], shirtFilter);
            applyFilter(movie, [ "torso", "shirt", ], shirtFilter);
            applyFilter(movie, [ "hips", "shirt", ], shirtFilter);

            // Pants color
            applyFilter(movie, [ "hips", "pants", ], pantsFilter);
            applyFilter(movie, [ "thighL", "pants", ], pantsFilter);
            applyFilter(movie, [ "thighR", "pants", ], pantsFilter);
            applyFilter(movie, [ "calfL", "pants", ], pantsFilter);
            applyFilter(movie, [ "calfR", "pants", ], pantsFilter);
            applyFilter(movie, [ "footL", "pants", ], pantsFilter);
            applyFilter(movie, [ "footR", "pants", ], pantsFilter);
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

    protected var _curConfigData :ConfigData;

    protected static const MEMORY_CONFIG :String = "Config";
}

}
