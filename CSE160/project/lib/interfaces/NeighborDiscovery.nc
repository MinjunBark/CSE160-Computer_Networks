#include "../../includes/packet.h"

interface NeighborDiscovery{
   // command error_t send(pack msg, uint16_t dest ); //dont need it 
   command void run();
   command void print();
   command uint16_t convertFloodsize();
   command uint16_t getNeighbor(uint16_t position);

}

