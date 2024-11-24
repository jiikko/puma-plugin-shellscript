# frozen_string_literal: true

require "puma"
require "puma/plugin"

Puma::Plugin.create do
  def start(launcher)
    @child_pid = nil

    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        if @child_pid
          puts "[puma plugin command] Killing child process #{@child_pid}"
          begin
            Process.kill('TERM', @child_pid)
            Process.wait(@child_pid)
          rescue Errno::ESRCH, Errno::ECHILD => e
            puts "[puma plugin command] Failed to kill process: #{e.message}"
          ensure
            @child_pid = nil
          end
        else
          puts '[puma plugin command] No child process to kill'
        end
      end
    end

    command = ENV['PUMA_PLUGIN_COMMAND']

    in_background do
      loop do
        puts "[puma plugin command] Running command: #{command}"
        stdout, _stdin, pid = PTY.spawn(command)
        @child_pid = pid

        puts stdout.map(&:itself).join
        _, status = Process.wait2(pid)
        if status.success?
          puts '[puma plugin command] Command exited successfully'
        else
          puts "[puma plugin command] Command failed with status: #{status.exitstatus}"
        end
      rescue Errno::EIO => e
        Rails.logger.error "[puma plugin command] Error: #{e}"
      ensure
        @child_pid = nil
      end
    end
  end
end
