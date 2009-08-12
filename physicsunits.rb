module PhysicsUnit
 #Preserve method_missing to invalid units
 alias :old_mm :method_missing

 #Units from SI
 SI_base = [ :m, :G, :s, :A, :K, :mol, :cd ]
 SI_deriv = [ :rad, :sr, :Hz, :N, :Pa, :J, :W, :C, :V, :ohm, :F, :S, :H, :Wb, :T, :lm, :lx, :Bq, :Gy, :Sv, :kat ]
 #I use the grave (G) unit to refer to kg, to avoid mistakes like mkg (milikilogram don't exist).
 #But, kg is correctly interpret through g (gram) in Non_SI

 #Conversion constants to units not from SI
 Non_SI = {
  :in => 0.0254,	#Distance units (in meter)
  :ft => 0.3048,
  :mi => 1609.344,
  :nmi => 1852,
  :pc => 3.08567782e16,
  :yd => 0.9144,
  :g => 1e-3,		#Mass units (in kilogram or graves)
  :u => 1.66053873e-27,
  :Da => 1.66090210e-27,
  :gr => 64.79891e-3,
  :lb => 0.5,
  :min => 60,		#Time units (in seconds)
  :h => 3600,
  :d => 86400,
  :gf => 9.80665e-3,	#Force units (in newton (N))
  :lbf => 4448.2216152605,
  :dyn => 1e-5,
  :psi => 6894.757,	#Pressure units (in pascal (Pa))
  :mHg => 101325e3/760, 
  :torr => 101325.0/760, 
  :bar => 100000, 
  :mH2O => 9859.503, 
  :atm => 101325,
  :eV => 1.60217733e-19,	# Energy unit (in joule (J))
  :cal => 4.1868,
  :kcal => 4186.8,
  :BTU => 1054.6,
  :hp => 735.49875,	#Power unit (in watt (W))
  :oR => 5.0/9,		#Temperature unit (in Kelvin (K))
			# o - has been used in place of degrees (°)
			# other units need summing factor
			# will be done next
  :Ci => 3.7e10		#Radioactivity unit (in Becquerel (Bq))
  }

 #Prefixes to units
 SI_prefix = { :y => -24, :z => -21, :a => -18, :f => -15, :p => -12, :n => -9, :u => -6, :m => -3, :c => -2, :d => -1, :da => 1, :h => 2, :k => 3, :M => 6, :G => 9, :T => 12, :P => 15, :E => 18, :Z => 21, :Y => 24 }
 SI_prefix_re = /^([yzafpnumcdhkMGTPEZY]|da)/

 #Using method_missing to process the units methods.
 def method_missing(method_name, *args)
  # S.I. unit or derivated from it
  # no need to convertion
  return self if SI_base.index( method_name )
  return self if SI_deriv.index( method_name )

  # General case

  # defining Regexp to determine the type of method_name
  re_prefix = SI_prefix.map { |p, e| p }.join('|')	# Regexp to match prefix of units
  re_base = SI_base.join('|')				# Regexp to match a SI base unit
  re_deriv = SI_deriv.join('|')				# Regexp to match a derived SI unit
  re_non_si = Non_SI.map { |u, f| u }.join('|')		# Regexp to match a non-SI unit

  # Match the method_name separating the prefix and non-SI units
  match = Regexp.new("^(in_)?(#{re_prefix})?(#{re_base}|#{re_deriv}|(#{re_non_si}))$").match( method_name.to_s )

  old_mm(method_name, args) if match.nil?

  # Get exponent through prefix
  exp = 0
  exp = SI_prefix[match[2].to_sym] unless match[2].nil?
  
  # Get convertion factor
  factor = 1
  factor = Non_SI[match[4].to_sym] unless match[4].nil?

  if match[1].nil?
   # Unit case, convert to SI
   return self*factor*(10**exp)
  else
   # in_ case, convert from SI to given unit
   return self/factor*(10**-exp)
  end

 end

end


class Numeric
 include PhysicsUnit
 # Included in Numeric so it can work with any number.
end
