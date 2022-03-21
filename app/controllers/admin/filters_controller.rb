module Admin
  class FiltersController < AdminController
    before_action :set_filter, only: %i[edit update destroy]

    def index
      @filters = current_user.filters
    end

    def new
      @filter = current_user.filters.build
    end

    def create
      @filter = current_user.filters.build(filter_params)

      respond_to do |format|
        if @filter.save
          format.html { redirect_to admin_filters_path, notice: "Filter was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @filter.update(filter_params)
          format.html { redirect_to admin_filters_path, notice: "Filter was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @filter.destroy
      respond_to do |format|
        format.html { redirect_to admin_filters_url, notice: "Filter was successfully deleted." }
      end
    end

    private

    def set_filter
      @filter = current_user.filters.find(params[:id])
    end

    def filter_params
      params.require(:filter).permit(:id, :comparison, :value)
    end
  end
end
