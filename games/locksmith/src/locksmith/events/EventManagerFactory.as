// 
// $Id$

package locksmith.events {

import com.whirled.contrib.EventHandlerManager;

public interface EventManagerFactory 
{
    function createEventManager () :EventHandlerManager;
}
}
