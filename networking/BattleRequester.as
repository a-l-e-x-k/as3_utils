/**
 * Author: Alexey
 * Date: 12/1/12
 * Time: 5:41 PM
 */
package networking
{
	import events.RequestEvent;
	import events.ServerMessageEvent;

	import model.MessageTypes;
	import model.PopupsManager;
	import model.ServerTalker;
    import model.constants.GameConfig;
    import model.constants.GameTypes;

    import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIOError;

	import utils.EventHub;
	import utils.t;

	public class BattleRequester
	{
		private static var roomConnection:Connection;
		private static var _targetUid:String;
		private static var _finding:Boolean = false; //true if BattleRequester is at the state of awaiting confirmation / connecting

		/**
		 * Assuming that targetUid is id of the room
		 * @param targetUid
		 * @param uid
		 */
		public static function requestBattle(targetUid:String, uid:String):void
		{
			trace("BattleRequester : requestBattle : targetUid: " + targetUid + " uid: " + uid);
			_targetUid = targetUid;
			_finding = true;
			ServerTalker.client.multiplayer.joinRoom(targetUid, {safeBattle:true, gameVersion:GameConfig.GAME_VERSION}, onConnectedToRoom, couldNotConnect);
		}

		public static function cancelCurrentRequest():void
		{
			if (roomConnection)
			{
				cleanListeners();
				roomConnection.send(MessageTypes.CANCEL_BATTLE_REQUEST);
				roomConnection.disconnect();
			}
		}

		private static function couldNotConnect(error:PlayerIOError = null):void  // = null, because once upon a time ...  ArgumentError: Error #1063: Argument count mismatch on networking::BattleRequester$/couldNotConnect(). Expected 1, got 0.
		{
			trace("BattleRequester : couldNotConnect : ");
			if (_finding)
			{
				t.obj(error);
				_finding = false;
				EventHub.dispatch(new RequestEvent(RequestEvent.SHOW_PLAYER_NO_LONGER_ONLINE, {uid:_targetUid}));
			}
			else
				trace("BattleRequester : couldNotConnect : unexpected call of couldNotConnect() function");
		}

		/**
		 * Just connected. Wait for server reply on whether player can play.
		 * @param connection
		 */
		private static function onConnectedToRoom(connection:Connection):void
		{
            trace("BattleRequester: onConnectedToRoom: ");
			roomConnection = connection;
			roomConnection.addMessageHandler(MessageTypes.PLAYER_PLAYING_ALREADY, dispatchPlayingAlready);
			roomConnection.addMessageHandler(MessageTypes.START_GAME, onStartGameMessageReceived);
			roomConnection.addMessageHandler(MessageTypes.BATTLE_REQUEST_DENIED, dispatchPlayerDenied);
			roomConnection.addMessageHandler(MessageTypes.USER_LEFT, onTargetUserLeft);
			roomConnection.addDisconnectHandler(couldNotConnect);
		}

		private static function onStartGameMessageReceived(message:Message):void
		{
			trace("BattleRequester : onStartGameMessageReceived : ");
			trace(message);
			cleanListeners(); //no need for those connect-related messages
			PopupsManager.removeWaitingBattleRequestPopup();
			ServerTalker.setGameConnection(roomConnection);
			EventHub.dispatch(new ServerMessageEvent(ServerMessageEvent.START_GAME, message));
		}

		private static function dispatchPlayerDenied(msg:Message):void
		{
			EventHub.dispatch(new RequestEvent(RequestEvent.SHOW_PLAYER_CANCELLED_BATTLE, {uid:_targetUid}));
			cleanListeners();
		}

		private static function onTargetUserLeft(msg:Message):void
		{
			trace("BattleRequester : onTargetUserLeft : ");
			EventHub.dispatch(new RequestEvent(RequestEvent.SHOW_PLAYER_NO_LONGER_ONLINE, {uid:_targetUid}));
			cleanListeners();
		}

		private static function dispatchPlayingAlready(msg:Message):void
		{
			EventHub.dispatch(new RequestEvent(RequestEvent.SHOW_PLAYER_IS_PLAYING_ALREADY, {uid:_targetUid}));
			cleanListeners();
		}

		private static function cleanListeners():void
		{
			trace("BattleRequester : cleanListeners : roomConnection: " + roomConnection);
			if (!roomConnection)
				return;

			roomConnection.removeMessageHandler(MessageTypes.START_GAME, onStartGameMessageReceived);
			roomConnection.removeMessageHandler(MessageTypes.PLAYER_PLAYING_ALREADY, dispatchPlayingAlready);
			roomConnection.removeMessageHandler(MessageTypes.BATTLE_REQUEST_DENIED, dispatchPlayerDenied);
			roomConnection.removeMessageHandler(MessageTypes.USER_LEFT, onTargetUserLeft);
			roomConnection.removeDisconnectHandler(couldNotConnect);

			_finding = false;
		}
	}
}
