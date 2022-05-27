#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"
#include "../../includes/Routing.h"

configuration RoutingC {
    provides interface Routing;
}

implementation {

    components RoutingP;
    Routing = RoutingP;
    
    components new SimpleSendC(AM_PACK);
    RoutingP.Sender -> SimpleSendC;

    components new AMReceiverC(AM_PACK) as NeighborReceive;
    RoutingP.Receiver -> NeighborReceive;

    components new TimerMilliC() as sendTimer;
    RoutingP.periodicTimer -> sendTimer;

    components new HashmapC(uint16_t, 21) as Distance_HashMap;
    RoutingP.DistanceVector -> Distance_HashMap;
    
    components new HashmapC(uint16_t, 21) as NH_HashMap;
    RoutingP.NextHopVecter -> NH_HashMap;

    components NeighborDiscoveryC;
    RoutingP.NeighborDiscovery -> NeighborDiscoveryC;
}