require 'rubygems'
require 'bundler'

Bundler.require
root = ::File.dirname(__FILE__)


require ::File.join(root, 'app')

$ALTAY_APP_VERSION_FULL = 'Altay 0.1 NG'
$ALTAY_APP_VERSION_SHORT = '0.1ng'


Rack::Handler::Thin.run AltayNG.new, :Host => '0.0.0.0', :Port => '3000'