class Admin::AlertsController < Admin::BaseController
  before_action :load_report
  before_action :load_alert, except: [ :index, :new, :create ]
  before_action :build_alert, only: [ :new, :create ]

  selection :all,
    scope: lambda { |_| Alert.deleted(false) }
  selection :published
  selection :deleted

  def index
    @alerts = self.selection_scope.page(params[:page] || 1)
  end

  def new
  end

  def create
    @alert.save!

    @alert.reports << @report if @report

    redirect_to(admin_alert_path(@alert))

  rescue ActiveRecord::RecordInvalid
    delegate(:new)
  end

  def show
  end

  def edit
  end

  def update
    @alert.update_attributes!(alert_params)

    redirect_to(admin_alert_path(@alert))

  rescue ActiveRecord::RecordInvalid
    delegate(:new)
  end

  def publish
    @alert.published!

    redirect_to(admin_alert_path(@alert))
  end

  def unpublish
    @alert.published!(false)

    redirect_to(admin_alert_path(@alert))
  end

  def destroy
    @alert.deleted!

    redirect_to(admin_alerts_path)
  end

protected
  def scope
    Alert
  end

  def load_report
    return unless (params[:report_id])

    @report = Report.find_by(ident: params[:report_id])
  end

  def load_alert
    @alert = Alert.find(params[:id])
  end

  def build_alert
    @alert = Alert.new(alert_params)

    if (@report)
      @alert.headline ||= @report.description
    end

    @alert.metadata ||= Alert.metadata_default
    @alert.user = session_user
  end

  def alert_params
    params.fetch(:alert, { }).permit!
  end
end
