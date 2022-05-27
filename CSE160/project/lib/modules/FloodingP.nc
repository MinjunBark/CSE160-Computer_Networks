#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"


module FloodingP
{
	//Provides the SimpleSend interface in order to flood packets
	provides interface Flooding;
	//Uses the SimpleSend interface to forward recieved packet as broadcast
	uses interface SimpleSend as Sender;
	//Uses the Receive interface to determine if received packet is meant for me.
	uses interface Receive as Receiver;

	uses interface Packet;
    uses interface AMPacket;

	
	//Uses the Queue interface to determine if packet recieved has been seen before
	uses interface List<pack> as KnownPacketsList;

	uses interface NeighborDiscovery;
}

implementation
{
	pack sendPackage;
	uint8_t * neighbors; //Maximum of 20 neighbors?


	// Prototypes
	void makePack(pack * Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t * payload, uint8_t length);
	bool isInList(pack packet); //delete pointer star
	error_t addToList(pack packet);

	//Broadcast packet
	command error_t Flooding.send(pack msg, uint16_t dest)
	{
		//Attempt to send the packet
		dbg(FLOODING_CHANNEL, "Sending from Flooding\n");

		if (call Sender.send(msg, AM_BROADCAST_ADDR) == SUCCESS)
		{
			return SUCCESS;
		}
		return FAIL;
	}

	//Event signaled when a node recieves a packet
	event message_t *Receiver.receive(message_t * msg, void *payload, uint8_t len)
	{
		dbg(FLOODING_CHANNEL, "Packet Received in Flooding\n");
		if (len == sizeof(pack))
		{
			pack *contents = (pack *)payload;


			//If I am the original sender or have seen the packet before, drop it
			if ((contents->src == TOS_NODE_ID) || isInList(*contents))
			{
				dbg(FLOODING_CHANNEL, "Dropping packet.\n");
				return msg;
			}
			//Kill the packet if TTL is 0
			if (contents->TTL == 0){
            //do nothing
				dbg(FLOODING_CHANNEL, "TTL: %d\n", contents-> TTL); //
				call KnownPacketsList.pushback(*contents);
				return msg;
            }
			//
			if(contents->dest != TOS_NODE_ID){
				//for loop of neighborhood size
				uint16_t i;
				uint16_t tempSend;
				for(i = 0; i < call NeighborDiscovery.convertFloodsize(); i++){
					//which neighbor im at in the lsit 
					tempSend = call NeighborDiscovery.getNeighbor(i); //all of its neighbors

					dbg(FLOODING_CHANNEL,"Node:%d has %d\n ",TOS_NODE_ID,tempSend);
					//send the package to the neighbors 
					call Sender.send(*contents,tempSend);
					//add the packages to the knownpacklsit
					call KnownPacketsList.pushback(*contents); //node knows that packet
				}
			}else{
				//print
				dbg(FLOODING_CHANNEL,"Reached Nodes :) %s\n",contents->payload);
				return msg;
				}
		}
	}
	//added
	void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
	Package->src = src; //node it came from 
	Package->dest = dest; //node it wants to go to 
	Package->TTL = TTL; // time to live
	Package->seq = seq; // ID# of packes
	Package->protocol = protocol; //request/ reply
	memcpy(Package->payload, payload, length); //payload is message ? 
	}

	bool isInList(pack packet){
		uint16_t i;
		for(i = 0; i < call KnownPacketsList.size(); i++){ //added .size()
			sendPackage = call KnownPacketsList.get(i);
			if((packet.src == sendPackage.src) && (packet.seq == sendPackage.seq)){ //added 
				dbg(FLOODING_CHANNEL, "SEEN PACKET! IGNORING ...\n"); //added 
				return TRUE;
			}
		}
		return FALSE;
	}

	command void Flooding.printFlood(){
		call NeighborDiscovery.print();
	}

	command void Flooding.runFlood(){
		call NeighborDiscovery.run();
	}

}