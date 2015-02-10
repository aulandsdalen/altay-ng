require 'sinatra'
require 'sinatra/json'
require 'rack-flash'
#require 'usagewatch' 


set :bind, '0.0.0.0'
enable :sessions


class AltayNG < Sinatra::Application
	use Rack::Flash
	helpers do
		def logged_in?
			if session[:username].nil?
				return false
			else
				return true
			end
			#return !session[:username].nil?
		end
		def username
			return session[:username]
		end
		def html(view)
			File.read(File.join('public', "#{view.to_s}.html"))
		end
	end
	usage = Usagewatch
	sysinfo = SysInfo.new
	os_short_name = %x(uname).chomp
	os_full_name = %x(uname -rs).chomp
	os_arch = %x(uname -m).chomp
	cpu_model = Sys::CPU.processors[0].model_name.chomp
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
			 :altay_version_commit => $ALTAY_APP_VERSION_COMMIT,
			 :os_short => os_short_name,
			 :os_full => os_full_name,
			 :os_logo_image_link => "/images/os-linux.png",
			 :ruby_version => RUBY_VERSION + " " + RUBY_PLATFORM,
			 :arch => os_arch,
			 :cpu_name => cpu_model
	end
	get '/software.json' do
		# TODO
		# separate system data and software data
	end
	get '/load.json' do 
		json :cpu => usage.uw_cpuused,
			 :ram_used => usage.uw_memused,
			 :ram_total => (%x(free).split(" ")[7].to_f/1024).to_i,
			 :uptime => IO.read('/proc/uptime').split[0].to_i
	end
	get '/user.json' do 
		json :sessions_count => %x(who | wc -l).chomp,
			 :www_user => %x(whoami).chomp
	end

	##################
	# authentication #
	##################
	get '/login/:username' do 
		session[:username] = params[:username]
		redirect '/'
	end
	get '/logout' do
		session[:username] = nil
		redirect '/'
	end
	get '/user' do
		json :logged_in => logged_in?,
			 :username => username
	end
	get '/reboot.action' do 
		#todo: auth
		#%x(reboot)
		#flash[:error] = "Log in to perform this action"
		json :result => "not authorized"
	end
end