begin

  mountpoints = []
  # we show devices, but we avoid outputing duplicate devices
  devices = []
  Facter.add("mountpoints") do
    ignorefs = ["NFS", "nfs", "nfs4", "nfsd", "afs", "binfmt_misc", "proc", "smbfs", 
                "autofs", "iso9660", "ncpfs", "coda", "devpts", "ftpfs", "devfs", 
                "mfs", "shfs", "sysfs", "cifs", "lustre_lite", "tmpfs", "usbfs", "udf",
                "fusectl", "fuse.snapshotfs", "rpc_pipefs"]
    begin
      require 'filesystem'
    rescue Exception => e
      confine :kernel => :linux
      ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
      fs_source = nil
      if FileTest.exists?("/etc/mtab")
        fs_source = "/etc/mtab" 
      elsif FileTest.exists?("/proc/mounts")
        fs_source = "/proc/mounts" 
      end

      mounts = File.read(fs_source).split("\n")
      mounts.each do |mount|
        mount = mount.split(" ")
        if ((not ignorefs.include?(mount[2])) && (mount[3] !~ /bind/) && (not devices.include?(mount[0])) && (not mountpoints.include?(mount[1])))
	              mountpoints.push(mount[1])
        end
        devices.push(mount[0]) if not devices.include?(mount[0])
      end
    else
      FileSystem.mounts.each do |m| 
        if ((not ignorefs.include?(m.fstype)) && (m.options !~ /bind/) && !devices.include?(mount[0]))
          mountpoints.push(m.mount)
        end
        devices.push(m.mount) if not devices.include?(m.mount)
      end
    end
    setcode do
      mountpoints.join(",")
    end
  end
  Facter.add("devices") do
    setcode do
      devices.join(",")
    end
  end

rescue Exception => e
end
