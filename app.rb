require 'sinatra'
require 'sinatra/json'
#require 'usagewatch' 

set :bind, '0.0.0.0'
class AltayNG < Sinatra::Application
	usage = Usagewatch
	sysinfo = SysInfo.new
	os_short_name = %x(uname).strip
	os_full_name = %x(uname -rs).strip
	os_arch = %x(uname -m).strip
	cpu_model = Sys::CPU.processors[0].model_name.strip
	before '/admin/*' do 
		authenticate!
	end
	get '/' do
		html :index
	end

	get '/cpu' do 
		"CPU load: #{usage.uw_cpuused} %"
	end
	get '/ram' do
		usedramperc = usage.uw_memused.to_f
		totalram = %x(free).split(" ")[7].to_f
		usedram = totalram * (usedramperc/100)
		"RAM usage: #{usedramperc} % or #{usedram.to_i} bytes of total #{totalram.to_i} bytes used"
	end
	get '/system' do
		"Running on #{sysinfo.os} #{sysinfo.arch} with version #{sysinfo.ruby} with IP #{sysinfo.ipaddress_internal}<br>#{%x(uname -rs)}"
	end
	get '/system.json' do
		json :altay_version_full => $ALTAY_APP_VERSION_FULL,
			 :altay_version_short => $ALTAY_APP_VERSION_SHORT,
			 :os_short => os_short_name,
			 :os_full => os_full_name,
			 :os_logo_image_link => "/images/os-linux.png",
			 :ruby_version => RUBY_VERSION + " " + RUBY_PLATFORM,
			 :arch => os_arch,
			 :cpu_name => cpu_model
	end
	get '/load.json' do 
		json :cpu => usage.uw_cpuused,
			 :ram_used => usage.uw_memused,
			 :ram_total => (%x(free).split(" ")[7].to_f/1024).to_i,
			 :uptime => IO.read('/proc/uptime').split[0].to_i
	end
	get '/user.json' do 
		json :sessions_count => %x(who | wc -l).strip,
			 :www_user => %x(whoami).strip
	end
	get '/reboot.action' do 
		#todo: auth
		#%x(reboot)
		json :result => "not authorized"
	end
	def html(view)
		File.read(File.join('public', "#{view.to_s}.html"))
	end
end