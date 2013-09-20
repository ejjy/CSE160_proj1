/**
 * ANDES Lab - University of California, Merced
 * This class provides a simple list.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 * 
 */

interface List<t>{
   command void pushback(t input);
	command void pushfront(t input);
	command t popback();
	command t popfront();
	command t front();
	command t back();
	command bool isEmpty();
	command uint16_t size();
	command t get(uint16_t position);
	command bool isFull();
	command t remove(uint16_t position);
}
