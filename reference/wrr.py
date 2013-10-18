from sets import Set

# http://kb.linuxvirtualserver.org/wiki/Weighted_Round-Robin_Scheduling

def schedule(cw,gcd,maxi,index,queues):
  while True:
    index=(index+1) % len(queues)
    if index == 0:
      cw = cw - gcd
      if cw <= 0:
        cw = maxi
        if cw == 0:
          return None
    if queues[index][1] >= cw:
      return (queues[index][0],index,cw)

index = -1
cw = 0;
queues = [("MAC0",1),("MAC1",2),("MAC2",3),("MAC3",4)]
results = []
maxi = 127;
gcd=1

for i in range (0,1000):
  (result,index,cw) = schedule(cw,gcd,maxi,index,queues)
  results = results + [result]

unique_set = Set(results)
for res in unique_set:
  print "%s: serviced %s times " % (res,results.count(res))
