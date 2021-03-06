# This ruby script creates the dynamic configuration file
# needed for the fluentd-remote-syslog plugin.

@env_vars = Array.new

# Loops through environment variables for the remote-syslog plugin
def init_environment_vars()
  prefix = 'REMOTE_SYSLOG_'
  group  = prefix + "HOST"

  ENV.each_key.to_a.select { |s| s.start_with? group }.uniq.each do |k|
    # [0] = environment variable name
    # [1] = syslog plugin config name
    # [2] = default value, if any
    vars = [
      ['HOST', 'remote_syslog', nil],
      ['PORT', 'port', "514"],
      ['HOSTNAME', 'hostname', ENV['HOSTNAME']],
      ['REMOVE_TAG_PREFIX', 'remove_tag_prefix', nil],
      ['TAG_KEY', 'tag_key', nil],
      ['FACILITY', 'facility', "local0"],
      ['SEVERITY', 'severity', "debug"],
      ['USE_RECORD', 'use_record', nil],
      ['PAYLOAD_KEY', 'payload_key', nil]
    ]
    t = k.dup
    t.slice! group
    vars.each { |r| r[2] = ENV[prefix + r[0] + t] unless !ENV[prefix + r[0] + t] }
    @env_vars.push(vars)
  end
end


def create_default_file()
  file_name = "/etc/fluent/configs.d/dynamic/output-remote-syslog.conf"
  c = '## This file was generated by generate-syslog-config.rb'

  @env_vars.each do |r|
  c <<
"
<store>
@type syslog_buffered
@id remote-syslog-input
"
     r.each { |v|  c << "#{v[1]} #{v[2]}\n" unless !v[2] }
  c <<
"</store>
"
  end

  File.open(file_name, 'w') { |f| f.write(c) }
end

init_environment_vars()
create_default_file()
