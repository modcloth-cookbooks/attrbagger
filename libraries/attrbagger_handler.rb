require 'chef/handler'

class AttrbaggerHandler < ::Chef::Handler
  def initialize
    super
    @autoloaded = false
  end

  def report
    unless @autoloaded
      if run_status && run_status.run_context
        Attrbagger.autoload!(run_status.run_context)
        @autoloaded = true
      end
    end
  end
end

if (Chef::Config[:attrbagger] || {})[:autoload]
  attrbagger_handler = AttrbaggerHandler.new
  Chef::Log.info("Enabling attrbagger as a start handler")
  Chef::Config.send(:start_handlers).delete_if do |v|
    v.class.to_s.include?(AttrbaggerHandler.to_s)
  end
  Chef::Config.send(:start_handlers) << attrbagger_handler
end
