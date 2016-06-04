module PhotoCook
  module Optimization
    module CarrierWave
      def optimize
        PhotoCook::Optimization.perform(current_path)
      end
    end
  end
end
