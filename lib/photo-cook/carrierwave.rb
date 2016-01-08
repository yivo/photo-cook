module PhotoCook
  module CarrierWave
    def resize(*args)
      PhotoCook.resize(url, *args)
    end

    def base64_uri(*args)
      PhotoCook.base64_uri(url, *args)
    end

    def hresize(*args)
      PhotoCook.hresize(url, *args)
    end

    def vresize(*args)
      PhotoCook.vresize(url, *args)
    end
  end
end