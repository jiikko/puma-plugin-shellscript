# frozen_string_literal: true

require 'puma-plugin-shellscript'
require 'puma'
require 'puma/plugin'
require 'pty'
require 'fileutils'

::Puma::Plugin.create do
  def start(launcher)
    pid_file = '/tmp/puma_plugin_shellscript.pid'

    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        if File.exist?(pid_file)
          child_pid = File.read(pid_file).strip.to_i
          if child_pid > 0
            puts "[puma plugin shellscript] Killing child process #{child_pid}"
            begin
              Process.kill('TERM', child_pid)
              Process.wait(child_pid)
            rescue Errno::ESRCH, Errno::ECHILD => e
              puts "[puma plugin shellscript] Failed to kill process: #{e.message}"
            ensure
              File.delete(pid_file) if File.exist?(pid_file)
            end
          else
            puts '[puma plugin shellscript] No valid child process PID to kill'
          end
        else
          puts '[puma plugin shellscript] PID file not found'
        end
      end
    end

    shellscript = ENV['PUMA_PLUGIN_SHELLSCRIPT']

    in_background do
      loop do
        puts "[puma plugin shellscript] Running shellscript: #{shellscript}"
        stdout, _stdin, pid = PTY.spawn(shellscript)

        File.write(pid_file, pid)

        puts stdout.map(&:itself).join
        _, status = Process.wait2(pid)
        if status.success?
          puts '[puma plugin shellscript] Command exited successfully'
        else
          puts "[puma plugin shellscript] Command failed with status: #{status.exitstatus}"
        end

        sleep 2
      rescue Errno::EIO => e
        Rails.logger.error "[puma plugin shellscript] Error: #{e}"
      ensure
        File.delete(pid_file) if File.exist?(pid_file)
      end
    end
  end
end
