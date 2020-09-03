# frozen_string_literal: true

class TreeDomainEvent
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :path, :string
  attribute :planed_children, array: :string

  validates :path, presence: true
  validates :planed_children, presence: true

  def publish
    # TODO
  end
end
