**The differences and similarities between HA VPN and NCC**

HA vpn establishes secure, encrypted IPsec VPN tunnels to Google Cloud.  And NNC(Network Connectivity Center) manages connectivity topology across VPCs and hybrid sites using a centralized hub.  They both use cloud router and can work in hybrid integration situtions thats how they are similar to each other.  Outside of that they both do completely different things and serve 2 different functions

**The use cases of HA VPN vs NCC**

HA VPN is used for workloads of high importance and need, along with being fault tolernant, if an issue araises and recovery is needed.  NCC is used for connecting multiple vpc networks together which allows private routing amongest them, it also integrates third-party Security Service Edge (SSE) providers

**The use cases of the Network Intelligence Center**

Its a console for Google Cloud network observability, monitoring, and troubleshooting, with real-time performance metrics with ensured high availability and preventing performance impact by proactively detecting network problems or misconfigurations

# References

[HA VPN](https://docs.cloud.google.com/network-connectivity/docs/vpn/concepts/overview#ha-vpn)

[Network Intelligence Center](https://cloud.google.com/network-intelligence-center?hl=en)

[Connectivity Tests](https://docs.cloud.google.com/network-intelligence-center/docs/connectivity-tests/concepts/overview)

[NCC](https://docs.cloud.google.com/network-connectivity/docs/network-connectivity-center/concepts/overview)