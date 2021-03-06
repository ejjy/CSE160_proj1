configuration SimpleSendC{
   provides interface SimpleSend;
}

implementation{
   components SimpleSendP as App;
   SimpleSend = App.SimpleSend;

	components new TimerMilliC() as sendTimer;
   components RandomC as Random;
	components new AMSenderC(6);

   //Timers
	App.sendTimer -> sendTimer;
	App.Random -> Random;
   
   App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMSend -> AMSenderC;
   
   //Lists
   components new ListC(sendInfo, 10) as sendBuffer;
   App.sendBuffer -> sendBuffer;
}
