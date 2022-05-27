#include "../../includes/packet.h"
#include "../../includes/socket.h"
// #include "../../includes/Routing.h"
#include "../../includes/TCP_Packet.h"
#include "../../includes/protocol.h"
#include "../../includes/channels.h"
#include <Timer.h>

module TransportP
{
	provides interface Transport;
	uses interface SimpleSend as Sender;
	// uses interface Receive as Receiver;
	// uses interface Packet;
    // uses interface AMPacket;
    uses interface Routing;
	uses interface Timer<TMilli> as ServerTimer;
    uses interface Timer<TMilli> as ClientTimer;
    uses interface Random;
	uses interface Hashmap<socket_store_t> as SocketStorage;  //added
}

implementation{
    // socket_store_t ServerAcceptSocket;
    // socket_store_t ClientAcceptSocket;
    
    void makeTCPPack(TCP_t* TCP, uint16_t src, uint16_t dest, uint16_t seq, uint16_t flag, uint16_t windowSize, uint16_t* payload, uint16_t protocol, uint16_t L);
    void makePack(pack * Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t * payload, uint8_t length);
    TCP_t* TPack;
    pack packet_temp;





    command socket_t Transport.socket(){ //creating sockets 
        uint16_t i;
        for(i = 1; i < 255; i++){ //max mem for uint8 //start at 1 because it should return 0 
           if(call SocketStorage.contains(i) == FALSE){ //checks every number till it gets to scoket storage
               return i;
           }
        }
        return 0;//null
    }

    command error_t Transport.bind(socket_t fd, socket_addr_t *addr){ //initializing socket 
        socket_store_t bindSocket;
        bindSocket.flag = 0;
        bindSocket.state = CLOSED;
        bindSocket.src = addr->port;
        bindSocket.dest.addr = 0;
        bindSocket.dest.port = 0;
        //bind socket records address to socket as source 

        // This is the sender portion.
        //
        bindSocket.lastWritten = 0;
        bindSocket.lastAck = 0;
        bindSocket.lastSent = 0;

        // This is the receiver portion
        bindSocket.lastRead = 0;
        bindSocket.lastRcvd = 0;
        bindSocket.nextExpected = 0;

        bindSocket.RTT = 0;
        bindSocket.effectiveWindow = 0;

        call SocketStorage.insert(fd,bindSocket);//inserting socket to socket storage with fd 
        return fd; //fd is key

    }

    command socket_t Transport.accept(socket_t fd){//when 1 soccet wants to make a connection with another. accept connection A to B port 
        socket_store_t CopyAcceptSocket = call SocketStorage.get(fd);//listening server
        socket_store_t ServerAcceptSocket = call SocketStorage.get(fd); //talks to client server
        uint16_t fd1;
        // socket_t fd;
        CopyAcceptSocket.state = LISTEN;
        CopyAcceptSocket.src;
        CopyAcceptSocket.dest.port = 0;
        CopyAcceptSocket.dest.addr = 0; // client
        //call SocketStorage.insert(fd1, CopyAcceptSocket); //changing copy to listen 
       // socket_store_t ServerAcceptSocket;
        ServerAcceptSocket.state = SYN_RCVD;
        // ServerAcceptSocket.dest.port = ;
        // ServerAcceptSocket.dest.addr = ;
        // uint16_t fd1;
        fd1 = call Transport.socket();
       call SocketStorage.insert(fd, CopyAcceptSocket);
       call SocketStorage.insert(fd1, ServerAcceptSocket);

//do theses
        //make TCP (SYN + ACK)
        makePack(&TPack, TOS_NODE_ID, dest->addr, seq,flag, windowSize,uint16_t* &TPack + i ,0, L);
        //send TCP
        SendTCP(ServerAcceptSocket[fd], dest->addr);


    }

    command uint16_t Transport.write(socket_t fd, uint8_t *buff, uint16_t bufflen){ //need help 
       socket_store_t writeSocket = call SocketStorage.get(fd);
       TCP_t* writePack;
       //writeSocket.sendBuff
       writeSocket.sendBuff[&buff];
       //use memcpy()
       memcpy(writePack->fd, writeSocket.sendBuff, writeSocket.lastWritten);
       return writeSocket.bufflen;//return amount of byte you wrote (bufflen) or amount of space left 
       call SocketStorage.insert(fd,writeSocket); //reinsert writesocket to socketstorage  //look at line 90

    /**
    * This will pass the packet so you can handle it internally. 
    * @param
    *    pack *package: the TCP packet that you are handling.
    * @Side Client/Server 
    * @return uint16_t - return SUCCESS if you are able to handle this
    *    packet or FAIL if there are errors.
    */
    }

    command error_t Transport.receive(pack* package){ //need help  hella long
        socket_store_t ReceiveSocket = call SocketStorage.get(fd);
        // memcpy(&TPack, &package->payload, PACKET_MAX_PAYLOAD_SIZE);

        switch{

            case 1:
                if()
                //if state is closed
            case 2:
                if()
                //if state is ESTABLISHED
            case 3:
                if()
                //if state is LISTEN
            case 4:
                if()
                //if state is SYN_SENT
            case 5:
                if()
                //if state is SYN_RECIEVED
        }   




        //if statements to 
        //switch case 
    }

    command uint16_t Transport.read(socket_t fd, uint8_t *buff, uint16_t bufflen){ //opposite of write
    
       socket_store_t ReadSocket = call SocketStorage.get(fd);
       TCP_t* readPack;

       ReadSocket.rcvdBuff[&buff];
       memcpy(readPack->fd, ReadSocket.rcvdBuff, ReadSocket.lastRead);
       return readsocket.bufflen;//return amount of byte you wrote (bufflen) or amount of space left 
       call SocketStorage.insert(fd,ReadSocket); //reinsert writesocket to socketstorage  //look at line 90
       //READSocket.READBuff
       //use memcpy(buff, readsocket.rcvdBuff , bufflen) // 

       //return amount of byte you wrote (bufflen) or amount of space left 
        //reinsert writesocket to socketstorage  //look at line 90


        /**
    * Attempts a connection to an address.
    * @param
    *    socket_t fd: file descriptor that is associated with the socket
    *       that you are attempting a connection with. 
    * @param
    *    socket_addr_t *addr: the destination address and port where
    *       you will atempt a connection.
    * @side Client
    * @return socket_t - returns SUCCESS if you are able to attempt
    *    a connection with the fd passed, else return FAIL.
    */
    }

    command error_t Transport.connect(socket_t fd, socket_addr_t * addr){//
        // dbg(TRANSPORT_CHANNEL, "connect worksss");
        socket_store_t connectSocket = call SocketStorage.get(fd);
        
        //diagram 

        if(connectSocket.state == CLOSED){//if state is closed 
            connectSocket.state = SYN_SENT; 
            makeTCPPack(TCP_t* TCP, uint16_t src, uint16_t dest, uint16_t seq, uint16_t flag, uint16_t windowSize, uint16_t* payload, uint16_t protocol, uint16_t L);
            SendTCP(ServerAcceptSocket[fd], dest->addr);
            //if state is closed send SYN packet to addr and 
        }else{
            return FAIL;
        }
    }
          /**
    * Attempts a connection to an address.
    * @param
    *    socket_t fd: file descriptor that is associated with the socket
    *       that you are attempting a connection with. 
    * @param
    *    socket_addr_t *addr: the destination address and port where
    *       you will atempt a connection.
    * @side Client
    * @return socket_t - returns SUCCESS if you are able to attempt
    *    a connection with the fd passed, else return FAIL.
    */
    
    //check out video
    command error_t Transport.close(socket_t fd){//cuts of connection //in diagram
        socket_store_t CloseSocket = call SocketStorage.get(fd);
        TCP_t closePack;
       // makeTCPPack(&closePack, CloseSocket.src, CloseSocket.dest.port, uint16_t seq, uint16_t FIN, uint16_t windowSize, uint16_t* payload, uint16_t protocol, uint16_t L) //watch video
        if(CloseSocket.state == ESTABLISHED){
            if(CloseSocket.state == FIN){
                makeTCPPack(&closePack, CloseSocket.src, CloseSocket.dest.port, uint16_t seq, FIN, CloseSocket.windowSize, "", 0) //watch video
                SendTCP(closePack, dest->addr);
                CloseSocket.state = FIN_WAIT_1;
            }
            if(CloseSocket.state == CLOSE_WAIT){
                SendTCP(closePack, dest->addr);
                CloseSocket.state = lastAck;
            }
            if(CloseSocket.state == CLOSING){
                SendTCP(closePack, dest->addr);
                CloseSocket.state = TIME_WAIT;
            }
        }else{
            CloseSocket.state = CLOSED;
        }
/**
    * Closes the socket.
    * @param
    *    socket_t fd: file descriptor that is associated with the socket
    *       that you are closing. 
    * @side Client/Server
    * @return socket_t - returns SUCCESS if you are able to attempt
    *    a closure with the fd passed, else return FAIL.
    */
    }

    command error_t Transport.release(socket_t fd){//optional
        // dbg(TRANSPORT_CHANNEL, "RELEASE WORKS");
        //socket_store_t releaseSocket = call SocketStorage.get(fd);
        /**

        //call socket and remove fd from it 





    * Listen to the socket and wait for a connection.
    * @param
    *    socket_t fd: file descriptor that is associated with the socket
    *       that you are hard closing. 
    * @side Server
    * @return error_t - returns SUCCESS if you are able change the state 
    *   to listen else FAIL.
    */
    }

    command error_t Transport.listen(socket_t fd){//done?
        socket_store_t listentSocket[MAX_NUM_OF_SOCKETS];
        if(fd == 0 || fd > MAX_NUM_OF_SOCKETS){ //checks for socket 
            return FAIL;
        }

        if(listentSocket[fd-1].state == ESTABLISHED){ //if socket is bound
            listentSocket.state = LISTEN; //sock = LISTEN
            return SUCCESS; //Add socket to hashmap

        }else{//Else fail
            return FAIL;
        }
        /**
    * Listen to the socket and wait for a connection.
    * @param
    *    socket_t fd: file descriptor that is associated with the socket
    *       that you are hard closing. 
    * @side Server
    * @return error_t - returns SUCCESS if you are able change the state 
    *   to listen else FAIL.
    */
    }

    //makes the tcp packets and send it 
    void SendTCP(TCP_t TPack, socket_addr_t* dest){
        uint16_t i; 
        uint16_t L = 0;
        socket_store_t sendTcpStorage;
        for(i = 0; i < sizeof(TCP_t);i+=L){
            L = 18;
            if(sizeof(TCP_t) - i < PACKET_MAX_PAYLOAD_SIZE){
                L = sizeof(TCP_t) - i;
            }else{
                L = PACKET_MAX_PAYLOAD_SIZE;
            }
            makePack(&TPack, TOS_NODE_ID, dest->addr, seq,flag, windowSize,uint16_t* &TPack + i ,0, L); //ask about this ???
            SocketStorage.payload[18] = i;
            SocketStorage.payload[19] = L;
            call Routing.send(TPack,dest->addr);
        }
    }

    void makeTCPPack(TCP_t* TCP, uint16_t src, uint16_t dest, uint16_t seq, uint16_t flag, uint16_t windowSize, uint16_t* payload, uint16_t L){ //switch seq and protocol
        TCP->src = src; //node it came from 
        TCP->dest = dest; //node it wants to go to 
        TCP->seq = seq; // time to live
        // TCP->ACK = ACK; // ID# of packes
        TCP->flag = flag; //request/ reply
        flag = SYN;
        TCP->windowSize = windowSize;
        TCP->payload = payload;
        // TCP->protocol = protocol;
        TCP->header_length = L;
        memcpy(TCP->payload, payload, L);
       // checkSum = src + seq + ack + bindSocket + flag + payload + L + windowSize + //payload is message ? 
	}
    void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t seq, uint16_t protocol, uint8_t* payload, uint8_t length){ //switch seq and protocol
        Package->src = src; //node it came from 
        Package->dest = dest; //node it wants to go to 
        Package->TTL = TTL; // time to live
        Package->seq = seq; // ID# of packes
        Package->protocol = protocol; //request/ reply
        memcpy(Package->payload, payload, length); //payload is message ? 
    }

}

