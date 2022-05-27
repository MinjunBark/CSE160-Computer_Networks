#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"
#include "../../includes/Routing.h"
#include "../../includes/socket.h"
#include "../../includes/TCP_Packet.h"
#include "../../includes/protocol.h"


configuration TransportC {
    provides interface Transport;
}

implementation {

    components TransportP;
    Transport = TransportP;
    
    components new SimpleSendC(AM_PACK);
    TransportP.Sender->SimpleSendC;

    components new TimerMilliC() as ServerTimer;
    TransportP.ServerTimer->ServerTimer;
    
    components new TimerMilliC() as ClientTimer;
    TransportP.ClientTimer->ClientTimer;

    components new RandomC as Random;
    TransportP.Random->Random;

    components new HashmapC(uint16_t, 21) as SocketStorage;
    TransportP.SocketStorage->HashmapC;

}