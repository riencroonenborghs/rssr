module FilterEngine
  class FilterEngine::Rule < ApplicationRecord
    VALID_COMPARISONS = %w{eq ne lt lte gt gte}
    
    belongs_to :user
    
    validates :value, presence: true
    validates :comparison, inclusion: { in: VALID_COMPARISONS }

    def chain(scope)
      raise "#chain(scope) implement me"
    end
    
    def human_readable
      raise "#human_readable) implement me"
    end

    private
    
    def sql_comparison
      raise "#sql_comparison implement me"
    end
  end
end