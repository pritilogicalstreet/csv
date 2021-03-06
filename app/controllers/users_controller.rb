class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv }
    end
  end
  
  def import
    b = User.import(params[:file])
    redirect_to users_path, notice: "#{b}"
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path
      flash.alert = "user  created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to users_path
      flash.alert = "user updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to @user
  end

  private
  def user_params
    params.require(:user).permit(:name, :password)
  end
end
