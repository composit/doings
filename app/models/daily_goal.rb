class DailyGoal < Goal
  belongs_to :master_goal

  def period
    "Daily"
  end
end
