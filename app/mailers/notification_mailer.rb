class NotificationMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @url = root_url
    mail(to: @user.email, subject: "Bienvenue sur Rails Challenge !")
  end

  def challenge_created_email(user, challenge)
    @user = user
    @challenge = challenge
    @url = challenge_url(@challenge)
    mail(to: @user.email, subject: "Votre challenge '#{@challenge.name}' a été créé avec succès !")
  end

  def participation_email(user, challenge, action)
    @user = user
    @challenge = challenge
    @action = action # 'joined' ou 'left'
    @url = challenge_url(@challenge)

    subject = case @action
    when "joined"
                "Vous avez rejoint le challenge '#{@challenge.name}' !"
    when "left"
                "Vous avez quitté le challenge '#{@challenge.name}'"
    end

    mail(to: @user.email, subject: subject)
  end
end
