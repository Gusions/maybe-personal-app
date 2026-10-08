class Import::ConfirmsController < ApplicationController
  layout "imports"

  before_action :set_import

  def show
    if @import.mapping_steps.empty?
      return redirect_to import_path(@import)
    end

    redirect_to import_clean_path(@import), alert: "Hai dei dati non validi, modificali finché tutti gli errori non sono risolti" unless @import.cleaned?
  end

  private
    def set_import
      @import = Current.family.imports.find(params[:import_id])
    end
end
