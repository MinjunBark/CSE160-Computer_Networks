#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"

configuration FloodingC {
    provides interface Flooding;
}

implementation {
    components FloodingP;
    Flooding = FloodingP;
    
    components new SimpleSendC(AM_PACK);
    FloodingP.Sender -> SimpleSendC;

    components new AMReceiverC(AM_PACK) as NeighborReceive;
    FloodingP.Receiver -> NeighborReceive;

    components NeighborDiscoveryC;
    FloodingP.NeighborDiscovery -> NeighborDiscoveryC;

    components new ListC(pack, 20) as KnownPacketsList;
    FloodingP.KnownPacketsList -> KnownPacketsList;

}