/**
 * Author: Alexey
 * Date: 7/31/12
 * Time: 3:37 AM
 */
package utils.animations
{
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.utils.Dictionary;

public class AnimClip extends MovieClip
{
	private var _loopDictionary:Dictionary = new Dictionary();
	private var _frames:Dictionary = new Dictionary();
	private var _stoppersDictionary:Dictionary = new Dictionary();
	private var _currentFrame:int = 0;

	public function AnimClip()
	{
		play();
	}

	public function tick(event:Event = null):void
	{
		if (_loopDictionary[_currentFrame + 1])
			goto(_loopDictionary[_currentFrame + 1]);
		else
			goto(_currentFrame + 1);

		if (_stoppersDictionary[_currentFrame + 1])
			stop();
	}

	override public function play():void
	{
		addEventListener(Event.ENTER_FRAME, tick);
	}

	override public function stop():void
	{
		removeEventListener(Event.ENTER_FRAME, tick);
	}

	public function goto(frame:Object, scene:String = null):void
	{
		setVisibility(false);
		_currentFrame = int(frame);
		setVisibility(true);
	}

	override public function addChild(child:DisplayObject):DisplayObject
	{
		_frames[_currentFrame] = child;
		setVisibility(false);
		super.addChild(child);
		return child;
	}

	public function addLoop(atFrame:int, toFrame:int):void
	{
		_loopDictionary[atFrame] = toFrame;
	}

	/**
	 * At which frames to stop
	 * @param atFrame
	 */
	public function addStopper(atFrame:int):void
	{
		_stoppersDictionary[atFrame] = 1;
	}

	public function getFramesCount():int
	{
		var count:int = 0;
		for (var key:Object in _frames)
		{
			count++;
		}
		return count;
	}

	private function setVisibility(flag:Boolean):void
	{
		if (_frames[_currentFrame])
			_frames[_currentFrame].visible = flag;
	}
}
}
