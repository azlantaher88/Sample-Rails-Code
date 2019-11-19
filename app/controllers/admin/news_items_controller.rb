class Admin::NewsItemsController < Admin::BaseController
  selection :all
  selection :published

  def index
    @news_items = self.selection_scope.page(params[:page] || 1)
  end

protected
  def scope
    NewsItem
  end
end
