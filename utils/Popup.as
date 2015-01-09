package utils
{
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * ...
 * @author Alexey Kuznetsov
 */
public class Popup extends Sprite
{
	private static var _popups:Vector.<Popup> = new Vector.<Popup>();

	protected var _mc:MovieClip;

	private var _shaderAlpha:Number;
	private var _shader:Shape;

	private var _forced:Boolean;

	/**
	 * Core of popup system. Shows basic popup. Supports queueing of popups.
	 * (if there are any of popups shown when adding popup,
	 * this popup will be added to queue and will be shown when the time comes).
	 * @param mcc usually MovieClip with graphics
	 * @param forced if true iit will ignore the queue of popups
	 * @param x may not be passed since popup is being centered by default
	 * @param y may not be passed since popup is being centered by default
	 * @param shaderAlpha alpha of popup background (which covers all the stuff beneath popup)
	 */
	public function Popup(mcc:MovieClip, forced:Boolean = false, x:Number = 0, y:Number = 0, shaderAlpha:Number = 0.7)
	{
		_shaderAlpha = shaderAlpha;
		_mc = mcc;
		_forced = forced;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		centerMC();
	}

	protected function onAddedToStage(event:Event):void
	{
		addShader();

		super.addChild(_mc);

		if (_popups.length > 0 && !_forced) //there are other popups in queue, wait until they will be removed
			visible = false;

		_popups.push(this);
	}

	protected function onRemovedFromStage(event:Event):void
	{
		_popups.splice(_popups.indexOf(this), 1);

		if (_popups.length > 0 && !_forced) //if there are any other popups in the queue -> show first one of them
			_popups[0].visible = true;
	}

	/**
	 * This must be called always, since it adds shape which blocks clicks to any other parts of interface.
	 * If no need in shader just pass shaderAlpha parameter as 0
	 */
	private function addShader():void
	{
		_shader = Misc.createRectangle(Config.APP_WIDTH, Config.APP_HEIGHT);
		_shader.alpha = _shaderAlpha;
		_shader.addEventListener(MouseEvent.CLICK, die);
		super.addChild(_shader);
	}

	private function centerMC():void
	{
		_mc.x = 0.5 * (Config.APP_WIDTH - _mc.width);
		_mc.y = 0.5 * (Config.APP_HEIGHT - _mc.height);
	}

	public function die(event:MouseEvent = null):void
	{
		clearListeners();
        if (_shader && contains(_shader))
            super.removeChild(_shader); //in case if popup is singleton (preventing stacking up of this shaders)
		parent.removeChild(this);
	}

	/**
	 * Allows all which inherit from this class to clear whatever stuff needed.
	 */
	protected function clearListeners():void
	{

	}

	/**
	 * Overriden so that classes which are inherited from this one may not care about shader & positioning overhead
	 * They just work with "popup" itself which is being MC passed to constructor
	 * @param child
	 * @return
	 */
	override public function addChild(child:DisplayObject):DisplayObject
	{
		_mc.addChild(child);
		return child;
	}

	public static function get popups():Vector.<Popup>
	{
		return _popups;
	}
}
}