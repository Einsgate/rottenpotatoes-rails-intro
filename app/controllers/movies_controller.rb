class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @my_debug = false
    
    @classes = {}
    @checked = {}
    @all_ratings = Movie.select(:rating).distinct
    
    # Load params from the session
    if (not params[:ratings]) and (not params[:order]) 
      if session[:params]
        if session[:params]["ratings"] or session[:params]["order"]
          flash.keep
          redirect_to controller: "movies", action: "index", ratings: session[:params]["ratings"], order: session[:params]["order"]
        end
      end
    elsif not params[:ratings]
      if session[:params] and session[:params]["ratings"]
        flash.keep
        redirect_to controller: "movies", action: "index", ratings: session[:params]["ratings"], order: params[:order]
      end
    elsif not params[:order]
      if session[:params] and session[:params]["order"]
        flash.keep
        redirect_to controller: "movies", action: "index", ratings: params[:ratings], order: session[:params]["order"]
      end
    end
    
    # Filter first
    if params[:ratings]
      @movies = Movie.with_ratings(params[:ratings].keys)
      for key in params[:ratings].keys
        @checked[key] = true
      end
    else
      @movies = Movie.all
      for rating in @all_ratings
         @checked[rating.rating] = true
      end
    end
    
    if params[:order] == 'title'
      @movies = @movies.order(:title)
      @classes[:title_header] = "hilite bg-warning"
    elsif params[:order] == 'release_date'
      @movies = @movies.order(:release_date)
      @classes[:release_date_header] = "hilite bg-warning"
    end
    
    # Store params in session
    session[:params] = params.clone
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
