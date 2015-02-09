require 'rubygems'
require 'bundler'

Bundler.require
root = ::File.dirname(__FILE__)


require ::File.join(root, 'app')

$ALTAY_APP_VERSION_FULL = 'Altay 0.1 NG'
$ALTAY_APP_VERSION_SHORT = '0.1ng'
$ALTAY_APP_VERSION_COMMIT = %x(git rev-parse --short HEAD).chomp

use Rack::Session::Cookie, :secret => 'aulandsdalen-altayng'

#Rack::Handler::Thin.run AltayNG.new, :Port => ENV['PORT']
run AltayNG