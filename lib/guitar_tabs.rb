require "guitar_tabs/version"
require 'pry' unless RUBY_ENGINE=='rbx'
module GuitarTabs
  autoload :GuitarPro, 'guitar_tabs/guitar_pro'
end
