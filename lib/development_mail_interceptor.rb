class DevelopmentMailInterceptor
  def self.delivering_email( message )
    message.subject = "#{message.to} #{message.subject}"
    message.to = "matt@composition9.com"
    message.from = "system9@composition9.com"
  end
end
