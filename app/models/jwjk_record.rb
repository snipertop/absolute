class JwjkRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :jwjk, reading: :jwjk_replica }
end