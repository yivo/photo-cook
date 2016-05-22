module PhotoCook
  class ImageOptim < AbstractOptimizer
    def optimize(path, opts_or_sym = :lossless)
      PhotoCook.logger.will_perform_optimization(path)

      image_optim = case opts_or_sym
        when Hash
          opts_or_sym.empty? ? default_image_optim : ::ImageOptim.new(opts_or_sym)
        when Symbol then named_image_optim(opts_or_sym)
        else default_image_optim
      end

      started     = Time.now
      result      = image_optim.optimize_image!(path)

      case result
        when ::ImageOptim::ImagePath::Optimized
          msec = (Time.now - started) * 1000.0
          PhotoCook.logger.performed_optimization(path, result.original_size, result.size, msec)
        else
          PhotoCook.logger.no_optimization_performed(path)
      end

      result
    end

  protected
    def named_image_optim(name)
      case name
        when :lossless then lossless_image_optim
        when :lossy    then lossy_image_optim
        else                default_image_optim
      end
    end

  private
    def lossless_image_optim
      @lossless_image_optim ||= ::ImageOptim.new
    end

    def default_image_optim
      lossy_image_optim
    end

    # https://github.com/toy/image_optim
    def lossy_image_optim
      @lossy_image_optim ||= ::ImageOptim.new(

        # Nice level (defaults to 10)
        nice: 10,

        # Number of threads or disable (defaults to number of processors)
        threads: nil,

        # Verbose output (defaults to false)
        verbose: false,

        # Require image_optim_pack or disable it, by default image_optim_pack will be used if available, will turn on :skip-missing-workers unless explicitly disabled (defaults to nil)
        pack: nil,

        # Skip workers with missing or problematic binaries (defaults to false)
        skip_missing_workers: true,

        # Allow lossy workers and optimizations (defaults to false)
        allow_lossy: false,

        advpng: {
          # Compression level: 0 - don't compress, 1 - fast, 2 - normal, 3 - extra, 4 - extreme (defaults to 4)
          level: 1
        },
        gifsicle: {
          # Interlace: true - interlace on, false - interlace off, nil - as is in original image (defaults to running two instances, one with interlace off and one with on)
          interlace: nil,

          # Compression level: 1 - light and fast, 2 - normal, 3 - heavy (slower) (defaults to 3)
          level: 1,

          # Avoid bugs with some software (defaults to false)
          careful: false
        },
        jhead: {},
        jpegoptim: {
          # List of extra markers to strip: :comments, :exif, :iptc, :icc or :all (defaults to :all)
          strip: :all,

          # Maximum image quality factor 0..100, ignored in default/lossless mode (defaults to 100)
          max_quality: 100
        },
        jpegrecompress: {
          # JPEG quality preset: 0 - low, 1 - medium, 2 - high, 3 - veryhigh (defaults to 3)
          quality: 3
        },
        jpegtran: {

          # Copy all chunks
          copy_chunks: false,

          # Create progressive JPEG file
          progressive: true,

          # Use jpegtran through jpegrescan, ignore progressive option
          jpegrescan: false
        },
        optipng: {
          # Optimization level preset: 0 is least, 7 is best
          level: 3,

          # Interlace: true - interlace on, false - interlace off, nil - as is in original image
          interlace: false,

          # Remove all auxiliary chunks (defaults to true)
          strip: true
        },
        pngcrush: {
          # List of chunks to remove or :alla - all except tRNS/transparency or :allb - all except tRNS and gAMA/gamma (defaults to :alla)
          chunks: :alla,

          # Fix otherwise fatal conditions such as bad CRCs (defaults to false)
          fix: false,

          # Brute force try all methods, very time-consuming and generally not worthwhile (defaults to false)
          brute: false,

          # Blacken fully transparent pixels (defaults to true)
          blacken: true
        },
        pngout: {
          # Copy optional chunks (defaults to false)
          copy_chunks: false,

          # Strategy: 0 - xtreme, 1 - intense, 2 - longest Match, 3 - huffman Only, 4 - uncompressed (defaults to 0)
          strategy: 2
        },
        pngquant: {
          # min..max - don't save below min, use less colors below max (both in range 0..100; in yaml - !ruby/range 0..100), ignored in default/lossless mode (defaults to 100..100, 0..100 in lossy mode)
          quality: 100..100,

          # speed/quality trade-off: 1 - slow, 3 - default, 11 - fast & rough (defaults to 3)
          speed: 11
        },
        svgo: {
          # List of plugins to disable (defaults to [])
          disable_plugins: [],

          # List of plugins to enable (defaults to [])
          enable_plugins: []
        }
      )
    end
  end
end