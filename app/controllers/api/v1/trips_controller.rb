class Api::V1::TripsController < ApplicationController
  skip_before_action :authorized

  def index
    if request.headers['term']
      term = request.headers['term'].split(",")
      @trips = Trip.searchable(term)
      render json: @trips
    else
      @trips = Trip.all
      render json: @trips, include: [:trip_lead, :park]
    end
  end

  def create
    @user = User.find_by(username: params[:trip_lead][:username])
    @trip = Trip.new(trip_params)
    @trip.trip_lead = @user
    @trip.save!
    if @trip.save
      UserTrip.create!(
        trip: @trip,
        user: @trip.trip_lead
      )
      ParkTrip.create!(
        park: @trip.park,
        trip: @trip
      )

     render json: @trip, include: [:trip_lead, :park]
    else
      render json: { error: 'failed to create trip'}, status: :not_acceptable
    end
  end

  def edit
    @trip = Trip.find_by(id: params[:trip_id])
  end

  def update
    @trip = Trip.find_by(id: params[:trip_id])
    @user = User.find_by(username: params[:username])
    @user_trip = UserTrip.new(
      user: @user,
      trip: @trip
    )
    if @user_trip.save!
      render json: @trip, include: :user_trips
    else
      render json: {message: 'you have already joined this trip'}, status: :not_acceptable
    end
  end

  private

  def trip_params
    params.require(:trip).permit(:name, :state, :description, :start_date, :end_date, :park_id, :trip_goers, :trip_lead, :difficulty_rating)
  end
end