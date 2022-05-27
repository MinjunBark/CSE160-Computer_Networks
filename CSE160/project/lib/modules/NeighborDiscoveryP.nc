#include <Timer.h>
#include "../../includes/command.h"
#include "../../includes/packet.h"
#include "../../includes/CommandMsg.h"
#include "../../includes/sendInfo.h"
#include "../../includes/channels.h"
//add 
// #include "../../includes/channels.h"
module NeighborDiscoveryP
{

    //Provides the SimpleSend interface in order to neighbor discover packets
    provides interface NeighborDiscovery;
    //Uses SimpleSend interface to forward recieved packet as broadcast
    uses interface SimpleSend as Sender;
    //Uses the Receive interface to determine if received packet is meant for me.
	uses interface Receive as Receiver;

    uses interface Packet;
    uses interface AMPacket;
	//Uses the Queue interface to determine if packet recieved has been seen before
	uses interface List <uint16_t> as Neighborhood; //uint16_t = neighbor // type is neighbor
    uses interface Timer<TMilli> as periodicTimer;
    
}


implementation
{
    
    pack sendPackage; 
    // neighbor neighborHolder;
    uint16_t neighbor; //added 
    uint16_t SEQ_NUM=200;
    uint8_t * temp = &SEQ_NUM;
    void makePack(pack * Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t * payload, uint8_t length);

	bool isNeighbor(uint16_t nodeid); //changed
    void addNeighbor(uint16_t nodeid); //changed
    void updateNeighbors();
    void printNeighborhood();

    uint8_t neighbors[19]; //Maximum of 20 neighbors?

    
    command void NeighborDiscovery.run()
	{
        makePack(&sendPackage, TOS_NODE_ID, AM_BROADCAST_ADDR, 1, SEQ_NUM , PROTOCOL_PING, "Got it!" , PACKET_MAX_PAYLOAD_SIZE);
        SEQ_NUM++;
        call Sender.send(sendPackage, AM_BROADCAST_ADDR);
        
        call periodicTimer.startPeriodic(1000000000); //added
	}

    event void periodicTimer.fired()
    {
        //dbg(NEIGHBOR_CHANNEL, "Sending from NeighborDiscovery\n");
        updateNeighbors();




        //optional - call a funsion to organize the list
        makePack(&sendPackage, TOS_NODE_ID, AM_BROADCAST_ADDR, 1, SEQ_NUM , PROTOCOL_PING, "Got it!" , PACKET_MAX_PAYLOAD_SIZE);
		call Sender.send(sendPackage, AM_BROADCAST_ADDR);
    }

	command void NeighborDiscovery.print() {
		printNeighborhood();
	}
    

    event message_t *Receiver.receive(message_t * msg, void *payload, uint8_t len)
    {
        if (len == sizeof(pack)) //check if there's an actual packet
        {
            pack *contents = (pack*) payload;  //used for sendPackets 
           //dbg(NEIGHBOR_CHANNEL,"\nsrc:%d\ndest:%d\nprotocol:%d\nTTL:%d\n", contents->src, contents->dest, contents->protocol, contents->TTL);

            //dbg(NEIGHBOR_CHANNEL, "%d\n", contents->protocol); //%d == number
            if (PROTOCOL_PING == contents->protocol) //got a message, not a reply
            {
                if (contents->TTL == 1) //
                {
                    //replace the destination with source 
                    contents->dest = contents->src;
                    //replace source with current ID
                    contents->src = TOS_NODE_ID;
                    //subtract 1 from TTL 
                    contents->TTL = contents->TTL -1;
                    //replace protocol with pingreply
                    contents->protocol = PROTOCOL_PINGREPLY;
                    //print message "sending a reply "
                    //dbg(NEIGHBOR_CHANNEL, "Sending a reply: \n");
                    //send pack 
                    call Sender.send(*contents, contents->dest);
                    //return msg
                    return msg;
                }else{
                    return msg;
                }
            }
            if(PROTOCOL_PINGREPLY == contents->protocol){
                    //check if neighbor ->  bool isNeighbor(uint8_t nodeid);
                    if(isNeighbor(contents->src)){
                        // dbg(NEIGHBOR_CHANNEL,"MURRRRPPPPPPPPP");
                        updateNeighbors();
                    }
                    if(contents->src != TOS_NODE_ID){
                        addNeighbor(contents->src);
                    }
                }
        }
    }
    //prepares to send message 
    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t* payload, uint8_t length){
    Package->src = src;
    Package->dest = dest;
    Package->TTL = TTL;
    Package->seq = seq;
    Package->protocol = protocol;
    memcpy(Package->payload, payload, length); //manipulate package to become updated 
    }

    void updateNeighbors(){
        makePack(&sendPackage, TOS_NODE_ID, AM_BROADCAST_ADDR, 1, SEQ_NUM , PROTOCOL_PING, temp , PACKET_MAX_PAYLOAD_SIZE);
		call Sender.send(sendPackage, AM_BROADCAST_ADDR);
    }

    bool isNeighbor(uint16_t nodeid){
        int i;
        int neighborSize;
        neighborSize = call Neighborhood.size();
        for(i = 0; i < neighborSize; i++){
            uint16_t tempNeighbor = call Neighborhood.get(i);
            if(tempNeighbor == nodeid){
                return TRUE;
            }
        }
        return FALSE;
    }
    void printNeighborhood(){
        int i;
        int tempNeighSize;
        dbg(NEIGHBOR_CHANNEL, "------------- Node:%d --------------\n", TOS_NODE_ID);
        tempNeighSize = call Neighborhood.size();
        for(i = 0; i < tempNeighSize; i++){
            uint16_t temp2Neighbor = call Neighborhood.get(i);
            dbg(NEIGHBOR_CHANNEL, "\tNeighbor:%d \n", temp2Neighbor);
        }

    }
    void addNeighbor(uint16_t nodeid){
       uint16_t i;
    //    dbg(NEIGHBOR_CHANNEL, "YEEEEEEEEEETTTTTTTT%d\n", nodeid);
       bool isInList = FALSE;
       for(i = 0; i < call Neighborhood.size(); i++){
           if(call Neighborhood.get(i) == nodeid){
               isInList = TRUE;
               break;
           }
       }
        if(!isInList){
            call Neighborhood.pushback(nodeid);
        }
        // call Neighborhood.pushback(nodeid);
    }

    command uint16_t NeighborDiscovery.convertFloodsize(){
        return call Neighborhood.size();
    }
    command uint16_t NeighborDiscovery.getNeighbor(uint16_t position){
        uint16_t tempget = call Neighborhood.get(position);
        return tempget;
    }

}