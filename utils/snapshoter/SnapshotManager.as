/**
 * Author: Alexey
 * Date: 8/24/12
 * Time: 6:31 PM
 */
package utils.snapshoter
{
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import model.ServerTalker;

/**
 * Tracks recording activation / finish events & enterFrame events
 */
public class SnapshotManager
{
	private static var stageLink:Stage;
	private static var snapshotName:String;
	private static var isRecording:Boolean = false;

	public static function init(stage:Stage, ssnapshotName:String):void
	{
		stageLink = stage;
		snapshotName = ssnapshotName;
		Snapshoter.initAreaSelector(stage);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private static function onKeyDown(event:KeyboardEvent):void
	{
		if (event.keyCode == Keyboard.SPACE)
		{
			if (!isRecording)
				tryStartRecording();
			else
				stopRecording();
		}
	}

	private static function tryStartRecording():void
	{
		trace("Trying to start recoding...");
		if (Snapshoter.ready)
		{
			trace("Recording started.");
			isRecording = true;
			ServerTalker.startSnapshotRecording(snapshotName, Snapshoter.areaWidth, Snapshoter.areaHeight);
			stageLink.addEventListener(Event.ENTER_FRAME, snaphot);
		}
		else
			trace("Snapshoter aint ready yet! Select area first.");
	}

	private static function stopRecording():void
	{
		trace("Stopped recoding.");
		isRecording = false;
		ServerTalker.finishSnapshotRecording();
		stageLink.removeEventListener(Event.ENTER_FRAME, snaphot);
	}

	private static function snaphot(event:Event):void
	{
		var byteAr:ByteArray = Snapshoter.getBASnaphot();
		ServerTalker.saveSnapshotFrame(byteAr);
//		byteAr.position = 0;
//		var load:Loader = new Loader();
//		load.loadBytes(byteAr);
//		load.scaleX = 0.5;
//		load.scaleY = 0.5;
//		load.x = 800;
//		stageLink.addChild(load);
	}
}
}
