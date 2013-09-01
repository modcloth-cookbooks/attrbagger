#
# Cookbook Name:: attrbagger
# Recipe:: handler
#
# Copyright 2013, ModCloth, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

recipe = self

attrbagger_handler_file = ::File.join(
  node['chef_handler']['handler_path'], 'attrbagger_handler.rb'
)

cookbook_file attrbagger_handler_file do
  source 'handlers/attrbagger_handler.rb'
  mode 0640
  action :nothing
end.run_action(:create)

chef_handler('Chef::Handler::AttrbaggerHandler') do
  source attrbagger_handler_file
  arguments run_context: recipe.run_context, autoload: node['attrbagger']['autoload']
  supports start: true
  action :nothing
end.run_action(:enable)

ruby_block 're-run start handlers' do
  block do
    require 'chef/run_status'
    require 'chef/handler'
    Chef::Handler.run_start_handlers(nil)
  end
  action :nothing
end.run_action(:create)
