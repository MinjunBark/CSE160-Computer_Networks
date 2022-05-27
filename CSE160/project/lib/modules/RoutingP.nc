#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"
#include "../../includes/Routing.h"

module RoutingP
{
	//Provides the SimpleSend interface in order to flood packets
	provides interface Routing;
	//Uses the SimpleSend interface to forward recieved packet as broadcast
	uses interface SimpleSend as Sender;
	//Uses the Receive interface to determine if received packet is meant for me.
	uses interface Receive as Receiver;
	uses interface Packet;
    uses interface AMPacket;
	uses interface Timer<TMilli> as periodicTimer;
    // uses interface HashMap <pack,20> DistanceVector;//added
	uses interface Hashmap<uint16_t> as DistanceVector;  //added
	uses interface Hashmap<uint16_t> as NextHopVecter;
	uses interface NeighborDiscovery;
}

implementation
{
	pack sendPackage;
	uint8_t * neighbors; //Maximum of 20 neighbors?


	// Prototypes
	void makePack(pack * Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t * payload, uint8_t length);
	//Broadcast packet
	command error_t Routing.send(pack msg, uint16_t dest)
	{
		//Attempt to send the packet
		uint16_t temp =  call NextHopVecter.get(dest);
		dbg(ROUTING_CHANNEL, "Sending from ROUTING\n");
		if (call Sender.send(msg, temp) == SUCCESS)
		{
			return SUCCESS;
		}
		return FAIL;
	}

	//Event signaled when a node recieves a packet
	event message_t *Receiver.receive(message_t * msg, void *payload, uint8_t len)
	{
		//dbg(ROUTING_CHANNEL, "Packet Received in Routing\n");
		if (len == sizeof(pack))
		{
			pack *contents = (pack *)payload;
			// dbg(ROUTING_CHANNEL, "Routing called: \n");
			
			// dbg(ROUTING_CHANNEL, "%d\n", contents->protocol);
			//If I am the original sender or have seen the packet before, drop it
			if (PROTOCOL_DV == contents->protocol)
			{
				uint16_t k;
				for(k = 0; k < 10; k++){
					if(contents->payload[2*k] == 0){
						//ignoring
						// dbg(ROUTING_CHANNEL,"IGNORING\n");
					}else{
						uint16_t RoutingDest = contents->payload[2*k];
						uint16_t RoutingCost = contents->payload[2*k+1];
							// dbg(ROUTING_CHANNEL,"IGNORING222222\n");
						if(call DistanceVector.contains(RoutingDest) == TRUE){
							//if the cost is shorter than prvious then replace
								// dbg(ROUTING_CHANNEL,"IGNORING33333\n");
							if(RoutingCost + 1 < call DistanceVector.get(RoutingDest)){
									// dbg(ROUTING_CHANNEL,"IGNORING4444444\n");
								call DistanceVector.insert(RoutingDest, RoutingCost+1);
								call NextHopVecter.insert(RoutingDest, contents->src);
							}else{
								//ignore
									// dbg(ROUTING_CHANNEL,"IGNORING5555\n");
							}
						}else{ //dont have anything in hashmap 
							// dbg(ROUTING_CHANNEL,"IGNORING6666666\n");
							call DistanceVector.insert(RoutingDest, RoutingCost+1);
							call NextHopVecter.insert(RoutingDest, contents->src);
						}
					}
				}
				//read payload//1 pair at a time 
				//1 pair at a time 
				//if distAdvertisment is better then currrent Dist 
				//replace dist and next hop to src
			}else if(contents->TTL > 0){
				//check if we're are dest
				if(contents->dest == TOS_NODE_ID && contents->protocol == PROTOCOL_PING){
					dbg(ROUTING_CHANNEL, "Coming From Routing Channel\n");
				}else{
					uint16_t temp = call NextHopVecter.get(contents->dest);
					call Sender.send(*contents,temp);
				}
			}
			//Kill the packet if TTL is 0
			if (contents->TTL == 0){
            //do nothing
				//dbg(ROUTING_CHANNEL, "TTL: %d\n", contents-> TTL); //
				// call KnownPacketsList.pushback(*contents);
				return msg;
            }
		}
	}

	//added
	void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t* payload, uint8_t length){ //switch seq and protocol
	Package->src = src; //node it came from 
	Package->dest = dest; //node it wants to go to 
	Package->TTL = TTL; // time to live
	Package->seq = seq; // ID# of packes
	Package->protocol = protocol; //request/ reply
	memcpy(Package->payload, payload, length); //payload is message ? 
	}

	void makeRoutingPack(pack *Package, uint16_t dest, uint16_t packcount){
		uint8_t payload[PACKET_MAX_PAYLOAD_SIZE];

	}

	//timerfunction
	//routingpack function
	command void Routing.printRouting(){
		uint16_t i =0;
		uint32_t* keys = call DistanceVector.getKeys();
		dbg(ROUTING_CHANNEL,"Printing Routing Table: \n");
		dbg(ROUTING_CHANNEL, "Dest\tCount\tHop\t\n");

		for(i = 0; i < call DistanceVector.size(); i++){
			uint16_t tempdest = keys[i];
			uint16_t tempCost = call DistanceVector.get(tempdest);
			uint16_t tempNH = call NextHopVecter.get(tempdest);
			if(tempdest != 0){
				dbg(ROUTING_CHANNEL,"%3d\t%3d\t%3d\t\n",tempdest,tempCost, tempNH);
			}
		}
		call NeighborDiscovery.print();
	}

	command void Routing.runRouting(){
		call DistanceVector.insert(TOS_NODE_ID,0);
		call periodicTimer.startPeriodic(10000); //can change time 
		call NeighborDiscovery.run();
	}

	command void Routing.PrintNeighbors(){ // work on this
		call NeighborDiscovery.print();
	}

	event void periodicTimer.fired()
    {
		uint16_t NeighborSize = call NeighborDiscovery.convertFloodsize();
		uint16_t i = 0;
       //dbg(ROUTING_CHANNEL, "Sending from Routing %d\n", NeighborSize);
		//dbg(ROUTING_CHANNEL, "NeighborSize: %d\n", NeighborSize);
		for(i = 0; i < NeighborSize; i++){
			uint16_t j;
			uint16_t k;
			uint32_t* getKeys = call DistanceVector.getKeys();
			for(j = 0; j < call DistanceVector.size(); j+=10){
				makePack(&sendPackage, TOS_NODE_ID, call NeighborDiscovery.getNeighbor(i), 1, 1, PROTOCOL_DV, " " , 0); //changed to 2 from 0
				// dbg(ROUTING_CHANNEL, "hello");
				for(k = 0; k < 10; k++){
					if(j+k >= call DistanceVector.size()){
						sendPackage.payload[2*k] = 0;
						sendPackage.payload[2*k+1] = 0;
						// dbg(ROUTING_CHANNEL, "hello again");
					}else{
						uint16_t ID = getKeys[j+k];
						sendPackage.payload[2*k] = ID;
						sendPackage.payload[2*k+1] = call DistanceVector.get(ID);
						// dbg(ROUTING_CHANNEL, "hello bitches");
					}
				}
				call Sender.send(sendPackage, call NeighborDiscovery.getNeighbor(i));
			}
		}
    }
}