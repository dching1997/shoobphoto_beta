def self.default_ignore_exceptions
  [].tap do |exceptions|
    exceptions << ::ActiveRecord::RecordNotFound if defined? ::ActiveRecord::RecordNotFound
    exceptions << ::ActionController::UnknownFormat if defined? ::ActionController::UnknownFormat
    exceptions << ::ActionController::InvalidCrossOriginRequest if defined? ::ActionController::InvalidCrossOriginRequest
  end
end