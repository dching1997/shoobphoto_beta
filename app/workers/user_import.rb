class UserImport
 	include Sidekiq::Worker
 	sidekiq_options queue: "package_import"

  	def perform(chunk)
  		@user_id = []

      	chunk.each do |h|
      		school = School.where(:ca_code => "#{h["nscode"]}")

      		if school.any?
      			school = school.last
      			school.update(:scode => h["scode"].to_i)
      		else
      			@user_id << h["nscode"]
      		end
	   
     	end #end chunk
     	puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
      	puts @user_id
      	puts "#{@user_id.count}"
 	end
end

