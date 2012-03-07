class CommentsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @book = Book.find(params[:book_id]) if params[:book_id]
    @comment = Comment.find(params[:id]) if params[:id]
  end
  
  def index
    @comments = @book.comments
  end
  
  def create
    @comment = @book.comments.build(params[:comment])
    @comment.creator = current_user
    if !@comment.save
      error = @comment.errors.first
      flash[:error] = "#{error[0]} #{error[1]}"
    end
    redirect_to "/books/#{@book.id}/comments"
  end
  
  def reply
  end
  
  def do_reply
    book = @comment.model
    reply_comment = book.comments.build(params[:comment])
    reply_comment.reply_comment_id = @comment.id
    reply_comment.creator = current_user
    if reply_comment.save
      return redirect_to "/books/#{book.id}/comments"
    end
    error = reply_comment.errors.first
    flash[:error] = "#{error[0]} #{error[1]}"
    redirect_to "/comments/#{@comment.id}/reply"
  end
end
