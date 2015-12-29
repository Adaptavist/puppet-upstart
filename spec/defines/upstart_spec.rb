require 'spec_helper'

service_name = 'test_service'
app_username = 'admin'
launch_cmd = 'start'
start_on = true
env = {'SERVICE_HOME' => '/home/service'}
chdir = '/home/service'

describe 'upstart', :type => 'define' do
  let(:title){service_name}
  
  context "Should fail on unsupported osfamily" do
    let(:facts) { { :osfamily => 'Windows', } }
      it { expect { should contain_service(service_name) }.to raise_error(Puppet::Error) }
  end

  context "Should fail on supported osfamily without app_username param" do
    let(:facts) { { :osfamily => 'Debian', } }
      it { expect { should contain_service(service_name) }.to raise_error(Puppet::Error) }
  end

  context "Should fail on unsupported osfamily without launch_cmd param" do
    let(:facts) { { :osfamily => 'Debian', } }
    let(:params) { { :app_username => app_username, } }
      it { expect { should contain_service(service_name) }.to raise_error(Puppet::Error) }
  end

  context "Should create service based on name, init config and restart service with default params on Debian" do
    let(:facts) { { :osfamily => 'Debian'} }
    let(:params) { { 
      :app_username => app_username,
      :launch_cmd => launch_cmd,
    } }
    it do
      should contain_service(service_name).with(
        'ensure'   => 'running',
        'provider' => 'upstart',
        'require'  => "File[/etc/init/#{service_name}.conf]",
      )

      should contain_file("/etc/init/#{service_name}.conf").with(
          'ensure' => 'present',
      ).with_content(/description\W*\"#{service_name}\"/)
      .with_content(/start on stopped rc RUNLEVEL=\[2345\]/)
      .with_content(/stop on runlevel \[016\]/)
      .with_content(/respawn limit 10 5/)
      .with_content(/env USER=\"#{app_username}\"/)
      .with_content(/exec su -s \/bin\/dash -c \'exec \"\$0\" \"\$\@\"\' \"\$USER\" --/)
      should contain_exec("restart-#{service_name}").with(
          'require'     => "File[/etc/init/#{service_name}.conf]",
          'subscribe'   => "File[/etc/init/#{service_name}.conf]",
          'command'     => "/sbin/stop #{service_name}; /sbin/start #{service_name}",
          'refreshonly' => true,
      )
    end
  end

  context "Should create service based on name, init config and restart service with custom params on Debian" do
    let(:facts) { { :osfamily => 'Debian'} }
    let(:params) { { 
      :app_username => app_username,
      :launch_cmd   => launch_cmd,
      :start_on     => start_on,
      :env          => env,
      :chdir        => chdir,
    } }
    it do
      should contain_service(service_name).with(
        'ensure'   => 'running',
        'provider' => 'upstart',
        'require'  => "File[/etc/init/#{service_name}.conf]",
      )

      should contain_file("/etc/init/#{service_name}.conf").with(
          'ensure' => 'present',
      ).with_content(/description\W*\"#{service_name}\"/)
      .with_content(/start on #{start_on}/)
      .with_content(/stop on runlevel \[016\]/)
      .with_content(/respawn limit 10 5/)
      .with_content(/env #{env.keys[0]}=#{env.values[0]}/)
      .with_content(/chdir #{chdir}/)
      .with_content(/env USER=\"#{app_username}\"/)
      .with_content(/exec su -s \/bin\/dash -c \'exec \"\$0\" \"\$\@\"\' \"\$USER\" --/)

      should contain_exec("restart-#{service_name}").with(
          'require'     => "File[/etc/init/#{service_name}.conf]",
          'subscribe'   => "File[/etc/init/#{service_name}.conf]",
          'command'     => "/sbin/stop #{service_name}; /sbin/start #{service_name}",
          'refreshonly' => true,
      )
    end
  end

  context "Should create service based on name, init config and restart service with default params on RedHat" do
    let(:facts) { { :osfamily => 'RedHat'} }
    let(:params) { { 
      :app_username => app_username,
      :launch_cmd => launch_cmd,
    } }
    it do
      should contain_service(service_name).with(
        'ensure'   => 'running',
        'hasstatus'  => true,
        'hasrestart' => true,
        'start'      => "/sbin/initctl start #{service_name}",
        'stop'       => "/sbin/initctl stop #{service_name}",
        'status'     => "/sbin/initctl status #{service_name} | grep '/running' 1>/dev/null 2>&1",
        'require'    => "File[/etc/init/#{service_name}.conf]",
        'provider'   => 'base',
      )

      should contain_file("/etc/init/#{service_name}.conf").with(
          'ensure' => 'present',
      ).with_content(/description\W*\"#{service_name}\"/)
      .with_content(/start on stopped rc RUNLEVEL=\[2345\]/)
      .with_content(/stop on runlevel \[016\]/)
      .with_content(/respawn limit 10 5/)
      .with_content(/env USER=\"#{app_username}\"/)
      .with_content(/exec su -s \/bin\/dash -c \'exec \"\$0\" \"\$\@\"\' \"\$USER\" --/)
      should contain_exec("restart-#{service_name}").with(
          'require'     => "File[/etc/init/#{service_name}.conf]",
          'subscribe'   => "File[/etc/init/#{service_name}.conf]",
          'command'     => "/sbin/stop #{service_name}; /sbin/start #{service_name}",
          'refreshonly' => true,
      )
    end
  end

  context "Should create service based on name, init config and restart service with custom params on RedHat" do
    let(:facts) { { :osfamily => 'RedHat'} }
    let(:params) { { 
      :app_username => app_username,
      :launch_cmd   => launch_cmd,
      :start_on     => start_on,
      :env          => env,
      :chdir        => chdir,
    } }
    it do
      should contain_service(service_name).with(
        'ensure'   => 'running',
        'hasstatus'  => true,
        'hasrestart' => true,
        'start'      => "/sbin/initctl start #{service_name}",
        'stop'       => "/sbin/initctl stop #{service_name}",
        'status'     => "/sbin/initctl status #{service_name} | grep '/running' 1>/dev/null 2>&1",
        'require'    => "File[/etc/init/#{service_name}.conf]",
        'provider'   => 'base',
      )

      should contain_file("/etc/init/#{service_name}.conf").with(
          'ensure' => 'present',
      ).with_content(/description\W*\"#{service_name}\"/)
      .with_content(/start on #{start_on}/)
      .with_content(/stop on runlevel \[016\]/)
      .with_content(/respawn limit 10 5/)
      .with_content(/env #{env.keys[0]}=#{env.values[0]}/)
      .with_content(/chdir #{chdir}/)
      .with_content(/env USER=\"#{app_username}\"/)
      .with_content(/exec su -s \/bin\/dash -c \'exec \"\$0\" \"\$\@\"\' \"\$USER\" --/)

      should contain_exec("restart-#{service_name}").with(
          'require'     => "File[/etc/init/#{service_name}.conf]",
          'subscribe'   => "File[/etc/init/#{service_name}.conf]",
          'command'     => "/sbin/stop #{service_name}; /sbin/start #{service_name}",
          'refreshonly' => true,
      )
    end
  end

  context "Should fail with unsupported OS family" do
    let(:facts) { { :osfamily => 'Solaris'} }
    let(:params) { { 
      :app_username => app_username,
      :launch_cmd   => launch_cmd,
      :start_on     => start_on,
      :env          => env,
      :chdir        => chdir,
    } }

    it do
      should raise_error(Puppet::Error, /upstart - Unsupported Operating System family: Solaris/)
    end
  end
end
