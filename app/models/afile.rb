class Afile < ActiveRecord::Base
  belongs_to :dattachment
      # This method associates the attribute ":avatar" with a file attachment
  has_attached_file :dfile, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :dfile, :content_type => /\Aimage\/.*\Z/
end
