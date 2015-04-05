module AppManager
  class Site
    attr_reader :name, :port

    def initialize(name, port)
      @name   = name
      @port   = port
    end

    def self.next_port
      last_site = if all.empty?
                    self.new("null", 8000)
                  else
                    self.all.sort_by{|s| s.port}.last
                  end
      last_site.port + 1
    end

    def status
      if File.exists?(pid_file)
        'UP'
      else
        'DOWN'
      end
    end


    def start
      thin(:start)
    end

    def stop
      thin(:stop)
    end

    def save
      begin
        Dir.mkdir([AppManager.config.sites_path, handle].join('/'))
        Dir.mkdir([AppManager.config.sites_path, handle, 'config'].join('/'))
        Dir.mkdir([AppManager.config.sites_path, handle, 'log'].join('/'))

        config_file = File.open([AppManager.config.sites_path, handle, 'config', 'config.ru'].join('/'), 'a')
        create_config(config_file, name, port)

        thin_file = File.open([AppManager.config.sites_path, handle, 'config', 'thin.yml'].join('/'), 'a')
        create_thin(thin_file, name, port)
      rescue => e
        e
      end
    end

    def destroy
      begin
        if status == 'UP'
          raise Exception, "The server you are trying to destroy is still running."
        else
          FileUtils.rm_rf([AppManager.root, 'sites', "#{port}-#{name}"].join('/'))
          lines       = File.readlines(App.new.router_file)
          new_lines   = lines.reject {|l|
                            l == "#{name}.localhost: localhost:#{port}\n"
                        }
          router_file = File.open(App.new.router_file, 'w')
          new_lines.each { |new_line|
            router_file.write( new_line )
          }
          router_file.close
        end
      rescue => e
        e
      end
    end

    def self.all
      Dir.glob("#{AppManager.config.sites_path}/*").map do |site|
        x = site.split('/').last.split('-')
        name = x[1].to_s
        port = x[0].to_i
        Site.new(name, port)
      end
    end

    private


      def handle
        "#{port}-#{name}"
      end

      def pid_file
        pid_file = "#{AppManager.config.sites_path}/#{handle}/tmp/pids/#{port}.pid"
        pid_file
      end

      def thin(action)
        file = "#{AppManager.config.sites_path}/#{handle}/config/thin.yml"
        system("cat #{file}")

            system("
              thin -C #{file} --chdir #{AppManager.config.sites_path}/#{handle} #{action.to_s}
            ")


      end


    def create_config(file, name, port)
      File.open(file.to_path, 'a')
file << <<-eos
app = proc do |env|
  [ 200, {'Content-Type' => 'text/plain'}, ["Hello Rack! #{port}"] ]
end
run app
eos
      file.close
    end

    def create_thin(file, name, port)
      File.open(file.to_path, 'a')
file << <<-eos
---
pid: tmp/pids/#{port}.pid
port: #{port}
timeout: 20
wait: 20
log: log/thin.log
max_conns: 1024
require: []
environment: production
max_persistent_conns: 512
threaded: true
daemonize: true
tag: thin-#{port}
rackup: config/config.ru
eos
      file.close
    end

  end
end
