## my tardis
* Motherboard:  AsRock Z87E-ITX
* Case:  Lian-Li PC-Q25B; http://www.lian-li.com/en/dt_portfolio/pc-q25/
  * supports 8 HDs in total.  however this Z87E-ITX only has 6-ports.  seems most ITX motherboards have 4-ports.
* CPU:  Intel Haswell i7-4770K + things i learned about Haswell K
  * Haswell **does not support** older SandForce 12xx SSD drives
  * K does not support VT-d/IOMMU CPU instructions
  * K overclocks to 4.0Ghz with stock Intel cooler however runs much hotter than Ivy Bridge.  apparently no matter which low cost cooler you use, 100c temps are normal.
  * the Lian-Li Q25 keeps everything as chilly as possible.  less ambient heat output than a PS3.
  * arctic silver thermal paste did not improve temps whatsoever.  yes i followed best practices applying thermal paste ;)
  * i ended up assigning 6-cores (3 of the 4 real-cores) to my Linux guest that executes handbrake and it dropped the temps ~72-82c

### pic below w/o power and cooler
* 2 x 8GB RAM G.SKILL Ares 1866Mhz
* 1 x HighPoint RocketRAID 622 controller.  eSATA to SansDigital 4 x 2TB JBOD = RAID5
* 3 x 4TB HDD Seagate ST4000DM000 SATA 6Gb/s w/ Windows Storage Spaces
  * still learning about Storage Spaces
* 2 x (open) 3.5" SATA HD bays
* 1 x 256GB SDD ADATA MLC SATA 6Gb/s
  * bottom plate supports additional 2.5/3.5" mounts

![alt text](https://github.com/scrathe/tardisIVR/blob/master/files/tardisITX01.png?raw=true "tardisITX")

### pic below w/power
* Lian-Li claims power supply depth = 180 mm = 7.08 inches (w/o HD backplane?)
* SilverStone SF55F-G 550W = 5.52 inches
  * fully modular cables allow plenty of space.  i did not use the short-cable kit; http://www.newegg.com/Product/Product.aspx?Item=N82E16812162010  however i imagine it would be required for single/dual slot PCIe GPU.

![alt text](https://github.com/scrathe/tardisIVR/blob/master/files/tardisITX02.png?raw=true "tardisITX")
