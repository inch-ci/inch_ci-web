class Statistics < ActiveRecord::Base
  private

  def no_same_name_for_same_date
    if self.class.where(:date => date, :name => name).count > 0
      errors.add(:name, "name/date combination already exist")
    end
  end

  validate :no_same_name_for_same_date
  validates :date, :presence => true
  validates :name, :presence => true
end
