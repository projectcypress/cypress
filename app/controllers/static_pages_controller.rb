# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  def terms_and_conditions; end
end
