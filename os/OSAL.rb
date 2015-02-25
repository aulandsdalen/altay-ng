class OSAL
	module OS
		def OS.windows?
			(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
		end

		def OS.osx?
			(/darwin/ =~ RUBY_PLATFORM) != nil
		end

		def OS.linux?
			(/linux/ =~ RUBY_PLATFORM) != nil 
		end
	end
	def cpu_load
		if (/darwin/ =~ RUBY_PLATFORM) != nil
			return rand(100)
		end
		if (/linux/ =~ RUBY_PLATFORM) != nil
			return Usagewatch.uw_cpuused
		end
	end
	def total_ram
		if (/darwin/ =~ RUBY_PLATFORM) != nil
			return "16384"
		end
		if (/linux/ =~ RUBY_PLATFORM) != nil
			return (%x(free).split(" ")[7].to_f/1024).to_i
		end
	end
	def uptime 
		if (/darwin/ =~ RUBY_PLATFORM) != nil
			return '1000' # TODO: rewrite to real values
		end
		if (/linux/ =~ RUBY_PLATFORM) != nil
			IO.read('/proc/uptime').split[0].to_i
		end
	end
	def ram_used
		if (/darwin/ =~ RUBY_PLATFORM) != nil
			return 45
		end
		if (/linux/ =~ RUBY_PLATFORM) != nil
			if Usagewatch.us_memused != 0
				return Usagewatch.uw_memused
			else
				return 80
			end
		end
	end
	def sessions_count
		if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) == nil 
			return %x(who | wc -l).chomp
		end
	end
	def cpu_model
		if (/linux/ =~ RUBY_PLATFORM) == nil
			return "Generic x86 CPU"
		else
			return Sys::CPU.processors[0].model_name.chomp
		end
	end
	def dmesg
		if (/linux/ =~ RUBY_PLATFORM) != nil 
			output = %x(utmp_reader)
			output_file = File.new("dmesg.log", 'w')
			output_file.puts output
			output_file.close
		end
		return output_file
	end
	def restart_service servicename
		if (/linux/ =~ RUBY_PLATFORM) == nil
			return true
		else
			if(system("sudo service #{servicename} restart"))
				return $?
			else
				return false
			end
		end
	end
end