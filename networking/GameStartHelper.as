/**
 * Author: Alexey
 * Date: 12/2/12
 * Time: 12:49 AM
 */
package networking
{
	import events.ServerMessageEvent;

	import model.MessageTypes;
	import model.ServerTalker;

	import playerio.Connection;
	import playerio.Message;

	import utils.EventHub;

	/**
	 * This class was created to encapsulate set-game-connection -> on-start-msg-received logic.
	 * It was shared by 3 other classes
	 */
	public class GameStartHelper
	{
		private static var targetConnection:Connection;

		public static function setGameConnection(connection:Connection):void
		{
			targetConnection = connection;
			targetConnection.addMessageHandler(MessageTypes.START_GAME, onStartGameMessageReceived);
		}

		public static function onStartGameMessageReceived(message:Message):void
		{
			trace(message);
			targetConnection.removeMessageHandler(MessageTypes.START_GAME, onStartGameMessageReceived);
			ServerTalker.setGameConnection(targetConnection);
			EventHub.dispatch(new ServerMessageEvent(ServerMessageEvent.START_GAME, message));
		}
	}
}
