class BooksController < ApplicationController
  before_action :find_book, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit]
  before_action :get_categories, only: [:new, :edit, :create, :update]
  def index
    if params[:category].blank?
      @books = Book.all.order("created_at DESC")
    else
      @category_id = Category.find_by(name: params[:category])
      # @books = Book.where(:category_id => @category_id).order("created_at DESC")
      @books = @category_id.books
    end
  end

  def new
    @book = current_user.books.build
  end

  def show
    if @book.reviews.blank?
      @average_review = 0
    else
      @average_review = @book.reviews.average(:rating).round(2)
    end
  end

  def edit
    @bookcategories = @book.categories
  end

  def update
    @book.categories.destroy_all
    add_categories
    if @book.update(book_params)
      redirect_to @book
    else
      render 'edit'
    end
  end

  def destroy
    @book.destroy
    redirect_to root_path
  end

  def create
    @book = current_user.books.build(book_params)
    add_categories
    if @book.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  private
  def book_params
    params.require(:book).permit(:title, :description, :author, :category_id, :book_img)
  end

  def find_book
    @book = Book.find(params[:id])
  end

  def add_categories()
    if params[:book][:category_id]
      params[:book][:category_id].each {|category|
          @book.categories << Category.find_by(id: category)
      }
    end
  end

  def get_categories
    @categories = Category.all
  end
end
