# name: digest-report-gemini
# about: Sends a POST request with email_id and user_id after a digest is sent
# version: 0.2
# authors: Gemini
# url: https://github.com/your-repo/discourse-digest-notifier

enabled_site_setting :digest_notifier_enabled

after_initialize do
  # The 'user' object is passed into this event by Discourse core
  on(:user_notifications_digest_sent) do |user|
    begin
      # Securely generate a 20-digit string
      # SecureRandom.random_number(10**20) ensures it stays within the 20-digit range
      email_id = SecureRandom.random_number(10**20).to_s.rjust(20, '0')
      
      # Extract the internal Discourse User ID
      discourse_user_id = user.id

      # External endpoint configuration
      uri = URI.parse("https://ai.templetrends.com/digest_report.php")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.open_timeout = 2 
      http.read_timeout = 2 

      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data({ 
        "email_id" => email_id,
        "user_id" => discourse_user_id 
      })

      http.request(request)

    rescue StandardError => e
      # Failsafe: Log the error to /logs but do not interrupt the mailer
      Rails.logger.error("Digest Notifier Plugin Failure for User #{user&.id}: #{e.message}")
    end
  end
end
