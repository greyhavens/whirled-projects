== Creating an Avatar with the FAT ==

Creating an avatar that works with Whirled is easy when you use this avatar
handling code.

=== Setting up Your Project ===

Create a new project in the Flash Authoring Tool do the following.

Add two paths to your project path:

whirled\src\as
whirled\projects\avatars\uravatar\src

Create a scene named "main" and place the following ActionScript code in it:

------------------------- ActionScript Code -------------------------
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import com.whirled.AvatarControl;

if (_ctrl == null) {
    _ctrl = new AvatarControl(this);
    _body = new Body(_ctrl, this);
    addEventListener(Event.UNLOAD, handleUnload);
    function handleUnload (... ignored) :void {
        _body.shutdown();
    }
}

var _ctrl :AvatarControl;
var _body :Body;
----------------------- End ActionScript Code -----------------------

=== States ===

States are modes that the avatar can be in which persist as the avatar moves
between scenes. The avatar starts in the "Default" state and the user can
select other states from a menu on their avatar (for example, "Dancing", or
"Smiling", or anything you like).

To create a state for your avatar, simply create a scene with names that match
the following pattern:

state_Default
state_Smiling
state_Dancing

Normally an avatar will spend most of their time in the:

state_Default

animation which should show the avatar in its natural resting pose.

Avatars can also walk around, so you will want to create a walking animation
for them:

state_Default_walking

You can also create custom walking animations to use when the avatar is in a
particular state, for example:

state_Dancing_walking

If an avatar is in a state that does not have a custom walking animation, it
will use state_Default_walking so be sure to always have a default walking
animation.

Avatars can also "go to sleep" which happens when the player goes away from
their keyboard for a while. You can create a custom animation for their
sleeping state like so:

state_Default_sleeping

As with walking, custom states can have custom sleeping animations if you like:

state_Smiling_sleeping

Avatars can also have transitions to and from walking and sleeping. As the
walking and sleeping animations will be looped, it can be useful to have
animations that ease the avatar into and out of the walking or sleeping
loop. These are named as follows:

state_Default_towalking
state_Default_fromwalking

state_Default_tosleeping
state_Default_fromsleeping

If you have a custom walking or sleeping animation for any other state, those
too can have ease-in and ease-out animations, for example:

state_Dancing_towalking
state_Dancing_fromwalking

=== Actions ===

Actions are one-time animations that play immediately for everyone in the room
and then the avatar reverts back to their current state.

TBD

=== Transitions ===

TBD

=== Random Scene Selection ===

TBD
