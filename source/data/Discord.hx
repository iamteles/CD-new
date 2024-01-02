package data;

import Sys.sleep;
#if DISCORD_RPC
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	public function new()
	{
		#if DISCORD_RPC
		//trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1155541092725428425",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		//trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			////trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}
	
	public static function shutdown()
	{
		#if DISCORD_RPC
		DiscordRpc.shutdown();
		#end
	}
	
	static function onReady()
	{
		#if DISCORD_RPC
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "CD v2"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		//trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		//trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if DISCORD_RPC
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		//trace("Discord Client initialized");
		isInitialized = true;
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if DISCORD_RPC
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: "What are you lookin at?",
			state: state,
			largeImageKey: 'icon',
			largeImageText: "CDv2",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
		#end
	}
}
