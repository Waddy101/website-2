# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: 'show'

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show; end

  # GET /events/new
  def new
    @event = Event.new
    facebook_event = FacebookService.get_event(params[:facebook_event_id]) unless params[:facebook_event_id].blank?
    @event = Event.new_from_facebook_event(facebook_event) if facebook_event
  rescue Koala::Facebook::ClientError => e
    flash[:alert] = "Facebook event could not be retrieved - #{e.message}"
  end

  # GET /events/1/edit
  def edit; end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        begin
          FacebookService.post_event(@event) if params['event']['facebook'].to_i.positive?
        rescue Koala::Facebook::ClientError => e
          flash[:alert] = "Facebook: #{e.inspect}"
        end
        TwitterService.post_event(@event) if params['event']['twitter'].to_i.positive?
        DiscordService.post_event(@event) if params['event']['discord'].to_i.positive?
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:name, :description, :image_link, :datetime, :location, :lan_number, :facebook_event_id, :ticket_link)
  end
end
