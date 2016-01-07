# a sample program to use ipwhois to dump info about a random IP address

import random
import time
from time import sleep
from ipwhois import IPWhois
# from ipwhois.utils import get_countries
# only needed this for commented line about flattening later on
import OSC
import serial
import re

# scaling tool (no longer needed)
# from numpy import interp

# setup OSC communication
c = OSC.OSCClient()
c.connect(('127.0.0.1', 12000))
oscmsg = OSC.OSCMessage()

# setup serial communication
port = input('port: ')
baudrate = input('baudrate: ')
ser = serial.Serial(port, baudrate)

# for testing
# ser = serial.Serial('/dev/ttyACM1', 115200)

# regex string formatting pattern to check if serial has read correctly
pattern = re.compile("^(?:[0-9]{1,3}\.){3}[0-9]{1,3}..[0-9]{1,4}")

sleep(1)

i = 0
counter = 32

q = 0
# a while statement to make sure only proper lines of data are parsed
while q == 0:
    check = ser.readline()
    matched = pattern.match(check)
    if matched:
        result = check.split("__")
        q = 1
    else:
        print '_dropped_'
sw = 0
ipstring = result[0]
print result
# this all needs to be looked up now otherwise we will have errors later
obj = IPWhois(result[0])
results = obj.lookup()
parsed1 = results.items()
parsed2 = results['nets'][0].items()
parsed1.pop(8)
parsedfinal = parsed1 + parsed2
oscmsg = OSC.OSCMessage()
oscmsg.setAddress("/netinfo")
oscmsg.append(ipstring)
c.send(oscmsg)
# trigger switch for IP address scanning
while True:
    # i need to add a statement to check the formatting of the string
    q = 0
    while q == 0:
        check = ser.readline()
        matched = pattern.match(check)
        if matched:
            # print check
            result = check.split("__")
            q = 1
        else:
            print '_dropped_'

    # once a correct string has been read, take out the switch number
    sw = int(result[1])
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/currentip")
    oscmsg.append(result[0])
    c.send(oscmsg)
    if sw > 500:
        # creates a gap to stop rapid polling of whois
        if i > 40:
            # if enough time has elapsed, whois the new IP string
            obj = IPWhois(result[0])
            results = obj.lookup()
            parsed1 = results.items()
            parsed2 = results['nets'][0].items()
            parsed1.pop(8)
            parsedfinal = parsed1 + parsed2
            oscmsg = OSC.OSCMessage()
            oscmsg.setAddress("/netinfo")
            oscmsg.append(result[0])
            c.send(oscmsg)
            i = 0
            time.sleep(0.05)
        else:
            print 'don\'t shake so much!'
    else:
        if random.random() < 0.1:
            sq = random.randrange(len(parsedfinal))
            oscmsg = OSC.OSCMessage()
            oscmsg.setAddress("/whois")
            parsedfinal2 = str(parsedfinal[sq])
            oscmsg.append(parsedfinal2)
            c.send(oscmsg)
        i = i+1
