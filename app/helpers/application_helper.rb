module ApplicationHelper
    def full_title(page_title = '')
        if page_title.empty?
            base_title = "郑州商学院"
        else
            page_title
        end
    end
end
