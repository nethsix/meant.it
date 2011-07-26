ActionMailer::Base.smtp_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :domain               => "meant.it",  
  :user_name            => "thanks@meant.it",
  :password             => "p1ssth4nks",
  :authentication       => "plain",  
  :enable_starttls_auto => true  
}
