module Admin
  class RulesController < AdminController
    before_action :set_rule, only: %i[edit update destroy]

    def index
      @rules = current_user.filter_engine_rules
    end

    def new
      @rule = FilterEngine::KeywordRule.new user: current_user
    end

    def create
      @rule = current_user.filter_engine_rules.new(rule_params.to_h.update(type: FilterEngine::KeywordRule, user: current_user))

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
      params.require(:rule).permit(:id, :comparison, :value)
    end
  end
end
