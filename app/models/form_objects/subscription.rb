# frozen_string_literal: true

module FormObjects
  class Subscription < Struct.new(:url, :title, :get_title_from_url, :tag_names, keyword_init: true)
    def self.from_params(subscription_params)
      new(
        url: subscription_params[:url],
        title: subscription_params[:title],
        get_title_from_url: subscription_params[:get_title_from_url],
        tag_names: subscription_params[:tag_names]
      )
    end
  end
end
