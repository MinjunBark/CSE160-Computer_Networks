#ifndef TCP_Packet_H
#define TCP_Packet_H
#define NUM_SUPPORTED_PORTS 256

enum flag{

    URG = 0b100000;
    ACK = 0b010000;
    PSH = 0b001000;
    RST = 0b000100;
    SYN = 0b000010;
    FIN = 0b000001;

};

typedef nx_struct TCP_t {

    nx_uint16_t DestinationPort;
    nx_uint16_t SourcePort;
    nx_uint16_t seqNum;
    nx_uint16_t checkSum;
    nx_uint16_t flag;
    nx_uint16_t windowSize;
    nx_uint16_t payload[TCP_MAX_DATA_SIZE];
    nx_uint16_t ACK;
    nx_uint16_t header_length;
} TCP_t;

#endif
