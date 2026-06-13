# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ApplicationRecord
  has_many :log_tags, dependent: :destroy
  has_many :logs, through: :log_tags

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }

  scope :used_by_user, lambda { |user|
    joins(:logs).where(logs: { user_id: user.id }).distinct.order(:name)
  }
end
