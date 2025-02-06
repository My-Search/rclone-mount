本教程以linux使用rcloud为目的
1、安装rcloud
```bash
curl https://rclone.org/install.sh | sudo bash
```
这里需要下载windows的客户端，用于后面进行授权获取token信息使用：在windows上[下载](https://rclone.org/downloads/)
具体已在下面第二步用到的地方进行注释写了使用的方法。

2、rcloud配置一个cloud
以OneDrive为例，其它具体请自行学习
以下是配置的整个流程：
```bash
[root@racknerd-2806d45 rclone]# rclone config
2025/02/06 02:11:00 NOTICE: Config file "/root/.config/rclone/rclone.conf" not found - using defaults
No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n

Enter name for new remote.
name> OneDrive

Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
 1 / 1Fichier
   \ (fichier)
 2 / Akamai NetStorage
   \ (netstorage)
 3 / Alias for an existing remote
   \ (alias)
 4 / Amazon S3 Compliant Storage Providers including AWS, Alibaba, ArvanCloud, Ceph, ChinaMobile, Cloudflare, DigitalOcean, Dreamhost, GCS, HuaweiOBS, IBMCOS, IDrive, IONOS, LyveCloud, Leviia, Liara, Linode, Magalu, Minio, Netease, Outscale, Petabox, RackCorp, Rclone, Scaleway, SeaweedFS, Selectel, StackPath, Storj, Synology, TencentCOS, Wasabi, Qiniu and others
   \ (s3)
 5 / Backblaze B2
   \ (b2)
 6 / Better checksums for other remotes
   \ (hasher)
 7 / Box
   \ (box)
 8 / Cache a remote
   \ (cache)
 9 / Citrix Sharefile
   \ (sharefile)
10 / Cloudinary
   \ (cloudinary)
11 / Combine several remotes into one
   \ (combine)
12 / Compress a remote
   \ (compress)
13 / Dropbox
   \ (dropbox)
14 / Encrypt/Decrypt a remote
   \ (crypt)
15 / Enterprise File Fabric
   \ (filefabric)
16 / FTP
   \ (ftp)
17 / Files.com
   \ (filescom)
18 / Gofile
   \ (gofile)
19 / Google Cloud Storage (this is not Google Drive)
   \ (google cloud storage)
20 / Google Drive
   \ (drive)
21 / Google Photos
   \ (google photos)
22 / HTTP
   \ (http)
23 / Hadoop distributed file system
   \ (hdfs)
24 / HiDrive
   \ (hidrive)
25 / ImageKit.io
   \ (imagekit)
26 / In memory object storage system.
   \ (memory)
27 / Internet Archive
   \ (internetarchive)
28 / Jottacloud
   \ (jottacloud)
29 / Koofr, Digi Storage and other Koofr-compatible storage providers
   \ (koofr)
30 / Linkbox
   \ (linkbox)
31 / Local Disk
   \ (local)
32 / Mail.ru Cloud
   \ (mailru)
33 / Mega
   \ (mega)
34 / Microsoft Azure Blob Storage
   \ (azureblob)
35 / Microsoft Azure Files
   \ (azurefiles)
36 / Microsoft OneDrive
   \ (onedrive)
37 / OpenDrive
   \ (opendrive)
38 / OpenStack Swift (Rackspace Cloud Files, Blomp Cloud Storage, Memset Memstore, OVH)
   \ (swift)
39 / Oracle Cloud Infrastructure Object Storage
   \ (oracleobjectstorage)
40 / Pcloud
   \ (pcloud)
41 / PikPak
   \ (pikpak)
42 / Pixeldrain Filesystem
   \ (pixeldrain)
43 / Proton Drive
   \ (protondrive)
44 / Put.io
   \ (putio)
45 / QingCloud Object Storage
   \ (qingstor)
46 / Quatrix by Maytech
   \ (quatrix)
47 / SMB / CIFS
   \ (smb)
48 / SSH/SFTP
   \ (sftp)
49 / Sia Decentralized Cloud
   \ (sia)
50 / Storj Decentralized Cloud Storage
   \ (storj)
51 / Sugarsync
   \ (sugarsync)
52 / Transparently chunk/split large files
   \ (chunker)
53 / Uloz.to
   \ (ulozto)
54 / Union merges the contents of several upstream fs
   \ (union)
55 / Uptobox
   \ (uptobox)
56 / WebDAV
   \ (webdav)
57 / Yandex Disk
   \ (yandex)
58 / Zoho
   \ (zoho)
59 / iCloud Drive
   \ (iclouddrive)
60 / premiumize.me
   \ (premiumizeme)
61 / seafile
   \ (seafile)
Storage> 36

Option client_id.
OAuth Client Id.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_id> 

Option client_secret.
OAuth Client Secret.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret> 

Option region.
Choose national cloud region for OneDrive.
Choose a number from below, or type in your own value of type string.
Press Enter for the default (global).
 1 / Microsoft Cloud Global
   \ (global)
 2 / Microsoft Cloud for US Government
   \ (us)
 3 / Microsoft Cloud Germany
   \ (de)
 4 / Azure and Office 365 operated by Vnet Group in China
   \ (cn)
region> 1

Option tenant.
ID of the service principal's tenant. Also called its directory ID.
Set this if using
- Client Credential flow
Enter a value. Press Enter to leave empty.
tenant> 

Edit advanced config?
y) Yes
n) No (default)
y/n> n

Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n> n

Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
        rclone authorize "onedrive"
Then paste the result.
Enter a value.
#### 这里需要打开你的windows，以命令行方式：`.\rclone.exe authorize "onedrive"` , 会在你的windows上打开浏览器，你需要登录OneDrive进行授权，授权成功后返回命令行窗口，得到一个JSON,全部复制！
config_token> {"access_token":"...这里已被我删除..","token_type":"Bearer","refresh_token":"..这里已被我删除..","expiry":"2025-02-06T15:40:34.9969175+08:00"}

Option config_type.
Type of connection
Choose a number from below, or type in an existing value of type string.
Press Enter for the default (onedrive).
 1 / OneDrive Personal or Business
   \ (onedrive)
 2 / Root Sharepoint site
   \ (sharepoint)
   / Sharepoint site name or URL
 3 | E.g. mysite or https://contoso.sharepoint.com/sites/mysite
   \ (url)
 4 / Search for a Sharepoint site
   \ (search)
 5 / Type in driveID (advanced)
   \ (driveid)
 6 / Type in SiteID (advanced)
   \ (siteid)
   / Sharepoint server-relative path (advanced)
 7 | E.g. /teams/hr
   \ (path)
config_type> 1

Option config_driveid.
Select drive you want to use
Choose a number from below, or type in your own value of type string.
Press Enter for the default (b!ZzCndpMgSEqYqLSxSXcPR-i_mTQZG4JPvXZUOOGOvuh8G_FVCIqqQJn0HLjmtNL-).
 1 / AEEE102E-CFF8-4E2A-89C6-03841FF83500 (personal)
   \ (b!ZzCndpMgSEqYqLSxSXcPR-i_mTQZG4JPvXZUOOGOvuh8G_FVCIqqQJn0HLjmtNL-)
 2 / Bundles_b896e2bb7ca3447691823a44c4ad6ad7 (personal)
   \ (BE4A09E067638EA9)
 3 / ODCMetadataArchive (personal)
   \ (b!ZzCndpMgSEqYqLSxSXcPR-i_mTQZG4JPvXZUOOGOvuht9itUFfTkTrBFxLiBEGrq)
 4 / OneDrive (personal)
   \ (BE4A09E067638EA9)
config_driveid> 4

Drive OK?

Found drive "root" of type "personal"
URL: https://onedrive.live.com?cid=BE4A09E067638EA9&id=01VCHO3UV6Y2GOVW7725BZO354PWSELRRZ

y) Yes (default)
n) No
y/n> 

Configuration complete.
Options:
- type: onedrive
- token: {"access_token":"...这里已被我删除..","token_type":"Bearer","refresh_token":"..这里已被我删除..","expiry":"2025-02-06T15:40:34.9969175+08:00"}
- drive_id: BE4A09E067638EA9
- drive_type: personal
Keep this "OneDrive" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> 

Current remotes:

Name                 Type
====                 ====
OneDrive             onedrive

e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> 
```

到这里你就完成了配置，你就可以使用rclone的命令来进行copy本地文件到配置的云盘平台上了。
