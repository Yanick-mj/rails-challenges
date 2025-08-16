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
      # Track la création de challenge
      AnalyticsService.track_challenge_created(current_user, @challenge)

      redirect_to @challenge, notice: "created !"
    else
      # Track les erreurs de validation
      AnalyticsService.track_validation_error(current_user, "Challenge", @challenge.errors)

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @challenge
  end

  def update
    authorize @challenge

    # Capturer les changements avant la mise à jour
    changes = @challenge.changes if @challenge.changed?

    if @challenge.update(challenge_params)
      # Track la modification de challenge
      AnalyticsService.track_challenge_updated(current_user, @challenge, changes || {})

      redirect_to @challenge, notice: "Updated !"
    else
      # Track les erreurs de validation
      AnalyticsService.track_validation_error(current_user, "Challenge", @challenge.errors)

      render :edit, status: :unprocessable_entity
    end
  end

  def participate
    authorize @challenge, :show?

    participation = @challenge.challenge_participations.build(user: current_user)

    if participation.save
      # Track la participation au challenge
      AnalyticsService.track_challenge_joined(current_user, @challenge)

      redirect_back(fallback_location: @challenge, notice: "🎉 Vous participez maintenant à '#{@challenge.name}' (#{@challenge.participants.count}/#{@challenge.max_participants} participants)")
    else
      # Track les erreurs de participation
      AnalyticsService.track_error(current_user, "Participation Error", participation.errors.full_messages.join(", "), {
        challenge_id: @challenge.id,
        challenge_name: @challenge.name
      })

      redirect_back(fallback_location: @challenge, alert: "❌ #{participation.errors.full_messages.join(", ")}")
    end
  end

  def leave
    authorize @challenge, :show?

    participation = @challenge.challenge_participations.find_by(user: current_user)

    if participation&.destroy
      # Track le départ du challenge
      AnalyticsService.track_challenge_left(current_user, @challenge)

      redirect_back(fallback_location: @challenge, notice: "👋 Vous avez quitté '#{@challenge.name}' (#{@challenge.participants.count}/#{@challenge.max_participants} participants)")
    else
      # Track les erreurs de départ
      AnalyticsService.track_error(current_user, "Leave Error", "Impossible de quitter le challenge", {
        challenge_id: @challenge.id,
        challenge_name: @challenge.name
      })

      redirect_back(fallback_location: @challenge, alert: "❌ Impossible de quitter ce challenge.")
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:id])
  end

  def challenge_params
    params.require(:challenge).permit(:name, :description, :start_date, :end_date, :max_participants)
  end
end
