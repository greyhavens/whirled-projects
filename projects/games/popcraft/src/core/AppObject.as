package core {
	
import com.threerings.util.Assert;

import core.tasks.TaskContainer;

import flash.display.Sprite;

public class AppObject extends Sprite
{
	public function get objectName () :String
	{
		return "";
	}
	
	public function get objectRoles () :Array
	{
		return new Array();
	}
	
	/** Removes the AppObject from its parent mode. */
	public function removeSelf() :void
	{
		Assert.isTrue(null != _parentMode);
		_parentMode.removeObject(this);
	}
	
	/** Adds a task to this AppObject. */
	public function addTask (task :ObjectTask) :void
	{
		Assert.isTrue(null != task);
		_anonymousTasks.addTask(task);
	}
	
	/** Returns true if the AppObject has any tasks. */
	public function hasTasks () :Boolean
	{
		return _anonymousTasks.hasTasks();
	}
	
	/** Called once per update tick */
	protected function update (dt :Number) :void
	{
	}
	
	internal function updateInternal(dt :Number) :void
	{
		_anonymousTasks.update(dt, this);
		update(dt);
	}
	
	protected var _anonymousTasks :TaskContainer;
	
	// these variables are managed by AppMode and shouldn't be modified
	internal var _parentMode :AppMode;
	internal var _modeIndex :int = -1;
	
}

}