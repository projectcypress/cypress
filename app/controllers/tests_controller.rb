class TestsController < ApplicationController

  before_filter :authenticate_user!

end