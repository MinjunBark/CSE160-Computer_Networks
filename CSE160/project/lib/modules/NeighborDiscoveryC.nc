#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"

configuration NeighborDiscoveryC{
   provides interface NeighborDiscovery;
}

implementation {
  components NeighborDiscoveryP;
  NeighborDiscovery = NeighborDiscoveryP.NeighborDiscovery;


  components new SimpleSendC(AM_PACK) as Sender; //could change name
  NeighborDiscoveryP.Sender -> Sender;

  components new AMReceiverC(AM_PACK) as NeighborReceive;
  NeighborDiscoveryP.Receiver -> NeighborReceive;

  components new TimerMilliC() as sendTimer;
  NeighborDiscoveryP.periodicTimer -> sendTimer;

  components new ListC(uint16_t, 20) as Neighborhood;
  NeighborDiscoveryP.Neighborhood -> Neighborhood;

}