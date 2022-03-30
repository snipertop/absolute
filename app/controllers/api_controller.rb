class ApiController < ApplicationController
    include ApiHelper

    def index
        jdy_account_sync
    end
end