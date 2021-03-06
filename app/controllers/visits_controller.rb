class VisitsController < ApplicationController
  before_action :set_visit, only: [:show, :edit, :update, :destroy]

  # GET /visits
  # GET /visits.json
  def index
    @visits = Visit.all
  end

  # GET /visits/1
  # GET /visits/1.json
  def show
  end

  # GET /exhibitions/:exhibition_id/visits/new
  def new
    @exhibition = Exhibition.find(params[:exhibition_id])
    @visit = Visit.new

  end

  # GET /visits/1/edit
  def edit
  end

  # POST /visits
  # POST /visits.json
  def create
    @exhibition       = Exhibition.find(params[:exhibition_id])
    @visit            = Visit.new(visit_params)
    if @exhibition.visits.count >= @exhibition.capacity
      respond_to do |format|
        format.html { redirect_to exhibition_path(params[:exhibition_id]), notice: 'Capacité du lieu atteinte. Impossible de vous y inscrire' }
      end
    else
      if @visit.coming_at < @exhibition.opening_at
        respond_to do |format|
          format.html { redirect_to exhibition_path(params[:exhibition_id]), notice: "Votre date de visite doit être comprise dans les dates d'ouverture de l'exposition" }
        end
      else
        if @visit.coming_at >= @exhibition.closing_at
          respond_to do |format|
            format.html { redirect_to exhibition_path(params[:exhibition_id]), notice: "Votre date de visite doit être comprise dans les dates d'ouverture de l'exposition" }
          end
        else
          @visit.exhibition = @exhibition
          @visit.user       = current_user

          respond_to do |format|
            if @visit.save
              UserNotifier.send_registration_email(@visit).deliver_later

              format.html { redirect_to exhibition_path(params[:exhibition_id]), notice: 'Visit was successfully created.' }
              format.json { render :show, status: :created, location: @visit }
            else
              format.html { render :new }
              format.json { render json: @visit.errors, status: :unprocessable_entity }
            end
          end
        end
      end
    end
  end

  # PATCH/PUT /visits/1
  # PATCH/PUT /visits/1.json
  def update
    respond_to do |format|
      if @visit.update(visit_params)
        format.html { redirect_to @visit, notice: 'Visit was successfully updated.' }
        format.json { render :show, status: :ok, location: @visit }
      else
        format.html { render :edit }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visits/1
  # DELETE /visits/1.json
  def destroy
    @visit.destroy
    respond_to do |format|
      format.html { redirect_to visits_url, notice: 'Visit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_visit
      @visit = Visit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def visit_params
      params.require(:visit).permit(:coming_at, :user, :exhibition)
    end
end
