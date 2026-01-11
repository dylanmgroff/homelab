ssh -tt dylangroff@10.9.50.21 -i /home/dylangroff/.ssh/manlyswarm sudo su
ssh -tt dylangroff@10.9.50.22 -i /home/dylangroff/.ssh/manlyswarm sudo su
ssh -tt dylangroff@10.9.50.23 -i /home/dylangroff/.ssh/manlyswarm sudo su
ssh -tt dylangroff@10.9.50.24 -i /home/dylangroff/.ssh/manlyswarm sudo su
ssh -tt dylangroff@10.9.50.25 -i /home/dylangroff/.ssh/manlyswarm sudo su
ssh -tt dylangroff@10.9.50.26 -i /home/dylangroff/.ssh/manlyswarm sudo su


systemctl disable glusterd
systemctl stop glustered
NEEDRESTART_MODE=a apt remove software-properties-common glusterfs-server -y
rm -rf /var/lib/glusterd
shutdown -r now


NEEDRESTART_MODE=a apt install software-properties-common glusterfs-server -y
systemctl start glusterd
systemctl enable glusterd
mkdir -p /gluster/volume1


gluster peer probe 10.9.50.21; gluster peer probe 10.9.50.22; gluster peer probe 10.9.50.23; gluster peer probe 10.9.50.24; gluster peer probe 10.9.50.25; gluster peer probe 10.9.50.26;
gluster volume create staging-gfs replica 6 10.9.50.21:/gluster/volume1 10.9.50.22:/gluster/volume1 10.9.50.23:/gluster/volume1 10.9.50.24:/gluster/volume1 10.9.50.25:/gluster/volume1 10.9.50.26:/gluster/volume1 force
gluster volume start staging-gfs
chmod 666 /var/run/docker.sock
docker node update --label-add worker=true pveds-n01-w01
docker node update --label-add worker=true pveds-n02-w02
docker node update --label-add worker=true pveds-n03-w03


echo 'localhost:/staging-gfs /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab
mount.glusterfs localhost:/staging-gfs /mnt
chown -R root:docker /mnt