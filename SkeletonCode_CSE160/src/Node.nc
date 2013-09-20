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

   uses interface Random as Random;
   uses interface SplitControl as AMControl;
   uses interface Receive;

   uses interface SimpleSend as Sender;
}

implementation{
   pack sendPackage;

   // Prototypes
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

         if(TOS_NODE_ID==myMsg->dest){
            dbg("genDebug", "Packet from %d has arrived! Msg: %s\n", myMsg->src, myMsg->payload);
            switch(myMsg->protocol){
               uint8_t createMsg[PACKET_MAX_PAYLOAD_SIZE];
               uint16_t dest;

               case PROTOCOL_PING:
               dbg("genDebug", "Sending Ping Reply to %d! \n", myMsg->src);
               makePack(&sendPackage, TOS_NODE_ID, myMsg->src, MAX_TTL,
                     PROTOCOL_PINGREPLY, 0, (uint8_t *) myMsg->payload, sizeof(myMsg->payload));
               call Sender.send(sendPackage, sendPackage.dest);
               break;

               case PROTOCOL_PINGREPLY:
               dbg("genDebug", "Received a Ping Reply from %d!\n", myMsg->src);
               break;

               case PROTOCOL_CMD:
               switch(getCMD((uint8_t *) &myMsg->payload, sizeof(myMsg->payload))){
                  case CMD_PING:
                     memcpy(&createMsg, (myMsg->payload) + CMD_LENGTH+1, sizeof(myMsg->payload) - CMD_LENGTH+1);
                     memcpy(&dest, (myMsg->payload)+ CMD_LENGTH, sizeof(uint8_t));
                     makePack(&sendPackage, TOS_NODE_ID, (dest-48)&(0x00FF),
                           MAX_TTL, PROTOCOL_PING, 0, (uint8_t *)createMsg, sizeof(createMsg));	

                     //Place in Send Buffer
                     call Sender.send(sendPackage, sendPackage.dest);
                     break;
                  default:
                     break;
               }
               break;
               default:
               break;
            }
         }
         return msg;
      }

      dbg("genDebug", "Unknown Packet Type\n");
      return msg;
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
