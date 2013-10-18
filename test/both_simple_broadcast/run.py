#!/bin/env python

from NFTest import *
from reg_defines_wrr_switch import *

phy2loop0 = ('../connections/conn', [])

nftest_init(sim_loop = [], hw_config = [phy2loop0])
nftest_start()

routerMAC = []
routerIP = []
for i in range(4):
    routerMAC.append("00:ca:fe:00:00:0%d"%(i+1))
    routerIP.append("192.168.%s.40"%i)

num_broadcast = 10

mac1_weight = 0x1;
nftest_regwrite(IN_ARB_MAC1_QUEUE_WEIGHT_REG(),mac1_weight);

pkts = []
for i in range(num_broadcast):
    pkt = make_IP_pkt(src_MAC="aa:bb:cc:dd:ee:ff", dst_MAC=routerMAC[i%4],
                      EtherType=0x800, src_IP="192.168.0.1",
                      dst_IP=routerIP[i%4], pkt_len=100)

    nftest_regread_expect(IN_ARB_MAC1_QUEUE_WEIGHT_REG(),mac1_weight);
    nftest_send_phy('nf2c0', pkt)
    nftest_send_phy('nf2c1', pkt)
    nftest_expect_phy('nf2c1', pkt)
    nftest_expect_phy('nf2c0', pkt)
#    if not isHW():
#        nftest_expect_phy('nf2c2', pkt)
#        nftest_expect_phy('nf2c3', pkt)

nftest_barrier()

total_errors = 0

#tmp = nftest_regread_expect(reg_defines.MAC_GRP_1_TX_QUEUE_NUM_PKTS_SENT_REG(), num_broadcast)
#tmp = nftest_regread_expect(reg_defines.MAC_GRP_2_TX_QUEUE_NUM_PKTS_SENT_REG(), num_broadcast)
#tmp = nftest_regread_expect(reg_defines.MAC_GRP_3_TX_QUEUE_NUM_PKTS_SENT_REG(), num_broadcast)
#tmp = nftest_regread_expect(reg_defines.SWITCH_OP_LUT_NUM_MISSES_REG(), num_broadcast)

nftest_finish()
