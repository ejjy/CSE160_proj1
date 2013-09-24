#ANDES Lab - University of California, Merced
#Author: UCM ANDES Lab
#Last Update: 2013/09/03

#! /usr/bin/python
from TOSSIM import *
from packet import *
import sys

t = Tossim([])
r = t.radio()
# Read topology file.
f = open("topo.txt", "r")
numNodes = int(f.readline());
#i = 0;
for line in f:
  #if i == 0:
    #i = i+1;
    #continue;
  s = line.split()
  if s:
    print " ", s[0], " ", s[1], " ", s[2];
    r.add(int(s[0]), int(s[1]), float(s[2]))

# Channels used for debuging
t.addChannel("genDebug", sys.stdout)
t.addChannel("cmdDebug", sys.stdout)
# Debug channels for project 1
t.addChannel("Project1F", sys.stdout)
t.addChannel("Project1N", sys.stdout);

# Get and Create a Noise Model
noise = open("no_noise.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in range(1, numNodes+1):
       t.getNode(i).addNoiseTraceReading(val)

for i in range(1, numNodes+1):
  print "Creating noise model for ",i;
  t.getNode(i).createNoiseModel()
for i in range(1, numNodes+1):
  t.getNode(i).bootAtTime(i*1055);
#t.getNode(1).bootAtTime(1000);
#t.getNode(2).bootAtTime(2333);


def package(string):
 	ints = []
	for c in string:
		ints.append(ord(c))
	return ints

def run(ticks):
	for i in range(ticks):
		t.runNextEvent()

def runTime(amount):
   i=0
   while i<amount*1000:
      t.runNextEvent() 
      i=i+1

#Create a Command Packet
msg = pack()
msg.set_seq(0)
msg.set_TTL(15)
msg.set_protocol(99)

pkt = t.newPacket()
pkt.setData(msg.data)
pkt.setType(msg.get_amType())

# COMMAND TYPES
CMD_PING = "0"
CMD_NEIGHBOR_DUMP = "1"

# Generic Command
def sendCMD(string):
   args = string.split(' ');
   msg.set_src(int(args[0]));
   msg.set_dest(int(args[0]));
   msg.set_protocol(99);
   payload=args[1]

   for i in range(2, len(args)):
      payload= payload + ' '+ args[i]
	
   msg.setString_payload(payload)
   
   pkt.setData(msg.data)
   pkt.setDestination(int(args[0]))
   
   #print "Delivering!"
   pkt.deliver(int(args[0]), t.time()+5)
   runTime(2);

def cmdPing(source, destination, msg):
   dest = chr(ord('0') + destination);
   sendCMD(str(source) +" "+ CMD_PING + dest + msg);
   
def cmdNeighborDump(source):
   sendCMD(str(source) + " " + CMD_NEIGHBOR_DUMP);

#runTime(1)
#cmdPing(1, 2, "Hello World!");
#runTime(5)   
#cmdPing(1, 3, "Hello 1 to 3");
runTime(5)
#cmdPing(1, 2, "Hello 1 to 2");
cmdPing(3, 5, "Hello 3 to 5");
#cmdPing(5, 1, "Hello 5 to 1");
cmdPing(5, 3, "Hello 5 to 3");
cmdPing(3, 6, "Hello 3 to 6");
cmdPing(6, 3, "Hello 6 to 3");
#cmdPing(1, 3, "Hello 1 to 3");
#cmdPing(1, 3, "Hello again");
cmdNeighborDump(3);
#cmdPing(1, 8, "Hello 1 to 8");
#cmdPing(2,10, "Hello 2 to 10");
t.getNode(2).turnOff();
runTime(30)
cmdNeighborDump(3);
runTime(10)
#cmdPing(2, 4, "Hello 2 to 4");
#runTime(2)
#cmdPing(3, 6, "Hello 3 to 6")