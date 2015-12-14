//
// $Id$

package {

import com.threerings.util.ValueEvent; 

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

/**
 * A PhotoService that returns that latest uploaded photos from flickr.
 */
public class LatestFlickrPhotoService extends AbstractFlickrPhotoService
{
    override public function init () :void
    {
        super.init();

        _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_RECENT, handleFlickrRecentResult);
    }

    override protected function getFlickrKey () :String
    {
        return "5d29b1d793cc58bc495dda72e979f4af";
    }


    override protected function doGetPhotos (count :int) :void
    {
        _flickr.photos.getRecent("", count, 1);
    }

    /**
     * A photo was returned by flickr, now get the sizing info.
     */
    protected function handleFlickrRecentResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            flickrFailure(evt.data.error.errorMessage);
            return;
        }

        // otherwise, make size requests on everything we got
        getUrlsAndDispatchToGame((evt.data.photos as PagedPhotoList).photos);
    }
}
}
