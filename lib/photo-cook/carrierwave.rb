module PhotoCook
  module CarrierWave

    def resize(*args)
      PhotoCook.resize(url, *args)
    end

  end
end