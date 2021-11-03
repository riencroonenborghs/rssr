module Admin
  class RulesController < AdminController
    before_action :set_rule, only: %i[edit update destroy]

    def index
      @rules = current_user.filter_engine_rules
    end

    def new
      @rule = FilterEngine::KeywordRule.new user: current_user, group_id: 1
    end

    def create
      @rule = current_user.filter_engine_rules.new(rule_params)

      respond_to do |format|
        if @rule.save
          format.html { redirect_to admin_rules_path, notice: "Rule was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @rule.update(rule_params)
          format.html { redirect_to admin_rules_path, notice: "Rule was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @rule.destroy
      respond_to do |format|
        format.html { redirect_to admin_rules_url, notice: "Rule was successfully destroyed." }
      end
    end

    private

    def set_rule
      @rule = current_user.filter_engine_rules.find(params[:id])
    end

    def rule_params
      params.require(:rule).permit(:id, :type, :comparison, :value, :group_id)
    end
  end
end
