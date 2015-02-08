module AppManager
  class Util
    def self.next_port
      (Site.all.last.port || 8000) + 1
    end
  end
end
