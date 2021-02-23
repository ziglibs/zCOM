# zCOM Protocol Stacks

The zCOM library is there to provide a composable stack of protocols, down from osi layer 1 (e.g. [ethernet frames](https://en.wikipedia.org/wiki/Ethernet_frame), [IEEE_802.11](https://en.wikipedia.org/wiki/IEEE_802.11)) up to osi layer 7 ([DNS](https://en.wikipedia.org/wiki/Domain_Name_System), [DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol), [Tiny TP](https://en.wikipedia.org/wiki/Infrared_Data_Association#Tiny_TP), ...).

The library is designed in a way that you can stack each protocol onto a compatible protocol, for example serving Tiny TP over UDP instead of [IrLMP](https://en.wikipedia.org/wiki/Infrared_Data_Association#IrLMP) or use [PPP](https://en.wikipedia.org/wiki/Point-to-Point_Protocol) over a serial line.

## Goals

- Provide a general purpose implementation of a lot of link protocols
- Protocol implementations should be configurable so they are suitable for both high end machines (desktop, server) and embedded devices
  - This means that a protocol might require `comptime` configuration to restrict the number of allowed connections (for example, allow only up to 3 TCP connections to save RAM)
- Allow the use of *any* [physical layer](https://en.wikipedia.org/wiki/Physical_layer)
- Provide APIs that allows the use of `async`, but doesn't enforce it
- Make the APIs be usable for byte-by-byte inputs and don't require any specified packet size. Feeding a recording of 1 MB of data should work the same way as feeding a single byte.

## Project Status

The whole project is just in planning phase, no concrete implementation done yet.

## Supported Protocols

Each protocol with a tick is at least in a somewhat usable state

### Layer 1
- [ ] [Ethernet](https://en.wikipedia.org/wiki/Ethernet_frame)
- [ ] [IEEE802.11](https://en.wikipedia.org/wiki/802.11_Frame_Types) (WLAN)

### Layer 2
- [ ] [ARP](https://en.wikipedia.org/wiki/Address_Resolution_Protocol)
- [ ] [PPP](https://en.wikipedia.org/wiki/Point-to-Point_Protocol)
- [ ] [IrLAP](https://en.wikipedia.org/wiki/Infrared_Data_Association#IrLAP)

### Layer 3
- [ ] [IPv4](https://en.wikipedia.org/wiki/IPv4)
- [ ] [IPv6](https://en.wikipedia.org/wiki/IPv6)
- [ ] [ICMP](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)
- [ ] [IGMP](https://en.wikipedia.org/wiki/Internet_Group_Management_Protocol)
- [ ] [IrLMP](https://en.wikipedia.org/wiki/Infrared_Data_Association#IrLMP)

### Layer 4
- [ ] [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol)
- [ ] [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol)
- [ ] [Tiny TP](https://en.wikipedia.org/wiki/Infrared_Data_Association#Tiny_TP)

### Layer 7
- [ ] [DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol)
- [ ] [DNS](https://en.wikipedia.org/wiki/Domain_Name_System)
- [ ] [mDNS](https://en.wikipedia.org/wiki/Multicast_DNS)
- [ ] [NTP](https://en.wikipedia.org/wiki/Network_Time_Protocol)
- [ ] [PTP](https://en.wikipedia.org/wiki/Precision_Time_Protocol)




## Documents / Blogs / Further Reading

- https://www.saminiir.com/lets-code-tcp-ip-stack-1-ethernet-arp/
