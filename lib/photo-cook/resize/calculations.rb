# encoding: utf-8
# frozen_string_literal: true

module PhotoCook
  module Resize
    module Calculations
      class << self
        def size_to_fit(maxw, maxh, reqw, reqh, round = true)
          outw, outh = maxw, maxh

          scale = outw > reqw ? reqw / convert(outw) : 1.0
          outw, outh = outw * scale, outh * scale

          scale = outh > reqh ? reqh / convert(outh) : 1.0
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
                outh = (outh * maxw) / convert(outw)
                outw = maxw
              end
            else
              outw = maxw
              outh = (maxw * reqh) / reqw

              if outh > maxh
                outw = (outw * maxh) / convert(outh)
                outh = maxh
              end
            end

          elsif reqw > maxw
            outw = maxw
            outh = (reqh * maxw) / convert(reqw)

          elsif reqh > maxh
            outw = (reqw * maxh) / convert(reqh)
            outh = maxh
          end

          round ? [round(outw), round(outh)] : [outw, outh]
        end

        def round(x)
          PhotoCook::Pixels.round(x)
        end

      private
        def convert(x)
          x.kind_of?(Float) ? x : x.to_f
        end
      end
    end
  end
end
