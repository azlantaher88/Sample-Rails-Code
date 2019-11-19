class Admin::PeopleController < Admin::BaseController
  before_action :load_person, except: [ :index, :new, :create ]

  selection :all,
    scope: lambda { |_| Person.deleted(false) }
  selection :deleted,
    scope: lambda { |_| Person.deleted }

  def index
    @people = self.selection_scope.page(params[:page] || 1)
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
    @person.deleted!
    @person.searchable!(false)

    redirect_to(admin_people_path)
  end

protected
  def scope
    Person.deleted(false)
  end

  def load_person
    @person = Person.find(params[:id])
  end
end
