# Homelab
## Let's gooooo
I'm kicking off the metamorphasis of my homelab. To date I've been running docker on a single appliance. It's worked well but I've run into the limitations associated with a single appliance, i.e. resiliancy. An individual service run inside a single container has a single point of failure. Containers going down for one reason or another has bummed me out.

A particularly painfull container to crash is my password manager. If the appliance running my docker containers goes offline so does my password manager. Getting the appliance back online often requires said passwords. I've bridged the issue by moving the password manager to a Digital Ocean droplet.

Hosted compute is great for scalability and flexibility, but it's expensive. The services I'm running don't require many resources and so it is more cost effective to run on my own hardware. Plus, it's a great learning opportunity.

## Hardware
My lab is currently running on a single Asustor AS6504T using docker. The Asustor hardware has a few ghosts in the machine but in general it's been excellent. The AS6504T has a 2.0/2.7GHz quad-core Intel Celeron J4125 CPU with 16GB of DDR4 RAM. I have it loaded with 3x12TB Seagate Ironwolf HDDs in a RAID5 for my bulk media storage, 2x500GB Western Digital Black SN750 NVMe SSDs in a RAID0 for my scratch disk, and a single 1TB Western Digital Black SN750 NVMe as a download and file server disk.

I'll be adding three HP EliteDesk G3 800 G3 minis to the stack. Each G3 has a quad core Intel i5-6600T and 16GB of DDR4 RAM.

## Backups
I try to adhere to the 3-2-1 rule of backups. 3 copies of everything, in 2 places, 1 of which is offsite. To that end my single NVMe drive and RAID0 scratch back themselves up using rsync to the RAID5 array every night. Then the RAID5 array is mirrored offsite to Backblaze B2 and Hetzner Storage Box. I check in on my B2 and Hetzner backups once a month to make sure they are up-to-date. I also make snapshots of the RAID arrays twice daily to protect mostly against careless deletions. I've had a few instances over the years where this backup plan has saved my bacon.