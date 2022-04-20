class WexinUserController < ApplicationController
    include WexinUserHelper

    def index
        WexinUserHelper.wexin_user_sync
    end
end
