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

          template 'c:\check_me_out.txt' do
            variables(:config => new_resource)
            source 'check_me_out.erb'
            cookbook 'mysql'
            action :create
          end

          remote_file "#{cache_path}\\DSC Resource Kit.zip" do
            source 'https://gallery.technet.microsoft.com/scriptcenter/DSC-Resource-Kit-All-c449312d/file/131371/1/DSC%20Resource%20Kit%20Wave%209%2012172014.zip'
            checksum "7eeb0563bc9a82a1fcfb0f991d027192b45788eeaf2263fc1b0836c46c5d1dd8"
          end

          dsc_resource 'get-dsc-resource-kit' do
            resource :Archive
            property :ensure, 'Present'
            property :path, "#{cache_path}/DSC Resource Kit.zip"
            property :destination, "#{ENV['PROGRAMW6432']}/WindowsPowerShell/Modules"
          end

          directory "#{cache_path}/mysql" do
            recursive true
            action :create
          end

          template "#{cache_path}/mysql/derp.ps1" do
            cookbook 'mysql'
            source 'derp.ps1.erb'
            variables(
              :work_dir => cache_path,
              :mysql_name => mysql_name,
              :node_name => 'localhost',
              :ps_dsc_allow_plain_text_password => 'TRUE',
              :package_product_id => '{437AC169-780B-47A9-86F6-14D43C8F596B}',
              :package_uri => 'http://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-5.6.17.0.msi',
              :initial_root_password => new_resource.initial_root_password,
              )
            action :create
          end

          powershell_script "Use DSC to install mysql" do
            cwd "#{cache_path}/mysql"
            command ". ./derp.ps1"
            # FIXME: not_if { something }
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
