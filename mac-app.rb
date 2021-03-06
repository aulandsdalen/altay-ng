require 'sinatra'
require 'sinatra/json'
require 'rack-flash'
require 'bcrypt'


set :bind, '0.0.0.0'
use Rack::Session::Cookie, #:domain => '',
                           :expire_after => 86400, 
                           :secret => BCrypt::Password.create("altay-ng" + Time.now.to_s)


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
	login_data = {
		"username" => "user",
		"password" => "secret"
	}
	os = OSAL.new
	usage = Usagewatch
	sysinfo = SysInfo.new
	os_short_name = %x(uname).chomp
	os_full_name = %x(uname -rs).chomp
	os_arch = %x(uname -m).chomp
	cpu_model = "Generic #{os_arch} CPU" #Sys::CPU.processors[0].model_name.chomp
	get '/old' do
		html :index
	end

	get '/' do
		haml :index_new, :locals => {:os_full_name => os_full_name, 
			:os_short_name => os_short_name, 
			:os_arch => os_arch, 
			:cpu_model => cpu_model, 
			:total_ram => "16384", #(%x(free).split(" ")[7].to_f/1024).to_i,
			:uptime => %x(uptime),
			:sessions_count => %x(who | wc -l).chomp, 
			:current_user => session[:username]
		}
	end
	get '/system.json' do
		json :altay_version_full => $ALTAY_APP_VERSION_FULL,
			 :altay_version_short => $ALTAY_APP_VERSION_SHORT,
			 :altay_version_commit => $ALTAY_APP_VERSION_COMMIT,
			 :os_short => os_short_name,
			 :os_full => os_full_name,
			 #:os_logo_image_link => "/images/os-mac.png",
			 :ruby_version => RUBY_VERSION + " " + RUBY_PLATFORM,
			 :arch => os_arch,
			 :cpu_name => cpu_model
	end
	get '/load.json' do 
		json :cpu => os.cpu_load, #usage.uw_cpuused,
			 :ram_used => rand * 100, #usage.uw_memused,
			 :ram_total => "16384", #(%x(free).split(" ")[7].to_f/1024).to_i,
			 :uptime => %x(uptime) #IO.read('/proc/uptime').split[0].to_i
	end
	get '/user.json' do 
		json :sessions_count => %x(who | wc -l).chomp,
			 :www_user => %x(whoami).chomp
	end

	##################
	# authentication #
	##################
	get '/login' do
		if logged_in?
			flash[:notice] = "Already logged in"
			redirect '/'
		else
			haml :login, :locals => {:title => "Log in"}
		end
	end
	#get '/login/:username' do 
	#	session[:username] = params[:username]
	#	redirect '/'
	#end
	post '/authorize' do
		puts params
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

	##############
	# text files #
	##############
	get '/utmp' do
		if logged_in?
			output = %x(utmp_reader)
			output_file = File.new("UTMP.txt", 'w')
			output_file.puts output
			output_file.close
			send_file "UTMP.txt", :filename => "UTMP.log", :type => "text/plain"
		else
			flash[:error] = "Log in to see this page"
			redirect '/login'
		end
	end
	get '/dmesg' do
		if logged_in?
			send_file "dmesg.txt", :filename => "dmesg.log", :type => "text/plain"
		else
			flash[:error] = "Log in to see this page"
			redirect '/login'
		end
	end
end