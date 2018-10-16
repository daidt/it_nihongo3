class BooksController < ApplicationController
	def new
		@book = current_user.books.new
	end
	def show
		@book = Book.find(params[:id])
	end

	def create
		@book = current_user.books.new(book_params)    
		if @book.save
			redirect_to @book
		else render 'new'
		end
	end

	def edit
    @book = Book.all
  	end


	private

    def book_params
      params.require(:book).permit(:title, :author, :issue_date, :publishing_company,:description,
     	:picture,:category_id)
    end
end