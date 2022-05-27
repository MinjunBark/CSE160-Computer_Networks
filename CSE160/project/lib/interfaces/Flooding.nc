#include "../../includes/packet.h"

interface Flooding{
   command error_t send(pack msg, uint16_t dest );

   command void runFlood();
   command void printFlood();
   
}
