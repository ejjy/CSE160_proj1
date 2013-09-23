/*
 * Author: UCM ANDES Lab
 * Date: 2013/09/03
 * Description: Processes commands and returns an Command ID Number.
 */

#ifndef COMMAND_H
#define COMMAND_H
#include "dataStructures/iterator.h"
 
//Command ID Number
enum{
	CMD_PING = '0',
	CMD_NEIGHBOR_DUMP='1',
	CMD_LINKLIST_DUMP='2',
	CMD_ROUTETABLE_DUMP='3',
	CMD_TEST_CLIENT='4',
	CMD_TEST_SERVER='5',
	CMD_KILL='6',
	CMD_ERROR='9'
};

//Lengths of commands
enum{
	CMD_LENGTH = 1,
};

bool isPing(uint8_t *array, uint8_t size){
	if(array[0]==CMD_PING)return TRUE;
	return FALSE;
}

bool isNeighborDump(uint8_t *array, uint8_t size) {
	if(array[0] == CMD_NEIGHBOR_DUMP) return TRUE;
	return FALSE;
}

/*
 * getCmd - processes a string to find out which command is being issued. A Command ID is returned based on the
 * enum declared. Also debugging information is sent to the cmdDebug channel.
 * 
 * @param:
 * 		uint8_t *array = a string held in a byte array
 * 		uint8_t size = size of the above string
 * @return:
 * 		int = Returns one of the above ID Numbers to indicate the type of command.
 */
int getCMD(uint8_t *array, uint8_t size){
	dbg("cmdDebug", "A Command has been Issued.\n");

	if(isPing(array,size)){
		dbg("cmdDebug", "Command Type: Ping\n");
		return CMD_PING;
	}
	
	if(isNeighborDump(array, size)) {
		dbg("cmdDebug", "Command Type: Neighbor Dump\n");
		return CMD_NEIGHBOR_DUMP;
	}
	
	dbg("cmdDebug", "CMD_ERROR: \"%s\" does not match any known commands.\n", array);
	return CMD_ERROR;
}


#endif /* COMMAND_H */
