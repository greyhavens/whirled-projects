package vampire.avatar {

import com.threerings.util.HashMap;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;
import com.whirled.contrib.ColorMatrix;

import flash.display.MovieClip;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.utils.ByteArray;

public class VampireBody extends NewBody
{
    public function VampireBody (ctrl :AvatarControl, media :MovieClip, isConfigurable :Boolean,
                                 width :int, height :int = -1)
    {
        super(ctrl, media, width, height);

        _skintones = new HashMap();
        _skintones.put("lighter", 0xDEEFF5);
        _skintones.put("light", 0xD0DFFD);
        _skintones.put("cool", 0xC2EDD3);
        _skintones.put("warm", 0xE1C2ED);
        _skintones.put("dark", 0xC7B4EB);
        _skintones.put("darker", 0xCCCCCC);

        // Remix-based configuration
        //DataPack.load(_ctrl.getDefaultDataPack(), onDataPackLoaded);

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
                _curConfig = newConfig;
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

        _curConfig = config;
        applyConfig(_curConfig);
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

    protected function onDataPackLoaded (result :Object) :void
    {
        var config :VampatarConfig = new VampatarConfig();

        if (!(result is DataPack)) {
            log.warning("Unexpected DataPack data", "result", result);

        } else {
            var pack :DataPack = result as DataPack;

            var skinSelection :String = pack.getString("SkinColorChooser");
            if (_skintones.containsKey(skinSelection)) {
                config.skinColor = _skintones.get(skinSelection);
            } else {
                config.skinColor = pack.getColor("SkinColor");
            }

            config.hairColor = pack.getColor("HairColor");
            config.shirtColor = pack.getColor("ShirtColor");
            config.pantsColor = pack.getColor("PantsColor");
            config.shoesColor = pack.getColor("ShoesColor");
            config.shirtNumber = pack.getInt("Shirt");
            config.hairNumber = pack.getInt("Hair");
            config.shoesNumber = pack.getInt("Shoes");
        }

        applyConfig(config);
    }

    protected function applyConfig (config :VampatarConfig) :void
    {
        var skinFilter :ColorMatrixFilter = createColorFilter(config.skinColor);
        var hairFilter :ColorMatrixFilter = createColorFilter(config.hairColor);
        var shirtFilter :ColorMatrixFilter = createColorFilter(config.shirtColor);
        var pantsFilter :ColorMatrixFilter = createColorFilter(config.pantsColor);
        var shoesFilter :ColorMatrixFilter = createColorFilter(config.shoesColor);

        for each (var movie :MovieClip in getAllMovies()) {
            // Shirt
            selectFrame(movie, [ "torso", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "neck", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "hips", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "breasts", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "breasts", "breasts" ], config.shirtNumber);
            selectFrame(movie, [ "bicepL", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "bicepR", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "bicepL", "bicepL" ], config.shirtNumber);
            selectFrame(movie, [ "bicepR", "bicepR" ], config.shirtNumber);
            selectFrame(movie, [ "forearmL", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "forearmR", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "forearmL", "forearmL" ], config.shirtNumber);
            selectFrame(movie, [ "forearmR", "forearmR" ], config.shirtNumber);
            selectFrame(movie, [ "handL", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "handR", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "handL", "handL" ], config.shirtNumber);
            selectFrame(movie, [ "handR", "handR" ], config.shirtNumber);

            // Hair
            selectFrame(movie, [ "head", "scalp", "scalp" ], config.hairNumber);
            selectFrame(movie, [ "bangs", "bangs" ], config.hairNumber);
            selectFrame(movie, [ "hairL", "hairL" ], config.hairNumber);
            selectFrame(movie, [ "hairR", "hairR" ], config.hairNumber);
            selectFrame(movie, [ "hair", "hair" ], config.hairNumber);
            selectFrame(movie, [ "hairTips", "hairTips" ], config.hairNumber);

            // Shoes
            selectFrame(movie, [ "footL", "shoes" ], config.shoesNumber);
            selectFrame(movie, [ "footR", "shoes" ], config.shoesNumber);
            selectFrame(movie, [ "footL", "foot" ], config.shoesNumber);
            selectFrame(movie, [ "footR", "foot" ], config.shoesNumber);
            selectFrame(movie, [ "calfL", "shoes" ], config.shoesNumber);
            selectFrame(movie, [ "calfR", "shoes" ], config.shoesNumber);

            // Skin color
            applyFilter(movie, [ "head", "head" ], skinFilter);
            applyFilter(movie, [ "head", "ear" ], skinFilter);
            applyFilter(movie, [ "neck", "neck" ], skinFilter);
            applyFilter(movie, [ "bicepL", "bicepL" ], skinFilter);
            applyFilter(movie, [ "bicepR", "bicepR" ], skinFilter);
            applyFilter(movie, [ "forearmL", "forearmL" ], skinFilter);
            applyFilter(movie, [ "forearmR", "forearmR" ], skinFilter);
            applyFilter(movie, [ "handL", "handL" ], skinFilter);
            applyFilter(movie, [ "handR", "handR" ], skinFilter);
            applyFilter(movie, [ "breasts", "breasts" ], skinFilter);
            applyFilter(movie, [ "torso", "torso" ], skinFilter);
            applyFilter(movie, [ "hips", "hips" ], skinFilter);
            applyFilter(movie, [ "calfL", "calfL" ], skinFilter);
            applyFilter(movie, [ "calfR", "calfR" ], skinFilter);
            applyFilter(movie, [ "footL", "foot" ], skinFilter);
            applyFilter(movie, [ "footR", "foot" ], skinFilter);

            // Hair color
            applyFilter(movie, [ "head", "scalp", "scalp", ], hairFilter);
            applyFilter(movie, [ "head", "eyebrows", ], hairFilter);
            applyFilter(movie, [ "hairTips", "hairTips", ], hairFilter);
            applyFilter(movie, [ "bangs", "bangs", ], hairFilter);
            applyFilter(movie, [ "hairL", "hairL", ], hairFilter);
            applyFilter(movie, [ "hairR", "hairR", ], hairFilter);
            applyFilter(movie, [ "hair", "hair", ], hairFilter);

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

            // Shoes color
            applyFilter(movie, [ "calfL", "shoes", ], shoesFilter);
            applyFilter(movie, [ "calfR", "shoes", ], shoesFilter);
            applyFilter(movie, [ "footL", "shoes", ], shoesFilter);
            applyFilter(movie, [ "footR", "shoes", ], shoesFilter);
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

    protected var _skintones :HashMap;
    protected var _curConfig :VampatarConfig;

    protected static const MEMORY_CONFIG :String = "VampatarConfig";
}

}
