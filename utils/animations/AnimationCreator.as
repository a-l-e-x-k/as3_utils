/**
 * Author: Alexey
 * Date: 8/31/12
 * Time: 10:21 PM
 */
package utils.animations
{
	import events.RequestEvent;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;

	import starling.display.Image;
	import starling.textures.Texture;

	import utils.Misc;

	public class AnimationCreator extends MovieClip
	{
		protected var _objectsNeeded:int = 0; //max amout of objects which will be used in the game
		protected var _framesTotal:int = 0;
		protected var _frameCount:int = 0;
		private var _frames:Vector.<Texture> = new Vector.<Texture>();

		public function AnimationCreator(framesTotal:int, objectsNeeded:int, initDelay:int)
		{
			_framesTotal = framesTotal;
			_objectsNeeded = objectsNeeded;
			Misc.delayCallback(addEnterFrameListener, initDelay);  //so that all animation creators do not start at the same time (more stable recording)
		}

		private function addEnterFrameListener():void
		{
			init();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event:Event):void
		{
			doSnapshot();
		}

		protected function finish():void
		{
			_frameCount = 0;
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			dispatchEvent(new RequestEvent(RequestEvent.IMREADY, {items:getObjects()}));
		}

		private function getObjects():Array
		{
			var objects:Array = [];
			for (var i:int = 0; i < _objectsNeeded; i++)
			{
				objects.push(createObject());
			}
			return objects;
		}

		/**
		 * Each anim clip will be referencing the same frame object (Image).
		 * Thus, per se only memory for 1 "MovieClip" is created.
		 * @param bitmap
		 */
		protected function addFrame(bitmap:Bitmap):void
		{
			var texture:Texture = Texture.fromBitmap(bitmap, true, true);
//			var texture:Texture = Texture.fromBitmap(bitmap);
			_frames.push(texture);
//			bitmap.bitmapData.dispose(); //can't clean up, should handle LostDeviceContext
		}

		protected function createObject():starling.display.MovieClip
		{
			var mc:starling.display.MovieClip = new starling.display.MovieClip(_frames, 30);
			mc.stop();
			addLoops(mc);
			return mc;
		}

		protected function doSnapshot():void
		{
			//specific for each creator which overrides this method
		}

		protected function addLoops(mc:starling.display.MovieClip):void
		{
			//overriden in classes which want to add loops
		}

		protected function init():void
		{
			//overriden in every AnimationCreator. Initiation logic put in special function so that int can be delayed
		}
	}
}
