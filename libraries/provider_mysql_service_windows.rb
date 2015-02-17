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

              :initial_root_password => new_resource.initial_root_password,
              )
            action :create
          end

          package_uri = 'http://dev.mysql.com/get/Downloads/MySQLInstaller/mysql-installer-community-5.6.17.0.msi'

          dsc_script "install-#{mysql_name}" do
            #property :ensure, 'Present'
            cwd "#{cache_path}/mysql"
            configuration_data <<-EOS
            @{
              AllNodes = @(
                @{
                  NodeName = "localhost";
                  PSDscAllowPlainTextPassword = "$true";
                  PackageProductID = "{437AC169-780B-47A9-86F6-14D43C8F596B}";
                };
              );
            }
            EOS

            code <<-EOS
           	# variables
						$global:pwd = ConvertTo-SecureString "#{new_resource.initial_root_password}" -AsPlainText -Force
						$global:usrName = "root"
						$global:cred = New-Object -TypeName System.Management.Automation.PSCredential ($global:usrName,$global:pwd)

          	# Function definitions
						configuration SQLInstanceInstallationConfiguration {
              Import-DscResource -Module xMySql

              node $AllNodes.NodeName {
                Package mysql_bits {
                  Path = "#{package_uri}"
                  ProductId = $Node.PackageProductID
                  Name = "MySQL Install"
                }

                xMySqlServer MySQLInstance {
                  Ensure = "Present"
                  RootPassword = $global:cred
                  ServiceName = "#{mysql_name}"
                  DependsOn = "[Package]mysql_bits"
                }
              }
            }

            # SQLInstanceInstallationConfiguration
            EOS
          end

          # powershell_script "Use DSC to install mysql" do
          #   cwd "#{cache_path}/mysql"
          #   command ". ./derp.ps1"
          #   # FIXME: not_if { something }
          # end

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
