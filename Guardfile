# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'less', :all_on_start => true, :all_after_change => true, :output => 'css' do
  watch(%r{^less/.+\.less$})
end

guard 'haml', :output => 'example', :input => 'example' do
  watch(/^.+(\.html\.haml)/)
end

guard 'coffeescript', :input => 'coffeescript', :output => 'javascript' do
  watch /^.+(\.coffeescript)$/
end

guard 'jasmine' do
  watch(%r{spec/javascripts/spec_helper\.(js\.coffee|js|coffee)$})         { "spec/javascripts" }
  watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
  watch(%r{coffeescript/(.+?)\.(js\.coffee|js|coffee)$})  { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
end