class ChallengesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_challenge, only: [ :show, :update, :edit ]

  def index
    sort_direction = params[:sort] == "desc" ? :desc : :asc
    @challenges = Challenge.order(start_date: sort_direction)
  end

  def show
  end

  def new
    @challenge = Challenge.new
  end

  def create
    @challenge = Challenge.new(challenge_params)
    if @challenge.save
      redirect_to @challenge, notice: "created !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @challenge.update(challenge_params)
      redirect_to @challenge, notice: "Updated !"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:name, :description, :start_date, :end_date)
  end
end
