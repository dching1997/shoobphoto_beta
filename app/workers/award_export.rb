class AwardExport
  include Sidekiq::Worker
  sidekiq_options queue: "package_import"
    def perform(id)
      export = Missing.find(id)
      require 'csv'

      csv_file_setup = ''

          csv_file_setup << CSV.generate_line(['scode'] + ['name'] + ['abbrev'] + ['time_per'] + ['awd_date'] + ['rec_by'] + ['labelfile'] + ['award_id'])

          ExportList.where(:submitted => true).each do |export_list|
            export_list.where(:processed => false).each do |award|
               csv_file_setup << CSV.generate_line(["#{export_list.user.school.scode}"] + ["#{award.award.title}"] + ["#{award.award.abbreviation}"] + ["#{award.time_period}"] + ["#{award.receive_by}"] + ["#{award.award.image_file_name}"] + ["#{award.award.abbreviation.humanize}#{award.id}"])
            end
          end

          csv_file = ''

          csv_file << CSV.generate_line(['scode'] + ['shoob_id'] + ['st_stu_id'] + ['st_fname'] + ['st_lname'] + ['st_grade'] + ['st_teacher'] + ['image'] + ['award'] + ['st_id'])

          ExportList.where(:submitted => true).each do |export_list|
            export_list.where(:processed => false).each do |award|
              award.students.each do |student|
                @image = student.school.packages.where("name like ?", "%Fall%").last

                if @image.nil?
                  @image = student.school.packages.first
                end
                img = @image.student_images.where(:student_id => student.id)
               csv_file << CSV.generate_line(["#{student.school.scode}"] + ["#{student.shoob_id}"] + ["#{student.student_id}"] + ["#{student.first_name}"] + ["#{student.last_name}"] + ["#{student.grade}"] + ["#{student.teacher}"] + ["#{img.last.image.url}"] + ["#{award.award.abbreviation.humanize}#{award.id}"] + ["#{img.last.image_file_name}.jpg"])
             end
            end
          end
          
          file_name_setup = Rails.root.join('tmp', "award_setup_#{Time.now.day}-#{Time.now.month}-#{Time.now.year}_#{Time.now.hour}_#{Time.now.min}.csv");
          file_name = Rails.root.join('tmp', "award_#{Time.now.day}-#{Time.now.month}-#{Time.now.year}_#{Time.now.hour}_#{Time.now.min}.csv");

          File.open(file_name, 'wb') do |file|
          
            file.puts csv_file
          end

          File.open(file_name_setup, 'wb') do |file|
          
            file.puts csv_file_setup
          end

          s3 = AWS::S3.new

          key = File.basename(file_name)

          file = s3.buckets['shoobphoto'].objects["csvs/#{key}"].write(:file => file_name)
          file.acl = :public_read

          key_setup = File.basename(file_name_setup)

          file_setup = s3.buckets['shoobphoto'].objects["csvs/#{key_setup}"].write(:file => file_name_setup)
          file_setup.acl = :public_read

          export.update(:file_path => key, :file_path_setup => key_setup)
  end
end