class ChallengesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_challenge, only: [ :show, :update, :edit, :participate, :leave ]

  def index
    sort_direction = params[:sort] == "desc" ? :desc : :asc
    @challenges = policy_scope(Challenge).order(start_date: sort_direction)

    # Filtre pour afficher uniquement les challenges de l'utilisateur connecté
    if user_signed_in? && params[:owner] == "me"
      @challenges = @challenges.where(user: current_user)
      @page_title = "Mes Challenges"
    else
      @page_title = "Challenges"
    end
  end

  def show
    authorize @challenge
  end

  def new
    @challenge = Challenge.new
    authorize @challenge
  end

  def create
    @challenge = Challenge.new(challenge_params)
    @challenge.user = current_user
    authorize @challenge
    if @challenge.save
      redirect_to @challenge, notice: "created !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @challenge
  end

  def update
    authorize @challenge
    if @challenge.update(challenge_params)
      redirect_to @challenge, notice: "Updated !"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def participate
    authorize @challenge, :show?

    participation = @challenge.challenge_participations.build(user: current_user)

    if participation.save
      redirect_back(fallback_location: @challenge, notice: "🎉 Vous participez maintenant à '#{@challenge.name}' (#{@challenge.participants.count}/10 participants)")
    else
      redirect_back(fallback_location: @challenge, alert: "❌ #{participation.errors.full_messages.join(", ")}")
    end
  end

  def leave
    authorize @challenge, :show?

    participation = @challenge.challenge_participations.find_by(user: current_user)

    if participation&.destroy
      redirect_back(fallback_location: @challenge, notice: "👋 Vous avez quitté '#{@challenge.name}' (#{@challenge.participants.count}/10 participants)")
    else
      redirect_back(fallback_location: @challenge, alert: "❌ Impossible de quitter ce challenge.")
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
