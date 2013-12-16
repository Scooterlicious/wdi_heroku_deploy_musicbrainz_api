class Filestore
	
	#append a new user to a texts file
	def self.create(string_in)
		f = File.new(self.list_file_path, "a")
		f.puts("#{string_in}")
		f.close
	end

	#retrieve an array of all usernames
	def self.all
		contents = []
		f = File.new(self.list_file_path, "r")

		while (line = f.gets)
			contents << line
		end

		#I don't understand why the below stopped working.  But it stopped working.  So using a while loop instead
		# f.each do |line|
		# 	contents << line #line.chomp.split(", ")
		# end
		 f.close
		return contents
	end

	def self.list_file_path
		"./db/Filestore.db"
	end

	def self.find(username)
		#return user if it exists.
	end

	def self.delete(username)
		#delete a user based on username
	end

	def self.update(username, locale)
		#find user and update age
	end
end