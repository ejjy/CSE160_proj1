/**
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 * 
 */ 
#include <Timer.h>
#include "command.h"
#include "packet.h"
#include "sendInfo.h"
#include "ping.h"

module Node{
   uses interface Boot;

   uses interface List<pack> as PacketList;
   uses interface Random as Random;
   uses interface SplitControl as AMControl;
   uses interface Receive;
   //uses interface List<Node> as Neighbors;

   uses interface SimpleSend as Sender;
}

implementation{
   pack sendPackage;

   // Prototypes
   bool findPack(pack *Package);
   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t Protocol, uint16_t seq, uint8_t *payload, uint8_t length);

   event void Boot.booted(){
      call AMControl.start();

      dbg("genDebug", "Booted\n");
   }

   event void AMControl.startDone(error_t err){
      if(err == SUCCESS){
         dbg("genDebug", "Radio On\n");
      }else{
         //Retry until successful
         call AMControl.start();
      }
   }

   event void AMControl.stopDone(error_t err){}

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
      dbg("genDebug", "Packet Received\n");
      if(len==sizeof(pack)){
         pack* myMsg=(pack*) payload;
         //Check the packet first to see if we've seen it before
         if(myMsg->TTL == 0 || findPack(myMsg)) {
         	//Drop the packet if we've seen it or if it's TTL has run out
         	dbg("Project1F", "Dropping packet seq#%d from %d\n", myMsg->seq, myMsg->src);         	
         } else if(TOS_NODE_ID==myMsg->dest){
            dbg("Project1F", "Packet from %d has arrived! Msg: %s\n", myMsg->src, myMsg->payload);
            
            //First thing is to push the incoming packet into our seen/sent list
            if(call PacketList.isFull()) {
            	call PacketList.popfront();
            }
            call PacketList.pushback(*myMsg);

            switch(myMsg->protocol){
               uint8_t createMsg[PACKET_MAX_PAYLOAD_SIZE];
               uint16_t dest;

               case PROTOCOL_PING:
               dbg("Project1F", "Sending Ping Reply to %d! \n", myMsg->src);
               makePack(&sendPackage, TOS_NODE_ID, myMsg->src, MAX_TTL,
                     PROTOCOL_PINGREPLY, 0, (uint8_t *) myMsg->payload, sizeof(myMsg->payload));
               //Push the packet we want to send into our seen/sent list
			   if(call PacketList.isFull()) {
         	      call PacketList.popfront();
         	   }
         	   call PacketList.pushback(sendPackage);
               call Sender.send(sendPackage, AM_BROADCAST_ADDR);
               break;

               case PROTOCOL_PINGREPLY:
               dbg("Project1F", "Received a Ping Reply from %d!\n", myMsg->src);
               break;

               case PROTOCOL_CMD:
               switch(getCMD((uint8_t *) &myMsg->payload, sizeof(myMsg->payload))){
                  case CMD_PING:
                     memcpy(&createMsg, (myMsg->payload) + CMD_LENGTH+1, sizeof(myMsg->payload) - CMD_LENGTH+1);
                     memcpy(&dest, (myMsg->payload)+ CMD_LENGTH, sizeof(uint8_t));
                     makePack(&sendPackage, TOS_NODE_ID, (dest-48)&(0x00FF),
                           MAX_TTL, PROTOCOL_PING, 0, (uint8_t *)createMsg, sizeof(createMsg));	

                     //Push the packet we want to send into our seen/sent list
					 if(call PacketList.isFull()) {
						 call PacketList.popfront();
					 }
 	        		 call PacketList.pushback(sendPackage);
                     call Sender.send(sendPackage, AM_BROADCAST_ADDR);
                     break;
                  default:
                     break;
               }
               break;
               default:
               break;
            }
         } else {
         	//Handle packets that do not belong to you
         	dbg("Project1F", "Received packet not meant for %d\n", TOS_NODE_ID);
         	makePack(&sendPackage, myMsg->src, myMsg->dest, myMsg->TTL-1, myMsg->protocol, myMsg->seq, (uint8_t *)myMsg->payload, sizeof(myMsg->payload));
         	//Push the packet we want to send into our seen/sent list
			dbg("Project1F", "Received Message from %d, meant for %d. Rebroadcasting\n", myMsg->src, myMsg->dest);
         	if(call PacketList.isFull()) {
         		call PacketList.popfront();
         	}
         	call PacketList.pushback(sendPackage);
    	    call Sender.send(sendPackage, AM_BROADCAST_ADDR);
         }
         return msg;
      }

      dbg("genDebug", "Unknown Packet Type\n");
      return msg;
   }
	//Searches for a packet in our seen/sent packet list
	bool findPack(pack *Package) {
		uint16_t size = call PacketList.size();
		uint16_t i = 0;
		pack Match;
		for(i = 0; i < size; i++) {
			Match = call PacketList.get(i);
			if(Match.src == Package->src && Match.dest == Package->dest && Match.seq == Package->seq) {
				return TRUE;
			}
		}
		return FALSE;
	}

   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
      Package->src = src;
      Package->dest = dest;
      Package->TTL = TTL;
      Package->seq = seq;
      Package->protocol = protocol;
      memcpy(Package->payload, payload, length);
   }
}