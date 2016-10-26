class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed_items.includes(:user).order(created_at: :desc).page(params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost = current_user.microposts.find_by(id: params[:id])
    return redirect_to root_url if @micropost.nil?
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end

  # リツイート機能
  def retweet
    original = Micropost.find(params[:id])
    retweet = current_user.microposts.build(original: original.id)
    retweet.content = "＃ #{original.user.name}さんのリツイート　\n #{original.content}"
    retweet.image = original.image
    if retweet.save
      flash[:success] = "リツイートしました"
      redirect_to current_user
    else
      redirect_to :back
    end
  end

  private
  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end
end