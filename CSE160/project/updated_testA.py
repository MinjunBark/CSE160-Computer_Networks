from TestSim import TestSim

def main():
    # Get simulation ready to run.
    s = TestSim();

    # Before we do anything, lets simulate the network off.
    s.runTime(1);

    # Load the the layout of the network.
    s.loadTopo("tuna-melt.topo");
    # s.loadTopo("pizza.topo");
    # s.loadTopo("long_line.topo");

    # Add a noise model to all of the motes.
    # s.loadNoise("no_noise.txt");
    s.loadNoise("some_noise.txt");
    # s.loadNoise("meyer-heavy.txt");

    # Turn on all of the sensors.
    s.bootAll();

    # Add the main channels. These channels are declared in includes/channels.h
    s.addChannel(s.COMMAND_CHANNEL);
    s.addChannel(s.GENERAL_CHANNEL);
    s.addChannel(s.TRANSPORT_CHANNEL);

    # Determine the "well known address" and "well known port" of the server
    well_known_mote = 1;
    well_known_port = 42;
    other_well_known_mote = 7;
    other_well_known_port = 99;

    # After sending a ping, simulate a little to prevent collision.
    s.runTime(60);
    s.testServer(well_known_mote,well_known_port); #needs two, node i connects to port j
    s.runTime(60);

    s.testClient(4,15,well_known_mote,well_known_port,150); # Client at Node 4 binds to port 15 and attempts to send data to Node 1 at port 2. How much data? 10 bytes.
    s.runTime(1);
    s.runTime(100);

    # Testing 1 Client with Many Connections to 1 Server:
    # s.testClient(4,23,well_known_mote,well_known_port,150);
    # s.runTime(1);
    # s.runTime(1000);

    # Testing 1 Client with Many Connections, 1 for each Server:
    # s.testServer(other_well_known_mote,other_well_known_port);
    # s.runTime(60);
    # s.testClient(4,92,other_well_known_mote,other_well_known_port,200);
    # s.runTime(1000);

    # Testing Many Clients Connecting to Server
    s.testClient(8,31,well_known_mote,well_known_port,200);
    s.runTime(1);
    s.runTime(10);

    s.testClient(5,64,well_known_mote,well_known_port,50);
    s.runTime(1);
    s.runTime(10);

    s.runTime(2000);

    #s.clientClose(4,12,1,2); #Should Fail; Client DNE
    s.runTime(1);
    #s.clientClose(4,15,well_known_mote,well_known_port); #Should Succeed
    s.runTime(300);

if __name__ == '__main__':
    main()
