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
			return usage.uw_memused
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
end