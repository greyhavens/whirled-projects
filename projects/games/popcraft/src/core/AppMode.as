package core {
	
import com.threerings.util.Assert;
	
public class AppMode
{
	public function AppMode ()
	{
		_objects = new Array(1);
		
		_freeIndexes = new Array();
		_freeIndexes.push(0);
	}
	
	/** Adds an AppObject to the mode. The AppObject must not be owned by another mode. */
	public function addObject (obj :AppObject) :void
	{
		Assert.isTrue(null != obj);
		Assert.isTrue(null == obj._parentMode);
		
		// if there's no free slot in our objects array,
		// make a new one
		if(_freeIndexes.length == 0) {
			_freeIndexes.push(_objects.length);
			_objects.push(null);
		}
		
		Assert.isTrue(_freeIndexes.length > 0);
		var index :int = _freeIndexes.pop();
		Assert.isTrue(index >= 0 && index < _objects.length);
		Assert.isTrue(_objects[index] == null);
		
		_objects[index] = obj;
		
		obj._parentMode = this;
		obj._modeIndex = index;
		
		// does the object have a name?
		// TODO: implement name and role functionality
	}
	
	/** Removes an AppObject from the mode. The AppObject must be owned by this mode. */
	public function removeObject(obj :AppObject) :void
	{
		// lots o' sanity checks
		Assert.isTrue(null != obj);
		Assert.isTrue(this == obj._parentMode);
		Assert.isTrue(obj._modeIndex >= 0 && obj._modeIndex < _objects.length);
		Assert.isTrue(_objects[obj._modeIndex] == obj);
		
		_objects[obj._modeIndex] = null;
		_freeIndexes.unshift(obj._modeIndex); // we have a new free index
		
		obj._parentMode = null;
		obj._modeIndex = -1;
	}
	
	/** Called once per update tick. Updates all objects in the mode. */
	public function update (dt :Number) :void
	{
		// update all objects in this mode
		// there may be holes in the array, so check each object against null
		for each(var obj:* in _objects) {
			if(null != obj) {
				(obj as AppObject).updateInternal(dt);
			}
		}
	}
	
	/** Called when the mode is added to the mode stack */
	public function setup () :void
	{
	}
	
	/** Called when the mode is removed from the mode stack */
	public function destroy () :void
	{
	}
	
	/** Called when the mode becomes active on the mode stack */
	public function enter () :void
	{
	}
	
	/** Called when the mode becomes inactive on the mode stack */
	public function exit () :void
	{
	}
	
	protected var _objects :Array;
	protected var _namedObjects :Object;
	protected var _roleObjects :Object;
	protected var _freeIndexes :Array;
}

}