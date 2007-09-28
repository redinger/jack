# -*- ruby -*-

require 'rubygems'
require 'hoe'
$: << 'lib'
require 'jack'

Hoe.new('jack', Jack::VERSION) do |p|
  p.rubyforge_name = 'jack'
  p.author = 'Rick Olson'
  p.email = 'technoweenie@gmail.com'
  # p.summary = 'FIX'
  # p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  # p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << 'rake' << 'open4'
  p.test_globs << 'test/**/*_test.rb'
end

# vim: syntax=Ruby
