/**
 * ANDES Lab - University of California, Merced
 * 
 * @author UCM ANDES Lab
 * @date   2013/09/03
 * 
 */
#include "../../packet.h"
#include "../../sendInfo.h"

module SimpleSendP{
   provides interface SimpleSend;
   uses interface List<sendInfo> as sendBuffer;
   uses interface Timer<TMilli> as sendTimer;
   
   uses interface Packet;
   uses interface AMPacket;
   uses interface AMSend;

   uses interface Random as Random;
}

implementation{
   uint16_t sequenceNum = 0;
   bool busy = FALSE;
   message_t pkt;

   error_t send(uint16_t src, uint16_t dest, pack *message);
   // A random element of delay is included to prevent congestion.
   void postSendTask(){
      if(call sendTimer.isRunning() == FALSE){
         call sendTimer.startOneShot( (call Random.rand16() %200) + 20);
      }
   }

   command error_t SimpleSend.send(pack msg, uint16_t dest) {
      sendInfo input;
      input.packet = msg;
      input.dest = dest;

      call sendBuffer.pushback(input);

      postSendTask();
      
      return SUCCESS;
   }

   task void sendBufferTask(){
      if(!call sendBuffer.isEmpty() && !busy){
         sendInfo info;
         info = call sendBuffer.popfront();// Peak
         send(info.src,info.dest, &(info.packet));

      }
      if(!call sendBuffer.isEmpty()){
         postSendTask();
      }
   }
   
   event void sendTimer.fired(){
      post sendBufferTask();
   }

   /*
    * Send a packet
    *
    *@param
    *	src - source address
    *	dest - destination address
    *	msg - payload to be sent
    *
    *@return
    *	error_t - Returns SUCCESS, EBUSY when the system is too busy using the radio, or FAIL.
    */
   error_t send(uint16_t src, uint16_t dest, pack *message){
      if(!busy){
         pack* msg = (pack *)(call Packet.getPayload(&pkt, sizeof(pack) ));			
         *msg = *message;

         if(call AMSend.send(dest, &pkt, sizeof(pack)) ==SUCCESS){
            busy = TRUE;
            return SUCCESS;
         }else{
            dbg("genDebug","The radio is busy, or something\n");
            return FAIL;
         }
      }else{
         return EBUSY;
      }
      dbg("genDebug", "FAILED!?");
      return FAIL;
   }	

   event void AMSend.sendDone(message_t* msg, error_t error){
      //Clear Flag, we can send again.
      if(&pkt == msg){
         busy = FALSE;
         postSendTask();
      }
   }
}
