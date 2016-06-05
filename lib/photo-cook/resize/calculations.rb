# frozen_string_literal: true
module PhotoCook
  module Resize
    module Calculations
      class << self
        def size_to_fit(maxw, maxh, reqw, reqh, round = true)
          outw, outh = maxw, maxh

          scale = outw > reqw ? reqw / outw.to_f : 1.0
          outw, outh = outw * scale, outh * scale

          scale = outh > reqh ? reqh / outh.to_f : 1.0
          outw, outh = outw * scale, outh * scale

          round ? [round(outw), round(outh)] : [outw, outh]
        end

        def size_to_fill(maxw, maxh, reqw, reqh, round = true)
          outw, outh = reqw, reqh

          if reqw > maxw && reqh > maxh
            if maxw >= maxh
              outw = (reqw * maxh) / reqh.to_f
              outh = maxh

              if outw > maxw
                outh = (outh * maxw) / outw.to_f
                outw = maxw
              end
            else
              outw = maxw
              outh = (maxw * reqh) / reqw

              if outh > maxh
                outw = (outw * maxh) / outh.to_f
                outh = maxh
              end
            end

          elsif reqw > maxw
            outw = maxw
            outh = (reqh * maxw) / reqw.to_f

          elsif reqh > maxh
            outw = (reqw * maxh) / reqh.to_f
            outh = maxh
          end

          round ? [round(outw), round(outh)] : [outw, outh]
        end

        def round(x)
          PhotoCook::Pixels.round(x)
        end
      end
    end
  end
end
