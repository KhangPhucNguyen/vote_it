class PollAnswer
  include Mongoid::Document

  belongs_to :user
  belongs_to :poll_option do
    def find_by_id(id)
      where(_id: id).first
    end
  end
end
