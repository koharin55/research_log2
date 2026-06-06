Rails.application.config.to_prepare do
  default_attrs = ActionText::ContentHelper.sanitizer.class.allowed_attributes +
                  ActionText::Attachment::ATTRIBUTES
  ActionText::ContentHelper.allowed_attributes = default_attrs + ["style"]
end
