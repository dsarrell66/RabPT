class Refractive
  # A basic diffuse material.
  require_relative 'material.rb'
  require 'pry'
  
  include Material
  attr_accessor :refractive_idx 
  
  # @param refractive_idx:Float refractive index
  def initialize(refractive_idx)
    @refractive_idx = refractive_idx
  end
  
  def evaluate_brdf(hit_record, w_out, w_in)
    Spectrum.new(@k_d)
  end
  
  def evaluate_emission(hit_record, w_out)
    nil
  end
  
  def has_specular_reflection?
    true
  end
  
  def evaluate_specular_reflection(hit_record)
    normal = hit_record.normal.s_copy
    w_in = hit_record.normal.s_copy
    
    n_1 = 1.0
    n_2 = @refractive_idx
    
    # is hit not inside refractive material
    unless inside_material?(normal, w_in)
      n_1 = @refractive_idx
      n_2 = 1.0
      normal.negate
    end
    
    refraction_ratio = n_1/n_2
    cos_theta_i = w_in.dot(normal)
		w_in.negate();
    
    sin2_thata_t = (refraction_ratio**2.0)*(1.0-(cos_theta_i**2.0))
    cos_theta_t = Math::sqrt(1.0 - sin2_thata_t)
    
    total_internal_refraction = (sin2_thata_t > 1)
    
    # schlick approximation for refraction coefficient R     
    return nil if total_internal_refraction
    reflected_part = compute_schlick_r(n_1, n_2, cos_theta_i, cos_theta_t)  
  
		return nil if (reflectedPart < 1e-5)
    
    r_dir = w_in.s_copy
    scaled_normal = normal.s_copy.scale(2.0*cos_theta_i)
    r_dir.add(scaled_normal)
    
    brdf_contribution = Spectrum.new(1.0)
		brdf_contribution.mult(reflected_part) 

    brdf_contribution = Spectrum.new(1.0)
    brdf_contribution.mult(1.0 - r_schlick)  
    args = {:brdf => brdf_contribution,
            :emission => Spectrum.new(0.0),
            :w => r_dir,
            :is_specular => true,
            :p => reflected_part}
		ShadingSample.new args
  end
  
  def has_specular_refraction?
    true
  end
  
  def evaluate_specular_refraction(hit_record)
    normal = hit_record.normal.s_copy
    w_in = hit_record.normal.s_copy
    
    n_1 = 1.0
    n_2 = @refractive_idx
    
    # is hit not inside refractive material
    unless inside_material?(normal, w_in)
      n_1 = @refractive_idx
      n_2 = 1.0
      normal.negate
    end
    
    refraction_ratio = n_1/n_2
    cos_theta_i = w_in.dot(normal)
		w_in.negate();
    
    sin2_thata_t = (refraction_ratio**2.0)*(1.0-(cos_theta_i**2.0))
    cos_theta_t = Math::sqrt(1.0 - sin2_thata_t)
    
    total_internal_refraction = (sin2_thata_t > 1)
    
    # schlick approximation for refraction coefficient R     
    return nil if total_internal_refraction
    r_schlick = compute_schlick_r(n_1, n_2, cos_theta_i, cos_theta_t)  
    
    # t from the paper
    t_vec = w_in.s_copy
    t_vec.scale(refraction_ratio)
    scale_factor = refraction_ratio*cos_theta_i - cos_theta_t
    tranformed_normal = normal.s_copy.scale(scale_factor)
    t_vec.add(tranformed_normal)
      
    brdf_contribution = Spectrum.new(1.0)
    brdf_contribution.mult(1.0 - r_schlick)  
    args = {:brdf => brdf_contribution,
            :emission => Spectrum.new(0.0),
            :w => t_vec,
            :is_specular => true,
            :p => 1.0-r_schlick}
		ShadingSample.new args
  end
  
  def shading_sample(hit_record, sample)
    evaluate_specular_reflection(hit_record);
  end
  
  def emission_sample(hit_record, sample)
    ShadingSample.new({})
  end
  
  def casts_shadows?
    false
  end
  
  def evaluate_bump_map(hit_record)
    nil
  end
  
  def to_s
    "refractive material using a refractive index equal to: #{@refractive_idx}"
  end
  
  private 
  
  # are we tracing a hit inside a specific material?
  # examines angles between surface normal 
  # and incident light direction
  # @param normal at surface hit
  # @param w_in incident light direction.
  def inside_material?(normal, w_in)
    normal.dot(w_in) > 0.0
  end
  
  # compute an approximation of the fresnel coefficient
  # used as the weight for refraction
  # @param n_1 'from' material refraction index 
  # @param n_2 'to' material refraction idex
  # @param cos_tehta_i angle between hit normal and incident light.
  # @param cos_theta_t TODO: see paper
  def compute_schlick_r(n_1, n_2, cos_theta_i, cos_theta_t)
    r_0 = ((n_1 - n_2) / (n_1 + n_2))**2.0
    x = (n_1 <= n_2) ? (1.0 - cos_theta_i) : (1.0 - cos_theta_t)
		r_0 + (1.0 - r_0)*(x**5.0)
  end
  
end