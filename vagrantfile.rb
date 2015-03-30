Vagrant.require_version ">= 1.7.2"

def require_plugin(name)
  unless Vagrant.has_plugin?(name)
    raise <<-EOT.strip
      #{name} plugin required. Please run: "vagrant plugin install #{name}"
    EOT
  end
end

require_plugin 'vagrant-parallels'
require_plugin 'vagrant-triggers'

Vagrant.configure("2") do |config|
    config.ssh.shell = "sh"
    config.ssh.username = "docker"
    config.ssh.password = "tcuser"
    config.ssh.insert_key = true

    config.vm.synced_folder ".", "/vagrant", :disabled => true

    config.vm.synced_folder Dir.home, Dir.home, type: "nfs", mount_options: [
        "nolock",
        "vers=3",
        "udp"
    ]

    config.vm.provider :parallels do |p|
        p.name = "boot2docker"
        p.cpus = (`sysctl -n hw.ncpu`).to_i
        p.memory = (`sysctl -n hw.memsize`).to_i / (1024 * 1024 * 8)
        p.optimize_power_consumption = false
        p.check_guest_tools          = false
        p.update_guest_tools         = false
        p.functional_psf             = false
        p.customize "pre-boot", [
            "set", :id,
            "--device-set", "cdrom0",
            "--image", File.expand_path("../boot2docker.iso", __FILE__),
            "--enable", "--connect"
        ]
        p.customize "pre-boot", [
            "set", :id,
            "--device-bootorder", "cdrom0 hdd0"
        ]
    end

    config.trigger.after [:up, :resume] do
        info "Making the Docker TLS certs available to the host."
        run_remote <<-EOT.prepend("\n\n") + "\n"
            DOCKER_PID=/var/run/docker.pid
            if [ ! -f "$DOCKER_PID" ]; then
                echo "---> Waiting for for Docker daemon to spin up."
                while [ ! -f "$DOCKER_PID" ]; do
                    echo .
                    sleep 1
                done
            fi
            cp -r /home/docker/.docker "#{Dir.pwd}"
        EOT
    end

    config.trigger.after [:destroy, :suspend, :halt] do
        info "Removing docker TLS certs from host."
        run "rm -rf .docker"
    end

    config.trigger.after [:up, :resume] do
        info "Adjusting datetime."
        run_remote <<-EOT.prepend("\n\n") + "\n"
            timeout -t 15 sudo /usr/local/bin/ntpclient -s -h pool.ntp.org
            date
        EOT
    end

    config.trigger.after [:up, :resume] do
        info "Building .env file."
        system <<-EOT.prepend("\n\n") + "\n"
            docker_host_ip="$(vagrant ssh-config | sed -n 's/[ ]*HostName[ ]*//gp')"
            [[ -z "$docker_host_ip" ]] && exit 1
            echo > .env
            echo export DOCKER_HOST_IP="$docker_host_ip" >> .env
            echo export DOCKER_HOST="tcp://${docker_host_ip}:2376" >> .env
            echo export DOCKER_TLS_VERIFY=1 >> .env
            echo export DOCKER_CERT_PATH=\\"$PWD/.docker\\" >> .env
        EOT
    end

    config.trigger.after [:up, :resume] do
        info "Run `source .env` to set docker environment variables."
    end

    config.trigger.after [:destroy, :suspend, :halt] do
        info "Removing .env file."
        run "rm -f .env"
    end

end
