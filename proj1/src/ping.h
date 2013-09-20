#ifndef PING_H
#define PING_H
#include <Timer.h>
#include "dataStructures/pingList.h"
#include "dataStructures/pingInfo.h"

enum{
	PING_TIMER_PERIOD=5333,
	PING_TIMEOUT = 5000 //Time out in 5 seconds
};

#endif /* PING_H */
