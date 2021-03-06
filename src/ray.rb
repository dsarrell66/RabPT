# a ray is defined as a parametric line p(t) = origin + t*direction where t is
# a real-valued scalar.
#
# TODO: Note that we brute-force set t to 0.0
class Ray
  attr_accessor :origin,
                :direction,
                :should_perturbate,
                :t

  EPSILON = 0.00001

  def initialize(args={})
    init_values
    args.each do |key, value|
      send("#{key}=", value)
    end

    return if @should_perturbate.nil?

    @origin = @direction.s_copy.scale(EPSILON).add(@origin)
  end

  # get point on ray for a given parameter t.
  def point_at(t)
    dir = @direction.s_copy
    orig = @origin.s_copy
    tmp = dir.scale(t).add(orig)
    Vector3f.new(tmp.x, tmp.y, tmp.z)
  end

  def to_s
    "origin: #{@origin.to_s} direction: #{@direction.to_s}"
  end

  private

  def init_values
    v          = Vector3f.new(0.0, 0.0, 0.0)
    @origin    = v
    @direction = v
    @depth     = 0.0
    @t         = 0.0
  end
end
