class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")
  end

  def purchases
    @orders = Order.all.where(buyer: current_user).order("created_at DESC")
  end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
    Stripe.api_key = ENV["STRIPE_API_KEY"]
    token = params[:stripeToken]
    logger.debug "TOKEN IS: #{token}"
   end

  # POST /orders
  # POST /orders.json
  def create
    Stripe.api_key = ENV["STRIPE_API_KEY"]
    token = params[:stripeToken]
    logger.debug "TOKEN IS: #{token}"
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @seller = @listing.user

    @order.listing_id = @listing.id
    @order.buyer_id = current_user.id
    @order.seller_id = @seller.id
    begin
    Stripe.api_key = ENV["STRIPE_API_KEY"]
    token = params[:stripeToken]
    logger.debug "TOKEN IS: #{token}"
      charge = Stripe::Charge.create(
        :amount => (@listing.price * 100).floor,
        :currency => "usd", 
        :source => token
      )
      flash[:notice] = "Thanks for ordering!"
    rescue Stripe::CardError => e
      flash[:danger] = e.message
    end

#    transfer = Stripe::Transfer.create(
 #     :amount => (@listing.price * 25).floor,
  #    :currency => "usd",
     # :destination => @seller.recipient
    #)

    respond_to do |format|
      if @order.save
        format.html { redirect_to root_url, notice: "Thanks for ordering!" }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
          Stripe.api_key = ENV["STRIPE_API_KEY"]
      token = params[:stripeToken]
      logger.debug "TOKEN IS: #{token}"
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:address, :city, :state)
  end
end
