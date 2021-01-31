#include <sourcemod>
#include <socket>

bool g_gameOverTriggered = false;
bool g_enabled = false;

Socket g_MumbleSocket;
ConVar g_BotAddress;

public OnPluginStart() {
	g_MumbleSocket = new Socket(SOCKET_TCP, OnSocketError);
	g_BotAddress = CreateConVar("mbl_bot_address", "127.0.0.1", "The IP of the mumble bot to interface with");

	HookConVarChange(g_BotAddress, ConVarChangeBotAddress);

	HookEvent("teamplay_game_over", GameOverEvent);		//maxrounds, timelimit
	HookEvent("tf_game_over", GameOverEvent);
    
}

public void ConVarChangeBotAddress(ConVar convar, const char[] oldvalue, const char[] newvalue) {
	g_enabled = true;
}

public void OnSocketConnected(Socket socket, any arg) {
	
}

public void OnSocketReceive(Socket socket, char[] receiveData, const int dataSize, any hFile) {
	// receive another chunk and write it to <modfolder>/dl.htm
	// we could strip the http response header here, but for example's sake we'll leave it in

}

public void OnSocketDisconnected(Socket socket, any arg) {
	CloseHandle(socket);
}

public void OnSocketError(Socket socket, const int errorType, const int errorNum, any arg) {
	// a socket error occured
	LogError("socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public GameOverEvent(Handle:event, const String:name[], bool:dontBroadcast) {
	if(g_gameOverTriggered || !g_enabled) {
		return;
	}

	char address[128];
	GetConVarString(g_BotAddress, address, sizeof(address));

	g_MumbleSocket.Connect(OnSocketConnected, OnSocketReceive, OnSocketDisconnected, address, 5000);
	g_gameOverTriggered = true;


	g_MumbleSocket.Send("end");
	CloseHandle(g_MumbleSocket);
}
