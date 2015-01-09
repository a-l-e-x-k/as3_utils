package utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Trying to remove event dispatching duties from application.
	 */
	public class EventHub
	{
		private static var _instance:EventDispatcher = new EventDispatcher();


		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_instance.addEventListener(type, listener,useCapture,priority, useWeakReference);
		}

		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_instance.removeEventListener(type, listener, useCapture);
		}

		public static function hasEventListener(type:String):Boolean
		{
			return _instance.hasEventListener(type);
		}

		public static function dispatch(event:Event):Boolean
		{
			return _instance.dispatchEvent(event);
		}
	}
}
