#include "../../packet.h"

interface FloodSend{
	command error_t send(pack msg, uint16_t dest);
}