package utils
{
import starling.display.DisplayObject;

public class ObjectsPool
{
	public var items:Array;
	public var counter:int;

	public function ObjectsPool(arrayOfObjects:Array)
	{
		counter = arrayOfObjects.length;
		items = arrayOfObjects;
	}

	public function getObject():DisplayObject
	{
		if(counter > 0)
			return items[--counter];
		else
			throw new Error("You exhausted the pool!");
	}

	public function returnObject(s:DisplayObject):void
	{
		items[counter++] = s;
	}

	public function destroy():void
	{
		items = null;
	}
}
}