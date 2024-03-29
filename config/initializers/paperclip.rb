Paperclip::Attachment.default_options[:storage] = :s3
Paperclip::Attachment.default_options[:s3_protocol] = 'https'
Paperclip::Attachment.default_options[:s3_credentials] = 
  { :bucket => ENV['S3_BUCKET_NAME'],
    :access_key_id => ENV['ACCESS_KEY'],
    :secret_access_key => ENV['SECRET_KEY'] }

Paperclip.interpolates :folder do |attachment, style|
  attachment.instance.folder
end

Paperclip.interpolates :url do |attachment, style|
  attachment.instance.image_file_name
end

Paperclip.interpolates :package_id do |attachment, style|
  attachment.instance.package_id
end

Paperclip.interpolates :package_image_file_name do |attachment, style|
  attachment.instance.package.image_file_name
end

Paperclip.interpolates :student_image_folder do |attachment, style|
  attachment.instance.student_image.folder
end

Paperclip.interpolates :watermark_file_name do |attachment, style|
  attachment.instance.student_image.watermark_file_name
end
  
Paperclip.interpolates :image_file_name do |attachment, style|
  attachment.instance.image_file_name
end

Paperclip.interpolates :scode do |attachment, style|
  attachment.instance.scode
end

Paperclip.interpolates :file_type do |attachment, style|
  attachment.instance.extension
end