require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MysqlService
      class Windows < Chef::Provider::MysqlService
        include MysqlCookbook::Helpers

        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          log 'hello world'          
        end

        action :delete do
        end

        action :start do
        end

        action :stop do
        end

        action :reload do
        end
      end
    end
  end
end
