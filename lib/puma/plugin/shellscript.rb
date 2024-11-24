# frozen_string_literal: true

require "puma"
require "puma/plugin"

Puma::Plugin.create do
  def start(launcher)
    @child_pid = nil

    launcher.events.register(:state) do |state|
      if %i[halt restart stop].include?(state)
        if @child_pid
          puts "[puma plugin shellscript] Killing child process #{@child_pid}"
          begin
            Process.kill('TERM', @child_pid)
            Process.wait(@child_pid)
          rescue Errno::ESRCH, Errno::ECHILD => e
            puts "[puma plugin shellscript] Failed to kill process: #{e.message}"
          ensure
            @child_pid = nil
          end
        else
          puts '[puma plugin shellscript] No child process to kill'
        end
      end
    end

    shellscript = ENV['PUMA_PLUGIN_SHELLSCRIPT']

    in_background do
      loop do
        puts "[puma plugin shellscript] Running shellscript: #{shellscript}"
        stdout, _stdin, pid = PTY.spawn(shellscript)
        @child_pid = pid

        puts stdout.map(&:itself).join
        _, status = Process.wait2(pid)
        if status.success?
          puts '[puma plugin shellscript] Command exited successfully'
        else
          puts "[puma plugin shellscript] Command failed with status: #{status.exitstatus}"
        end
      rescue Errno::EIO => e
        Rails.logger.error "[puma plugin shellscript] Error: #{e}"
      ensure
        @child_pid = nil
      end
    end
  end
end
