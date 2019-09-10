module Puerta

  class Config
    attr_accessor :env

    def env
      @env || :sandbox
    end

    def sandbox?
      env.to_s == 'sandbox'
    end

    def production?
      env.to_s == 'production'
    end

  end
end
