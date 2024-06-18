class SearchController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!

  def index
    if current_user.seller?
      # Lojas proprias
      @stores = Store.search(
        params[:search],
        fields: [{name: :text_middle}],
        match: :word_start,
        misspellings: {fuzziness: 2},
        where: {user_id: current_user.id},
        limit: 10
      )
      # Produtos proprios
      @products = Product.search(
        params[:search],
        fields: [{title: :text_middle}],
        match: :word_start,
        misspellings: {fuzziness: 2},
        where: {expired: false, store_user_id: current_user.id},
        limit: 10
      )
    elsif current_user.buyer?
      # Lojas visiveis
      @stores = Store.search(
        params[:search],
        fields: [{name: :text_middle}],
        match: :word_start,
        misspellings: {fuzziness: 2},
        where: {hidden: false},
        limit: 10
      )
      # Produtos de lojas visiveis de lojas visiveis
      @products = Product.search(
        params[:search],
        fields: [{title: :text_middle}],
        match: :word_start,
        misspellings: {fuzziness: 2},
        where: {hidden: false, expired: false, store_hidden: false},
        limit: 10
      )
    else
      render status: :forbidden, json: { error: "Unauthorized access" }
    end
  end

  private

  def search_params
    required = params.require(:search)
  end
end
