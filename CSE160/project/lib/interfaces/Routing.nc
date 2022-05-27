#include "../../includes/packet.h"

interface Routing{
   command error_t send(pack msg, uint16_t dest );

   command void runRouting();
   command void printRouting();
   command void PrintNeighbors();

}
