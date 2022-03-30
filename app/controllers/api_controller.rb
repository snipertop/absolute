class ApiController < ApplicationController
    include ApiHelper

    def index
        ApiHelper.jdy_account_sync
    end
end