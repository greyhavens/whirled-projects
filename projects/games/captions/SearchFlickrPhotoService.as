//
// $Id$


package {


import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.util.StringUtil;

/**
 * Allows keyword searching of flickr, falling back to getting the latest photos if
 * the specified keywords return no results.
 */
public class SearchFlickrPhotoService extends LatestFlickrPhotoService
{
    public function setKeywords (str :String, tagsOnly :Boolean = false) :void
    {
        _str = str;
        _tagsOnly = tagsOnly;

        // reset saved search info
        _total = -1;
        _pics.length = 0;
    }

    override public function init () :void
    {
        super.init();

        _flickr.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, handleFlickrSearchResult);
    }

    override protected function doGetPhotos (count :int) :void
    {
        // if we have no search string or our search string is too restrictive,
        // fall back to returning the latest photos
        if (StringUtil.isBlank(_str) || _total == 0) {
            super.doGetPhotos(count);
            return;
        }

        var tagsStr :String = _tagsOnly ? _str : "";
        var textStr :String = _tagsOnly ? "" : _str;

        switch (_total) {
        case -1:
            // get page 1, we'll figure out the total
//            trace("Getting #1 of <unknown>");
            _flickr.photos.search("", tagsStr, "any", textStr, null, null, null, null, -1, "",
                count, 1);
            break;

        default:
            // get a bunch of 1-page results
            count = Math.min(count, _total);
            var picks :Array = [];
            var pick :int;
            for (var ii :int = 0; ii < count; ii++) {
                do {
                    pick = 1 + Math.floor(_total * Math.random());

                } while (picks.indexOf(pick) != -1);
                picks.push(pick);

//                trace("Getting #" + pick + " of " + _total);
                _flickr.photos.search("", tagsStr, "any", textStr, null, null, null, null, -1, "",
                    1, pick);
            }
            break;
        }
    }

    protected function handleFlickrSearchResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            flickrFailure(evt.data.error.errorMessage);
            return;
        }

        var photoList :PagedPhotoList = (evt.data.photos as PagedPhotoList);
        _total = Math.min(photoList.total, FLICKR_MAX_IMAGES_LIMIT);

        if (_total == 0 && _needPhoto) {
            // we NEED a photo!
            doGetPhotos(1);
            return;
        }

//        trace("Got " + photoList.page + " (" + photoList.perPage + ") of " + _total +
//            "  (" + photoList.photos[0].id + ")");

        // otherwise, make size requests on everything we got
        getUrlsAndDispatchToGame(photoList.photos);
    }

    protected var _str :String;

    protected var _tagsOnly :Boolean;

    protected var _total :int;

    /** Flickr will only do search results for up to 4000 images, and then they start
     * repeating even though they report a larger total. */
    protected static const FLICKR_MAX_IMAGES_LIMIT :int = 4000;
}
}
