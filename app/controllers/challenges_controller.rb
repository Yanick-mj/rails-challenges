class ChallengesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_challenge, only: [:show, :edit, :update, :destroy, :participate, :leave]
  before_action :authorize_challenge, only: [:edit, :update, :destroy]

  def index
    @challenges = Challenge.includes(:user, :participants).all
  end

  def show
    @participants = @challenge.participants.includes(:challenge_participations)
    @can_participate = user_signed_in? && @challenge.can_participate?(current_user)
  end

  def new
    @challenge = current_user.challenges.build
  end

  def create
    @challenge = current_user.challenges.build(challenge_params)
    
    if @challenge.save
      redirect_to @challenge, notice: 'Challenge was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @challenge.update(challenge_params)
      redirect_to @challenge, notice: 'Challenge was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @challenge.destroy
    redirect_to challenges_url, notice: 'Challenge was successfully deleted.'
  end

  def participate
    unless user_signed_in?
      redirect_to new_user_session_path, alert: 'You must be logged in to participate.'
      return
    end

    @participation = @challenge.challenge_participations.build(user: current_user)
    
    if @participation.save
      redirect_to @challenge, notice: 'You have successfully joined this challenge!'
    else
      redirect_to @challenge, alert: @participation.errors.full_messages.join(', ')
    end
  end

  def leave
    @participation = @challenge.challenge_participations.find_by(user: current_user)
    
    if @participation
      @participation.destroy
      redirect_to @challenge, notice: 'You have left this challenge.'
    else
      redirect_to @challenge, alert: 'You are not participating in this challenge.'
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:name, :description, :start_date, :end_date)
  end

  def authorize_challenge
    redirect_to challenges_path, alert: 'Not authorized.' unless @challenge.user == current_user
  end
end
