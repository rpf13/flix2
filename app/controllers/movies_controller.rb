class MoviesController < ApplicationController

  before_action :require_signin, except: [:index, :show]
  before_action :require_admin, except: [:index, :show]
  def index
    @movies = Movie.send(movies_filter)
    # old version not using the "send method"
    # take care, for security reasons the send method
    # MUST use the private "movies_filter" method, otherwise
    # all scopes would be exposed to the public

    # case params[:filter]
    # when "upcoming"
    #   @movies = Movie.upcoming
    # when "recent"
    #   @movies = Movie.recent
    # when "hits"
    #   @movies = Movie.hits
    # when "flops"
    #   @movies = Movie.flops
    # else
    #   @movies = Movie.released
    # end
  end

  def show
    @movie = Movie.find(params[:id])
    @fans = @movie.fans
    @genres = @movie.genres.order(:name)

    if current_user
      @favorite = current_user.favorites.find_by(movie_id: @movie.id)
    end
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def update
    @movie = Movie.find(params[:id])
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Movie successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      redirect_to @movie, notice: "Movie successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    redirect_to movies_path, status: :see_other, alert: "Movie successfully deleted!"
  end

  private

  def movie_params
    params.require(:movie).
        permit(:title, :rating, :description, :released_on, :total_gross, :director, :duration, :image_file_name, genre_ids: [])
  end

  def movies_filter
    if params[:filter].in? %w(upcoming recent hits flops)
      params[:filter]
    else
      :released
    end
  end
end
