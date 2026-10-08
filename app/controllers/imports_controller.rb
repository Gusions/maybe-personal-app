class ImportsController < ApplicationController
  before_action :set_import, only: %i[show publish destroy revert apply_template]

  def publish
    @import.publish_later

    redirect_to import_path(@import), notice: "L'importazione è partita in background."
  rescue Import::MaxRowCountExceededError
    redirect_back_or_to import_path(@import), alert: "La tua importazione supera il numero massimo di righe consentite di #{@import.max_row_count}."
  end

  def index
    @imports = Current.family.imports

    render layout: "settings"
  end

  def new
    @pending_import = Current.family.imports.ordered.pending.first
  end

  def create
    account = Current.family.accounts.find_by(id: params.dig(:import, :account_id))
    import = Current.family.imports.create!(
      type: import_params[:type],
      account: account,
      date_format: Current.family.date_format,
    )

    redirect_to import_upload_path(import)
  end

  def show
    if !@import.uploaded?
      redirect_to import_upload_path(@import), alert: "Completa il caricamento del file."
    elsif !@import.publishable?
      redirect_to import_confirm_path(@import), alert: "Completa le mappature prima di procedere."
    end
  end

  def revert
    @import.revert_later
    redirect_to imports_path, notice: "L'importazione è in fase di ripristino in background."
  end

  def apply_template
    if @import.suggested_template
      @import.apply_template!(@import.suggested_template)
      redirect_to import_configuration_path(@import), notice: "Modello applicato."
    else
      redirect_to import_configuration_path(@import), alert: "Nessun modello trovato, configura manualmente la tua importazione."
    end
  end

  def destroy
    @import.destroy

    redirect_to imports_path, notice: "La tua importazione è stata eliminata."
  end

  private
    def set_import
      @import = Current.family.imports.find(params[:id])
    end

    def import_params
      params.require(:import).permit(:type)
    end
end
