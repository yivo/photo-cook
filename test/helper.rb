module TestHelper
  class << self
    def fixtures_dirpath
      File.expand_path('../fixtures', __FILE__)
    end

    def tmp_dirpath
      File.expand_path('../../tmp', __FILE__)
    end
  end
end
