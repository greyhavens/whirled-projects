package vampire.avatar {

import com.threerings.flash.ColorUtil;
import com.threerings.util.ArrayUtil;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.contrib.ColorMatrix;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.utils.ByteArray;

public class VampireBody extends VampireBodyBase
{
    public static const UPSELL :int = 0;
    public static const CONFIGURABLE :int = 1;

    public function VampireBody (ctrl :AvatarControl,
                                 media :MovieClip,
                                 configPanelType :int,
                                 configParams :ConfigParams,
                                 upsellItemId :int,
                                 width :int, height :int = -1)
    {
        super(ctrl, media, width, height);

        _configPanelType = configPanelType;
        _configParams = configParams;

        _upsellItemId = upsellItemId;

        if (_ctrl.hasControl()) {
            _ctrl.registerCustomConfig(createConfigPanel);
        }

        loadConfig();
        //_playerLevel = _ctrl.getMemory(MEMORY_PLAYER_LEVEL) as int;

        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED,
            function (e :ControlEvent) :void {
                if (e.name == MEMORY_CONFIG) {
                    loadConfig();
                } /*else if (e.name == MEMORY_PLAYER_LEVEL) {
                    _playerLevel = _ctrl.getMemory(MEMORY_PLAYER_LEVEL) as int;
                }*/
            });

        // Any state with "feeding" or "bared" in its name should not have its
        // facial components configured with selectCurConfigFrames().
        for each (var movie :MovieClip in getAllMovies()) {
            var movieName :String = getMovieName(movie).toLowerCase();
            if (movieName.indexOf("feeding") >= 0 || movieName.indexOf("bared") >= 0) {
                _nonFaceConfigurableMovies.push(movie);
            }
        }
    }

    /*override protected function setPlayerLevel (newLevel :int) :void
    {
        super.setPlayerLevel(newLevel);
        saveMemory(MEMORY_PLAYER_LEVEL, newLevel);
    }*/

    protected function createConfigPanel () :Sprite
    {
        switch (_configPanelType) {
        case CONFIGURABLE:
            return new VampatarConfigPanel(
                _playerLevel, _configParams, _curConfig,
                function (newConfig :VampatarConfig) :void {
                    saveConfig(newConfig);
                    applyConfig(newConfig);
                });

        case UPSELL:
            return new VampatarUpsellPanel(_ctrl, _upsellItemId);
        }

        return null;
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
        saveMemory(MEMORY_CONFIG, config.toBytes());
    }

    protected function saveMemory (name :String, value :Object) :void
    {
        _ctrl.setMemory(name, value, function (success :Boolean) :void {
            if (!success) {
                log.warning("Failed to save Vampatar memory!", "name", name);
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

        var shoeType :int = _configParams.shoeTypes[_curConfig.shoesNumber];

        for each (var movie :MovieClip in movies) {
            // Shirt
            selectFrame(movie, [ "torso", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "neck", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "hips", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "breasts", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "breasts", "skin" ], _curConfig.topNumber);
            selectFrame(movie, [ "bicepL", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "bicepR", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "bicepL", "skin" ], _curConfig.topNumber);
            selectFrame(movie, [ "bicepR", "skin" ], _curConfig.topNumber);
            selectFrame(movie, [ "forearmL", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "forearmR", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "forearmL", "skin" ], _curConfig.topNumber);
            selectFrame(movie, [ "forearmR", "skin" ], _curConfig.topNumber);
            selectFrame(movie, [ "handL", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "handR", "shirt" ], _curConfig.topNumber);
            selectFrame(movie, [ "handL", "skin" ], _curConfig.topNumber);
            selectFrame(movie, [ "handR", "skin" ], _curConfig.topNumber);

            // Hair
            selectFrame(movie, [ "head", "scalp", "scalp" ], _curConfig.hairNumber);
            selectFrame(movie, [ "bangs", "bangs" ], _curConfig.hairNumber);
            selectFrame(movie, [ "hairL", "hairL" ], _curConfig.hairNumber);
            selectFrame(movie, [ "hairR", "hairR" ], _curConfig.hairNumber);
            selectFrame(movie, [ "hair", "hair" ], _curConfig.hairNumber);
            selectFrame(movie, [ "hairTips", "hairTips" ], _curConfig.hairNumber);

            // Shoes
            selectFrame(movie, [ "footL", "shoes" ], _curConfig.shoesNumber);
            selectFrame(movie, [ "footR", "shoes" ], _curConfig.shoesNumber);
            selectFrame(movie, [ "footL", "skin" ], _curConfig.shoesNumber);
            selectFrame(movie, [ "footR", "skin" ], _curConfig.shoesNumber);
            selectFrame(movie, [ "calfL", "shoes" ], _curConfig.shoesNumber);
            selectFrame(movie, [ "calfR", "shoes" ], _curConfig.shoesNumber);

            // Pants
            // Pants have two different versions - over and under - that we
            // show depending on the type of shoes that the avatar is wearing.
            // Avatars wearing Boots use the under-pants; avatars wearing Normal shoes
            // use the over-pants
            //selectPantsForShoes(movie, [ "example", "example" ], _curConfig.pantsNumber, shoeType);
            //selectPantsForBoots(movie, [ "example", "example" ], _curConfig.pantsNumber, shoeType);

            // Face
            if (!ArrayUtil.contains(_nonFaceConfigurableMovies, movie)) {
                // Eyes
                selectFrame(movie, [ "head", "eyes" ], _curConfig.eyesNumber);
                // Brows
                selectFrame(movie, [ "head", "eyebrows" ], _curConfig.browsNumber);
                // Mouth
                selectFrame(movie, [ "head", "mouth" ], _curConfig.mouthNumber);
            }
        }
    }

    protected function applyCurConfigFilters (movies :Array) :void
    {
        //log.info("Applying filters to " + movies.length + " movies");

        var skinFilter :ColorMatrixFilter = createColorFilter(_curConfig.skinColor);
        var hairFilter :ColorMatrixFilter = createColorFilter(_curConfig.hairColor);
        var shirtFilter :ColorMatrixFilter = createColorFilter(_curConfig.topColor);
        var pantsFilter :ColorMatrixFilter = createColorFilter(_curConfig.pantsColor);
        var shoesFilter :ColorMatrixFilter = createColorFilter(_curConfig.shoesColor);
        var eyesFilter :ColorMatrixFilter = createHueFilter(ColorUtil.getHue(_curConfig.eyesColor));

        var hairFilter2 :ColorMatrixFilter = createColorFilter(_curConfig.hairColor2);
        var shirtFilter2 :ColorMatrixFilter = createColorFilter(_curConfig.topColor2);
        var pantsFilter2 :ColorMatrixFilter = createColorFilter(_curConfig.pantsColor2);
        var shoesFilter2 :ColorMatrixFilter = createColorFilter(_curConfig.shoesColor2);

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

            // Hair color
            applyFilter(movie, [ "head", "scalp", "scalp", ], hairFilter);
            applyFilter(movie, [ "head", "eyebrows", ], hairFilter);
            applyFilter(movie, [ "hairTips", "hairTips", ], hairFilter);
            applyFilter(movie, [ "bangs", "bangs", ], hairFilter);
            applyFilter(movie, [ "hairL", "hairL", ], hairFilter);
            applyFilter(movie, [ "hairR", "hairR", ], hairFilter);
            applyFilter(movie, [ "hair", "hair", ], hairFilter);

            // Hair color 2
            //applyFilter(movie, [ "example", "example" ], hairFilter2);

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

            // Shirt color 2
            //applyFilter(movie, [ "example", "example" ], shirtFilter2);

            // Pants color
            applyFilter(movie, [ "hips", "pants", ], pantsFilter);
            applyFilter(movie, [ "thighL", "pants", ], pantsFilter);
            applyFilter(movie, [ "thighR", "pants", ], pantsFilter);
            applyFilter(movie, [ "calfL", "pants", ], pantsFilter);
            applyFilter(movie, [ "calfR", "pants", ], pantsFilter);
            applyFilter(movie, [ "footL", "pants", ], pantsFilter);
            applyFilter(movie, [ "footR", "pants", ], pantsFilter);

            // Pants color 2
            //applyFilter(movie, [ "example", "example" ], pantsFilter2);

            // Shoes color
            applyFilter(movie, [ "calfL", "shoes", ], shoesFilter);
            applyFilter(movie, [ "calfR", "shoes", ], shoesFilter);
            applyFilter(movie, [ "footL", "shoes", ], shoesFilter);
            applyFilter(movie, [ "footR", "shoes", ], shoesFilter);

            // Shoes color 2
            //applyFilter(movie, [ "example", "example" ], shoesFilter2);

            // Eyes color
            applyFilter(movie, [ "head", "eyes", ], eyesFilter);
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
                                           frameNumber :int, visible :Boolean = true) :void
    {
        var child :MovieClip = findChild(movie, childPath);
        if (child != null) {
            if (visible) {
                child.visible = true;
                child.gotoAndStop(frameNumber);
            } else {
                child.visible = false;
            }
        }
    }

    protected static function selectPantsForShoes (movie :MovieClip, childPath :Array,
                                                 frameNumber :int, shoesType :int) :void
    {
        selectFrame(movie, childPath, frameNumber, shoesType == ConfigParams.SHOE_NORMAL);
    }

    protected static function selectPantsForBoot (movie :MovieClip, childPath :Array,
                                                 frameNumber :int, shoesType :int) :void
    {
        selectFrame(movie, childPath, frameNumber, shoesType == ConfigParams.SHOE_BOOT);
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

    protected static function createHueFilter (angle :Number) :ColorMatrixFilter
    {
        return new ColorMatrix().adjustHue(angle).createFilter();
    }

    protected var _curConfig :VampatarConfig;
    protected var _configPanelType :int;
    protected var _configParams :ConfigParams;
    protected var _upsellItemId :int;
    protected var _nonFaceConfigurableMovies :Array = [];

    protected static const MEMORY_CONFIG :String = "VampatarConfig";
    //protected static const MEMORY_PLAYER_LEVEL :String = "PlayerLevel";
}

}
