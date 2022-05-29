class ScoresController < ApplicationController

    def index
        
    end

    def search
        xn = params[:xn]
        xq = params[:xq]
        @scores = Score.where({user_xh: "20190141137", xn: xn, xq: xq})
        respond_to do |format|
            format.turbo_stream do
              render turbo_stream: 
                turbo_stream.update("search_results", partial: "scores/search_results", locals: { scores: @scores })
            end
        end
    end

end