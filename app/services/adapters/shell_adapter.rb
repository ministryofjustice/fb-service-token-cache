require 'open3'

class Adapters::ShellAdapter
  # run the given array of cmds & args
  # discarding the output
  def self.exec(*args)
    cmd_line = build_cmd( args )
    Rails.logger.info "executing cmd #{cmd_line}"
    # TODO: maybe use Open3.popen2e instead, so that we
    # can get streaming output as well as exit code?
    result = Kernel.system(cmd_line)

    unless result
      raise CmdFailedError.new(cause: "#{$?}", message: "failing cmd: #{redact_token(cmd_line)}")
    end
  end

  def self.output_of(*args)
    capture_with_stdin(cmd: args).strip
  end

  def self.capture_with_stdin(cmd: [], stdin: nil)
    cmd_line = build_cmd( cmd )

    stdout_str, status = Open3.capture2(cmd_line, stdin_data: stdin)
    unless status.success?
      raise CmdFailedError.new(cause: "#{$?}", message: "failing cmd: #{redact_token(cmd_line)}")
    end
    stdout_str
  end

  def self.build_cmd(args)
    args.join(' ')
  end

  def self.redact_token(message)
    message.gsub(/(?<=--token=)(.*)(?=\s)/, '<REDACTED>')
  end
end
