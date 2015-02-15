require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MysqlService
      class Windows < Chef::Provider::MysqlService
        include MysqlCookbook::Helpers

        use_inline_resources if defined?(use_inline_resources)
        cache_path = Chef::Config[:file_cache_path]

        def whyrun_supported?
          true
        end

        action :create do
          log 'hello world'

          remote_file "#{cache_path}\\DSC Resource Kit.zip" do
            #source 'http://gallery.technet.microsoft.com/scriptcenter/DSC-Resource-Kit-All-c449312d/file/126120/1/DSC%20Resource%20Kit%20Wave%207%2009292014.zip'
            source 'https://gallery.technet.microsoft.com/scriptcenter/DSC-Resource-Kit-All-c449312d/file/131371/1/DSC%20Resource%20Kit%20Wave%209%2012172014.zip'
          end
          
          dsc_resource 'get-dsc-resource-kit' do
            resource :Archive
            property :ensure, 'Present'
            property :path, "#{cache_path}/DSC Resource Kit.zip"
            property :destination, "#{ENV['PROGRAMW6432']}/WindowsPowerShell/Modules"
          end
          
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
