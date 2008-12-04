//
// $Id$

package locksmith {

import flash.display.Sprite;

import locksmith.client.ClientLocksmithController;

[SWF(width="700", heigh="500")]
public class Locksmith extends Sprite
{
    public function Locksmith ()
    {
        _control = new LocksmithController(this);
    }

    protected var _control :LocksmithController;
}
}
