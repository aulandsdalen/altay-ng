require 'sinatra'
require 'sinatra/json'
require 'rack-flash'


set :bind, '0.0.0.0'
use Rack::Session::Cookie, :domain => 'centos.local',
                           :expire_after => 86400, 
                           :secret => 'altay-aulandsdalen'


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
		def link_to url_fragment, mode=:path_only
			case mode
			when :path_only
				base = request.script_name
			when :full_url
				if (request.scheme == 'http' && request.port == 80 || request.scheme == 'https' && request.port == 443)
					port = ""
				else
		    		port = ":#{request.port}"
				end
			base = "#{request.scheme}://#{request.host}#{port}#{request.script_name}"
			else
				raise "Unknown script_url mode #{mode}"
			end
			"#{base}#{url_fragment}"
		end
	end
	login_data = {
		"username" => "user",
		"password" => "secret"
	}
	usage = Usagewatch
	sysinfo = SysInfo.new
	os_short_name = %x(uname).chomp
	os_full_name = %x(uname -rs).chomp
	os_arch = %x(uname -m).chomp
	cpu_model = Sys::CPU.processors[0].model_name.chomp
	get '/old' do
		html :index
	end

	get '/' do
		haml :index, :locals => {:os_full_name => os_full_name, 
			:os_short_name => os_short_name, 
			:os_arch => os_arch, 
			:cpu_model => cpu_model, 
			:total_ram => (%x(free).split(" ")[7].to_f/1024).to_i,
			:uptime => IO.read('/proc/uptime').split[0].to_i,
			:sessions_count => %x(who | wc -l).chomp
		}
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
	get '/login' do
		haml :login
	end
	#get '/login/:username' do 
	#	session[:username] = params[:username]
	#	redirect '/'
	#end
	post '/authorize' do
		if params[:username] == login_data["username"]
			if params[:password] == login_data["password"]
				puts "successful auth!"
				session[:username] = params[:username]
				session[:useragent] = request.env['HTTP_USER_AGENT']
				flash[:notice] = "Welcome back"
				redirect '/'
			else
				puts "wrong password"
				flash[:error] = "Wrong password"
				redirect '/login'
			end
		else
			puts "wrong login"
			flash[:error] = "Wrong login"
			redirect '/login'
		end
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
		json :result => "not authorized",
			 :code => 403,
			 :human_readable => "Log in to perform this action"
	end
end