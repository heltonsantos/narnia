module PaginationConcern
  extend ActiveSupport::Concern

  def page
    params['page'] || 1
  end

  def per_page
    params['per_page'] || 100
  end
end
