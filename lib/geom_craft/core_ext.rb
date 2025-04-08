# frozen_string_literal: true

Dir.glob(File.expand_path("core_ext/*.rb", __dir__)).sort.each do |path|
  require path
end

# copy from /opt/rbenv/versions/3.4.2/lib/ruby/gems/3.4.0/gems/activesupport-8.0.2/lib/active_support/core_ext.rb
