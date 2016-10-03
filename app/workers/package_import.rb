class PackageImport
 	include Sidekiq::Worker
 	sidekiq_options queue: "package_import"

  	def perform(chunk)

   		bucket = AWS::S3::Bucket.new('shoobphoto')
      	s3 = AWS::S3.new
      	bucket1 = s3.buckets["shoobphoto"]
      	csv_file = ''

        csv_file << CSV.generate_line(['student id'] + ['image'] + ['grade'] + ['folder'] + ['last_name']  + ['first_name'] + ['email']  + ['dob'] + ['teacher'] + ['rec_type'] + ['accesscode'] + ['ca_code'] + ['slug'] + ['shoob_id'] + ['Imported?'] + ['Failure reason'])

      	chunk.each do |h|
      	schools = School.where("ca_code like ?", "%#{h["ca_code"]}%")	
	      	if schools.any?
	      		school = schools.last
	      		packages = school.packages.where("slug like ?", "%#{h["slug"]}%")

	      		if packages.any?
	      			package = packages.last
					students = school.students.where(:student_id => "#{h["student_id"]}")

					if h["student_id"].nil?
						student = school.students.new(:student_id => h["student_id"], :last_name => h["last_name"], :first_name => h["first_name"], :grade => h["grade"], :id_only => true, :access_code => h["accesscode"])
			            student.save
					else
			          unless students.any?    
			            student = school.students.new(:student_id => h["student_id"], :last_name => h["last_name"], :first_name => h["first_name"], :grade => h["grade"], :id_only => true, :access_code => h["accesscode"])
			            student.save
			           else
			           	student = students.last
			           	student.update(:student_id => h["student_id"], :last_name => h["last_name"], :first_name => h["first_name"], :grade => h["grade"], :email => h["email"], :teacher => h["teacher"], :shoob_id => h["shoob_id"], :id_only => true, :access_code => h["accesscode"])
			          end
			        end #create student if student ID nil

			          unless h["folder"].nil?
			          	unless h["image"].nil?

				          	images = student.student_images.where("lower(folder) like ?", "%#{h["folder"]}%")
				          	if bucket.objects["images/#{h["folder"]}/#{h["image"].upcase}.jpg"].exists? #upcase
				          		url = h["folder"].upcase
				          	elsif bucket.objects["images/#{h["folder"]}/#{h["image"].downcase}.jpg"].exists? #upcase
				          		url = h["folder"].downcase
				          	else
				          		url = nil
				          	end

				          	unless url.nil?
					        	if images.any? #update
					        		image = images.last
					        		image.update(:package_id => package.id, :student_id => student.id, :image_file_name => h["url"], :url => h["url"], :folder => h["folder"], :shoob_id => h["shoob_id"])
					        	else #create
					        		image = StudentImage.new(:package_id => package.id, :student_id => student.id, :image_file_name => h["url"], :url => h["url"], :folder => h["folder"], :shoob_id => h["shoob_id"])
					        		image.save
					        	end
					        	csv_file << CSV.generate_line(["#{h["student id"]}"] + ["#{h["image"]}"] + ["#{h["grade"]}"] + ["#{h["folder"]}"] + ["#{h["last_name"]}"] + ["#{h["first_name"]}"] + ["#{h["email"]}"]  + ["#{h["dob"]}"] + ["#{h["teacher"]}"] + ["#{h["rec_type"]}"] + ["#{h["accesscode"]}"] + ["#{h["ca_code"]}"] + ["#{h["slug"]}"] + ["#{h["shoob_id"]}"] + ['TRUE'] + [''])
				        	else
				        		#throw exception image not found on s3
				        		csv_file << CSV.generate_line(["#{h["student id"]}"] + ["#{h["image"]}"] + ["#{h["grade"]}"] + ["#{h["folder"]}"] + ["#{h["last_name"]}"] + ["#{h["first_name"]}"] + ["#{h["email"]}"]  + ["#{h["dob"]}"] + ["#{h["teacher"]}"] + ["#{h["rec_type"]}"] + ["#{h["accesscode"]}"] + ["#{h["ca_code"]}"] + ["#{h["slug"]}"] + ["#{h["shoob_id"]}"] + ['FALSE'] + ['Image not found on S3'])
				        	end
			        	else
			        		#image blank
			        		csv_file << CSV.generate_line(["#{h["student id"]}"] + ["#{h["image"]}"] + ["#{h["grade"]}"] + ["#{h["folder"]}"] + ["#{h["last_name"]}"] + ["#{h["first_name"]}"] + ["#{h["email"]}"]  + ["#{h["dob"]}"] + ["#{h["teacher"]}"] + ["#{h["rec_type"]}"] + ["#{h["accesscode"]}"] + ["#{h["ca_code"]}"] + ["#{h["slug"]}"] + ["#{h["shoob_id"]}"] + ['FALSE'] + ['Image on CSV blank'])
						end #check if image is in CSV
					else
						csv_file << CSV.generate_line(["#{h["student id"]}"] + ["#{h["image"]}"] + ["#{h["grade"]}"] + ["#{h["folder"]}"] + ["#{h["last_name"]}"] + ["#{h["first_name"]}"] + ["#{h["email"]}"]  + ["#{h["dob"]}"] + ["#{h["teacher"]}"] + ["#{h["rec_type"]}"] + ["#{h["accesscode"]}"] + ["#{h["ca_code"]}"] + ["#{h["slug"]}"] + ["#{h["shoob_id"]}"] + ['FALSE'] + ['Folder on CSV blank'])
						#folder blank
			        end #check if folder exists to create image
			    else
			    	csv_file << CSV.generate_line(["#{h["student id"]}"] + ["#{h["image"]}"] + ["#{h["grade"]}"] + ["#{h["folder"]}"] + ["#{h["last_name"]}"] + ["#{h["first_name"]}"] + ["#{h["email"]}"]  + ["#{h["dob"]}"] + ["#{h["teacher"]}"] + ["#{h["rec_type"]}"] + ["#{h["accesscode"]}"] + ["#{h["ca_code"]}"] + ["#{h["slug"]}"] + ["#{h["shoob_id"]}"] + ['FALSE'] + ['No package with slug found for school'])
			    	#no package found with slug
			    end
			else
				csv_file << CSV.generate_line(["#{h["student id"]}"] + ["#{h["image"]}"] + ["#{h["grade"]}"] + ["#{h["folder"]}"] + ["#{h["last_name"]}"] + ["#{h["first_name"]}"] + ["#{h["email"]}"]  + ["#{h["dob"]}"] + ["#{h["teacher"]}"] + ["#{h["rec_type"]}"] + ["#{h["accesscode"]}"] + ["#{h["ca_code"]}"] + ["#{h["slug"]}"] + ["#{h["shoob_id"]}"] + ['FALSE'] + ['No school found with CA code'])
				#no school found with ca_code
			end
     	end #end chunk loop
     	file_name = Rails.root.join('tmp', "output_#{Time.now.day}-#{Time.now.month}-#{Time.now.year}_#{Time.now.hour}_#{Time.now.min}.csv");

          File.open(file_name, 'wb') do |file|
          
            file.puts csv_file
          end

          s3 = AWS::S3.new

          key = File.basename(file_name)

          file = s3.buckets['shoobphoto'].objects["AutoCSV/failed/#{key}"].write(:file => file_name)
          file.acl = :public_read
 	end #end def
end #end class
