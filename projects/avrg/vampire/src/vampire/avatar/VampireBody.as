package vampire.avatar {

import com.threerings.util.HashMap;
import com.whirled.AvatarControl;
import com.whirled.DataPack;
import com.whirled.contrib.ColorMatrix;

import flash.display.MovieClip;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;

public class VampireBody extends NewBody
{
    public function VampireBody (ctrl :AvatarControl, media :MovieClip, width :int,
                                 height :int = -1)
    {
        super(ctrl, media, width, height);

        _skintones = new HashMap();
        _skintones.put("lighter", 0xDEEFF5);
        _skintones.put("light", 0xD0DFFD);
        _skintones.put("cool", 0xC2EDD3);
        _skintones.put("warm", 0xE1C2ED);
        _skintones.put("dark", 0xC7B4EB);
        _skintones.put("darker", 0xCCCCCC);

        DataPack.load(_ctrl.getDefaultDataPack(), onDataPackLoaded);
    }

    protected function onDataPackLoaded (result :Object) :void
    {
        if (!(result is DataPack)) {
            log.warning("Unexpected DataPack data", "result", result);

        } else {
            var cm :ColorMatrix = new ColorMatrix();
            cm.colorize(result.getColor("SkinColor"));
            _skinFilter = cm.createFilter();
            cm.reset().colorize(result.getColor("HairColor"));
            _hairFilter = cm.createFilter();
            cm.reset().colorize(result.getColor("ShirtColor"));
            _shirtFilter = cm.createFilter();
            cm.reset().colorize(result.getColor("PantsColor"));
            _pantsFilter = cm.createFilter();
            cm.reset().colorize(result.getColor("ShoesColor"));
            _shoesFilter = cm.createFilter();

            _shirtNumber = (result as DataPack).getInt("Shirt");
            _hairNumber = (result as DataPack).getInt("Hair");
            _shoesNumber = (result as DataPack).getInt("Shoes");

            log.info("Got pack",
                     "shirtNumber", _shirtNumber,
                     "hairNumber", _hairNumber,
                     "shoesNumber", _shoesNumber);

            var skinSelection :String = (result as DataPack).getString("SkinColorChooser");
            if (_skintones.containsKey(skinSelection)) {
                _skinColorVampire = _skintones.get(skinSelection);
                cm.reset().colorize(_skinColorVampire);
                _skinFilter = cm.createFilter();

            } else {
                log.info("Couldn't get skinSelection", "val", skinSelection);
            }
        }

        // apply the configuration to each registered movie in the Vampatar
        for each (var movie :MovieClip in getAllMovies()) {
            applyConfiguration(movie);
        }
    }

    protected function applyConfiguration (movie :MovieClip) :void
    {
        selectFrame(movie, [ "torso", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "breasts", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "breasts", "breasts" ], _shirtNumber);
        selectFrame(movie, [ "bicepL", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "bicepR", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "bicepL", "bicepL" ], _shirtNumber);
        selectFrame(movie, [ "bicepR", "bicepR" ], _shirtNumber);
        selectFrame(movie, [ "forearmL", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "forearmR", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "forearmL", "forearmL" ], _shirtNumber);
        selectFrame(movie, [ "forearmR", "forearmR" ], _shirtNumber);
        selectFrame(movie, [ "handL", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "handR", "shirt" ], _shirtNumber);
        selectFrame(movie, [ "handL", "handL" ], _shirtNumber);
        selectFrame(movie, [ "handR", "handR" ], _shirtNumber);

        selectFrame(movie, [ "head", "scalp", "scalp" ], _hairNumber);
        selectFrame(movie, [ "bangs", "bangs" ], _hairNumber);
        selectFrame(movie, [ "hairL", "hairL" ], _hairNumber);
        selectFrame(movie, [ "hairR", "hairR" ], _hairNumber);
        selectFrame(movie, [ "hair", "hair" ], _hairNumber);
        selectFrame(movie, [ "hairTips", "hairTips" ], _hairNumber);

        selectFrame(movie, [ "footL", "shoes" ], _shoesNumber);
        selectFrame(movie, [ "footR", "shoes" ], _shoesNumber);
        selectFrame(movie, [ "footL", "foot" ], _shoesNumber);
        selectFrame(movie, [ "footR", "foot" ], _shoesNumber);
        selectFrame(movie, [ "calfL", "shoes" ], _shoesNumber);
        selectFrame(movie, [ "calfR", "shoes" ], _shoesNumber);

        if (_skinFilter) {
            applyFilter(movie, [ "head", "head" ], _skinFilter);
            applyFilter(movie, [ "head", "ear" ], _skinFilter);
            applyFilter(movie, [ "neck", "neck" ], _skinFilter);
            applyFilter(movie, [ "bicepL", "bicepL" ], _skinFilter);
            applyFilter(movie, [ "bicepR", "bicepR" ], _skinFilter);
            applyFilter(movie, [ "forearmL", "forearmL" ], _skinFilter);
            applyFilter(movie, [ "forearmR", "forearmR" ], _skinFilter);
            applyFilter(movie, [ "handL", "handL" ], _skinFilter);
            applyFilter(movie, [ "handR", "handR" ], _skinFilter);
            applyFilter(movie, [ "breasts", "breasts" ], _skinFilter);
            applyFilter(movie, [ "torso", "torso" ], _skinFilter);
            applyFilter(movie, [ "hips", "hips" ], _skinFilter);
            applyFilter(movie, [ "calfL", "calfL" ], _skinFilter);
            applyFilter(movie, [ "calfR", "calfR" ], _skinFilter);
            applyFilter(movie, [ "footL", "foot" ], _skinFilter);
            applyFilter(movie, [ "footR", "foot" ], _skinFilter);
        }

        if (_hairFilter) {
            applyFilter(movie, [ "head", "scalp", "scalp", ], _hairFilter);
            applyFilter(movie, [ "head", "eyebrows", ], _hairFilter);
            applyFilter(movie, [ "hairTips", "hairTips", ], _hairFilter);
            applyFilter(movie, [ "bangs", "bangs", ], _hairFilter);
            applyFilter(movie, [ "hairL", "hairL", ], _hairFilter);
            applyFilter(movie, [ "hairR", "hairR", ], _hairFilter);
            applyFilter(movie, [ "hair", "hair", ], _hairFilter);
        }

        if (_shirtFilter) {
            applyFilter(movie, [ "neck", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "bicepL", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "bicepR", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "forearmL", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "forearmR", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "handL", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "handR", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "breasts", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "torso", "shirt", ], _shirtFilter);
            applyFilter(movie, [ "hips", "shirt", ], _shirtFilter);
        }

        if (_pantsFilter) {
            applyFilter(movie, [ "hips", "pants", ], _pantsFilter);
            applyFilter(movie, [ "thighL", "pants", ], _pantsFilter);
            applyFilter(movie, [ "thighR", "pants", ], _pantsFilter);
            applyFilter(movie, [ "calfL", "pants", ], _pantsFilter);
            applyFilter(movie, [ "calfR", "pants", ], _pantsFilter);
            applyFilter(movie, [ "footL", "pants", ], _pantsFilter);
            applyFilter(movie, [ "footR", "pants", ], _pantsFilter);
        }

        if (_shoesFilter) {
            applyFilter(movie, [ "calfL", "shoes", ], _shoesFilter);
            applyFilter(movie, [ "calfR", "shoes", ], _shoesFilter);
            applyFilter(movie, [ "footL", "shoes", ], _shoesFilter);
            applyFilter(movie, [ "footR", "shoes", ], _shoesFilter);
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

    protected static function selectFrame (movie :MovieClip, childPath :Array, frameNumber :int) :void
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

    protected var _skinColorVampire :int;
    protected var _shirtNumber:int = 1;
    protected var _hairNumber:int = 2;
    protected var _shoesNumber:int = 2;
    protected var _skinFilter:ColorMatrixFilter;
    protected var _hairFilter:ColorMatrixFilter;
    protected var _shirtFilter:ColorMatrixFilter;
    protected var _pantsFilter:ColorMatrixFilter;
    protected var _shoesFilter:ColorMatrixFilter;
    protected var _skintones :HashMap;
}

}
