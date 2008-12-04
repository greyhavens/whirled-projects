//
// $Id$

package locksmith {

import locksmith.events.EventManagerFactory;
import locksmith.model.LocksmithModel;

public class LocksmithView extends LocksmithSprite
{
    public function LocksmithView (model :LocksmithModel, eventMgrFactory :EventManagerFactory)
    {
        super(eventMgrFactory.createManager());
        _model = model;
        _eventMgrFactory = eventMgrFactory;
    }

    protected _model :LocksmithModel;
    protected _eventMgrFactory :EventManagerFactory;
}
}
