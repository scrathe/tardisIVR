## a tardis
![alt text](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisITX00.png?raw=true "tardisITX")
* Motherboard:  AsRock Z87E-ITX;  http://www.asrock.com/mb/Intel/Z87E-ITX/
* Case:  Lian-Li PC-Q25B;  http://www.lian-li.com/en/dt_portfolio/pc-q25/
  * supports 8 HDs in total.  however this Z87E-ITX only has SATA 6-ports onboard.
* CPU:  Intel Haswell i7-4770K + things learned about Haswell K
  * Haswell **does not support** older SandForce SSD 12xx/15xx controllers;  http://www.ocztechnologyforum.com/forum/showthread.php?111964-Vertex-2-Agility-2-and-Haswell
  * K **lacks** vPro/TXT/VT-d/SIPP/IOMMU support;  http://www.anandtech.com/show/7001/intels-haswell-quadcore-desktop-processor-skus
  * K overclocks to 4.0Ghz with stock Intel cooler, however runs **way** hotter than Ivy Bridge.  apparently no matter which low cost cooler you use, 100c temps are normal.
  * the Lian-Li Q25 keeps everything as chilly as possible.  less heat output than a PS3.
  * arctic silver thermal paste did not improve temps whatsoever.  yes i followed best practices applying thermal paste```ლ(́◉◞౪◟◉‵ლ)```
  * ended up assigning 6-cores (3 of the 4 real-cores) to my Linux guest that executes handbrake and it dropped the temps slightly
* 2 x 8GB RAM G.SKILL Ares 1866Mhz
* 1 x HighPoint RocketRAID 622 controller.  eSATA to SansDigital 4 x 2TB JBOD = RAID5
* 3 x 4TB HDD Seagate ST4000DM000 SATA 6Gb/s w/ Windows Storage Spaces
* 2 x (open) 3.5" SATA HD bays
* 1 x 256GB SDD ADATA MLC SATA 6Gb/s
  * bottom plate supports additional 2.5/3.5" mounts

#### pic below w/o power and cooler
![alt text](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisITX01.png?raw=true "tardisITX")

#### pic below w/ SilverStone SF55F-G power supply
![alt text](https://github.com/scrathe/tardisIVR/blob/master/graphics/tardisITX02.png?raw=true "tardisITX")
* Q25 supports full ATX power supplies and Lian-Li claims depth = 180 mm = 7.08 inches.  but this can't be possible.  maybe remove HD rack/backplane?
* SF55F-G = 5.52 inches
  * fully modular cables allow plenty of space
  * (did not use) short-cable kit;  http://www.newegg.com/Product/Product.aspx?Item=N82E16812162010
